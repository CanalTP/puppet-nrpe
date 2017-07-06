#!/usr/bin/env python
# -*- coding: utf-8 -*-
from argparse import ArgumentParser
import requests
import yaml

"""
Check Rabbitmq queue metrics.
This script use rabbitmq API to get metrics from each queue
and verify value define by the user.

Parameters:
- host: define Rabbitmq host.
- port: define Rabbitmq port.
- authenticate: Rabbitmq login and password (login:password format)
- queues: List of queues which we want.
- check: List of metric to check with warning and critical values (metric_name:warning:critical format)

You can define all parameters in config.yml file:
host: "rabbitmq_host"
port: 15672
authenticate: "user:password"
queues:
  - "queue1"
  - "queue2"
  - "queue3"
  
"""
__author__ = "Christophe Biguereau"
__version__ = "1.0"

# Init empty configuration
cfg = None

# Valid Keys
VALID_KEYS = ['host', 'port', 'queues', 'authenticate']

# Final
OUTPUT_PREFIX = ("OK", "WARNING", "CRITICAL")
exit_code = 0


class RabbitmqApi:
    """
    Create Driver to connect to Rabbitmq API.
    """

    def __init__(self, host, port, user, password, proto="http"):
        """
        Init driver with host, port, proto, user and password.
        :param host: Rabbitmq Host.
        :param port: Rabbitmq Port.
        :param user: User to connect to rabbitmq.
        :param password: Password to connect to rabbitmq.
        :param proto: Protocol to connect to rabbitmq API.
        """
        self.host = "%s://%s:%s" % (proto, host, port)
        self.auth = (user, password)

    def get_queue(self, queues_name_filter=None):
        """
        Get Rabbitmq queues.
        :param queues_name_filter: Filter by queues name.
        :return: List of rabbitmq queues.
        """
        try:
            # Send Request to Rabbitmq API.
            r = requests.get("%s/%s" % (self.host, "api/queues"), auth=self.auth)

            # Raise error if http code != 200
            r.raise_for_status()

            # If queues_name filter define.
            if queues_name_filter:

                # Init queues
                rabbitmq_queues = []

                for q in r.json():
                    if q['name'] in queues_name_filter:
                        rabbitmq_queues.append(q)

            else:
                rabbitmq_queues = r.json()

            return rabbitmq_queues

        except (requests.HTTPError, requests.ConnectionError) as http_error:
            print("HTTP ERROR: Failed to connect to %s: %s." % (self.host, http_error))
            exit(2)
        except Exception as e:
            print("Unexpected error: %s." % str(e))
            exit(2)


def is_config_validator(config, valid_keys):
    """
    Validate configuration parameters.
    :param config: Configuration dictionary. 
    :param valid_keys: List of valid keys.
    :return: Boolean
    """

    for vk in valid_keys:
        if vk not in config.keys():
            print("Configuration error, %s parameters missing." % vk)
            exit(2)

    return True


def check_parameters(check_settings):
    """
    Return Check configuration with correct format.
    :param check_settings: String with field name, warning and critical value.
    :return: Tuple with type
    """
    keys, warn, crit = check_settings.split(':')

    try:
        warn = int(warn)
    except ValueError:
        warn = 0

    try:
        crit = int(crit)
    except ValueError:
        crit = 0

    return keys, warn, crit


if "__main__" == __name__:
    # Define arguments parser
    arg_parser = ArgumentParser(description="Check rabbitmq queues.")
    file_group = arg_parser.add_argument_group('File config.')
    file_group.add_argument("--file", "-f", metavar="file", help="YAML File with script parameters.")
    obo_group = arg_parser.add_argument_group('One by one parameters.')
    obo_group.add_argument("--host", "-H", metavar="host", help="Rabbitmq Host")
    obo_group.add_argument("--port", "-p", metavar="port", help="Rabbitmq port", default="15672")
    obo_group.add_argument("--queues", "-q", metavar="queues_name_list", nargs='+', help="Queues names.")
    obo_group.add_argument("--authenticate", "-a", metavar="login:password", help="Login and password for rabbitmq.")
    arg_parser.add_argument("--check", '-c', metavar="filed:warning:critical", nargs='+',
                            help="List of field to check with warning and critical limit.")
    arg_parser.add_argument("--list", "-l", action='store_true', help="List available field.")

    params = arg_parser.parse_args()

    # Check required parameters
    if not params.file and not params.host:
        print("Required parameters missing.")
        arg_parser.print_help()
        exit(2)

    # If file option is define
    if params.file:
        try:
            with open(params.file, 'r') as f:
                cfg = yaml.load(f)
        except IOError as e:
            print("Failed to read file %s: %s" % (params.file, e))
            exit(2)
        except Exception as e:
            print("Unexpected error while read file %s: %s." % (params.file, e))
            exit(2)
    else:
        # Init cfg as dict
        cfg = {}

        for k, v in params.__dict__.items():
            if v is not None:
                cfg[k] = v

    # if config is valid.
    if is_config_validator(cfg, VALID_KEYS):

        # Create rabbitmq driver.
        rabbitmq_login, rabbitmq_password = cfg['authenticate'].split(':')
        rabbitctl = RabbitmqApi(cfg['host'], cfg['port'], rabbitmq_login, rabbitmq_password)

        # Add run get queues
        try:
            rabbit_queues = rabbitctl.get_queue(queues_name_filter=cfg['queues'])
        except KeyError:
            rabbit_queues = rabbitctl.get_queue()

        # If list option are set
        if params.list:
            print("Metrics available on %s:" % cfg['host'])

            for k, v in rabbit_queues[0].items():

                if isinstance(v, dict):
                    for sub_k in v.keys():
                        print("- %s.%s" % (k, sub_k))
                else:
                    print("- %s" % k)

        # Run check
        if params.check:

            # Define final output
            script_output = []

            # For each check define.
            for check in params.check:

                # Split field name, warning and critical number.
                field, warning, critical = check_parameters(check)

                # For each queue.
                for queue in rabbit_queues:

                    # Get value from field name.
                    q_value = queue
                    for k in field.split('.'):
                        q_value = q_value[k]

                    if warning < q_value:
                        # Append output message.
                        script_output.append(" %s %s OK" % (queue['name'], field))
                        pass

                    elif critical < q_value < warning:
                        # Append output message.
                        script_output.append(" %s %s < %s" % (queue['name'], field, warning))

                        # Set exit code
                        exit_code = 1

                    elif q_value <= critical:
                        # Append output message
                        script_output.append(" %s %s < %s" % (queue['name'], field, critical))

                        # Set exit code
                        exit_code = 2

            # Print finale output.
            print("%s: %s" % (OUTPUT_PREFIX[exit_code], ";".join(script_output)))

            exit(exit_code)
