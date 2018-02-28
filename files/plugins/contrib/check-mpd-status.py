#!/usr/bin/env python
import json
import logging
import sys
from argparse import ArgumentParser
from pygments import highlight, lexers, formatters
from timeit import default_timer

import requests
from tabulate import tabulate

"""
Check MPD status.

TODO:
- Get micro-service configuration from conf.json file.
- Extract MPD config
- Run http request
"""
__author__ = "Christophe Biguereau"
__version__ = "0.3"
__maintainer = "Christophe Biguereau"
__status__ = "ALL"

# Define docker home directory
DOCKER_HOME_DIRECTORY = "/home/sue/dockers/"

# Init stdout output
logger = logging.getLogger()


class Timer(object):
    """
    Get exec time.
    """

    def __init__(self, verbose=False):
        self.verbose = verbose
        self.timer = default_timer

    def __enter__(self):
        self.start = self.timer()
        return self

    def __exit__(self, *args):
        end = self.timer()
        self.elapsed_secs = end - self.start
        self.elapsed = round(self.elapsed_secs * 1000, 2)  # Milliseconds with 2 floating point.
        if self.verbose:
            print('elapsed time: %f ms' % self.elapsed)


class Mpd(object):

    def __init__(self, proto, host, uri=None, authenticate=None):
        self.proto = proto
        self.host = host
        self.uri = uri
        self.auth = tuple(authenticate.split(':'))

    def get_url(self):
        return "{}://{}{}".format(self.proto, self.host, self.uri)


def set_logging(lvl=logging.INFO):
    """
    Set logging output.
    :param lvl: Define log level.
    """
    # Define format
    log_format = "%(levelname)s - %(message)s"

    # Define default log level
    logger.setLevel(lvl)

    # Init logging output with format
    stdout_logger = logging.StreamHandler(sys.stdout)
    stdout_logger.setLevel(lvl)
    stdout_logger.setFormatter(logging.Formatter(log_format))

    logger.addHandler(stdout_logger)

    # Increase requests lib log level.
    logging.getLogger("requests").setLevel(logging.WARNING)


if __name__ == "__main__":
    # Define man
    args_parse = ArgumentParser("Check MPD status.")
    args_parse.add_argument("-m", metavar="micro-servives", help="Specify micro services", required=True)
    args_parse.add_argument("--perf_data", action="store_true", default=False)
    user_params = args_parse.parse_args()

    # Init logger
    set_logging()

    try:
        # Try to read Json file
        with open("{}/{}/conf.json".format(DOCKER_HOME_DIRECTORY, user_params.m)) as f:
            # Load json config
            config_json = json.load(f)['modules'][user_params.m]

        # Create MPD config
        mpd = Mpd(proto=config_json['mpdConfig']['protocol'],
                  host=config_json['mpdConfig']['hostname'],
                  authenticate=config_json['mpdConfig']['auth'])

        # Add url to mpd
        if "mpdHealthCheckPath" in config_json.keys():
            setattr(mpd, 'uri', '{}{}'.format(config_json['mpdConfig']['pathname'],
                                              config_json['mpdHealthCheckPath']))
        elif "mpdMethods" in config_json.keys():
            setattr(mpd, 'uri', '{}{}'.format(config_json['mpdConfig']['pathname'],
                                              config_json["mpdMethods"]["healthCheck"]))

        # Run query
        with Timer() as t:
            r = requests.get(mpd.get_url(), auth=mpd.auth)

        # Return perf data output
        if user_params.perf_data:

            if r.status_code != 200:
                logger.critical("Failed to contact {}: {} | time={}s size={}B".format(mpd.get_url(), r.status_code,
                                                                                      round(t.elapsed_secs, 2),
                                                                                      r.headers['content-length']))
            else:
                logger.info("MPD OK | time={}s size={}B".format(t.elapsed_secs, r.headers['content-length']))

        else:

            logger.info("MPD status.")
            table = [["Descriptions", "Values"], ["http code", r.status_code],
                     ["time spend (sec)", round(t.elapsed_secs, 2)], ["content-length", r.headers['content-length']],
                     ["url", str(r.url)], ["content-type", r.headers['content-type']]]

            # Output table
            print tabulate(table, headers="firstrow")

            # Get Lexer base on content-type
            if r.headers['content-type'].startswith('application/xml'):
                lexer = lexers.XmlLexer()
            elif r.headers['content-type'].startswith('application/json'):
                lexer = lexers.JsonLexer()
            else:
                lexer = lexers.HtmlLexer()

            # Try to print JSON content
            try:
                # Format Json with indentation
                formatted_http_response = json.dumps(json.loads(r.text), sort_keys=True, indent=2)
            except Exception:
                formatted_http_response = r.text

            print("content:\n{}".format(highlight(formatted_http_response,lexer, formatters.TerminalFormatter())))

    except ValueError as e:
        logger.critical("Json file invalid: {}".format(e))
    except KeyError as e:
        print e
        logger.critical("MPD configuration do not exist for {}.".format(user_params.m))
    except IOError as e:
        logger.critical("Micro-services do not exist: {}".format(e))

