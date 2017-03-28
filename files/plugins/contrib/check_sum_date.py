#!/usr/bin/env python
# -*- coding: utf-8 -*-
from argparse import ArgumentParser
from requests import RequestException
from timeit import default_timer
from re import match
import xml.etree.ElementTree as ET
import dateutil.parser as parser
import requests

# Curl cmd
auth = ()
SUM_TEMPLATE_URL = "http://{host}/api/v4/infoVoy/rechercherProchainsDeparts" \
                    "?codeZoneArret=OCE87723197&Accept=application%2Fjson"

status_message = "{state} - {message}|time={spend_time}ms"
exit_code = 0

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


def validate_date(t_date):
    """
    Valid date is correct iso date.
    :param t_date: Date as string
    :return: Boolean
    """
    try:
        # Try to convert t_date as date object
        parser.parse(t_date)
        is_valid = True
    except Exception:
        is_valid = False
    return is_valid

if __name__ == "__main__":
    arg_parse = ArgumentParser(description="Check SUM status")
    arg_parse.add_argument("--host", metavar="hostname", help="Define hostname.", required=True)
    auth_arg_parse = arg_parse.add_mutually_exclusive_group()
    auth_arg_parse.add_argument("--auth", metavar="login:passwd", help="Sum authenticate")
    auth_arg_parse.add_argument("--webfile", metavar="file", help="Webinject file")

    user_params = arg_parse.parse_args()

    # Define http_answer variable
    http_answer = None

    # Valid auth format
    if user_params.auth:
        if match('.*:.*', user_params.auth):
            auth = tuple(user_params.auth.split(':'))
        else:
            print("Bad auth format. (login:password)")
            exit(2)
    else:
        try:
            # Open xml file
            tree = ET.parse(user_params.webfile)
            root = tree.getroot()

            # Find correct authenticate
            for http_auth in root.findall('httpauth'):
                if match('%s' % user_params.host, http_auth.text):
                    auth = (http_auth.text.split(':')[3], http_auth.text.split(':')[4])

        except Exception as e:
            print("Failed to open %s:\n%s" % (user_params.webfile, str(e)))
            exit(2)

    # Try to send http requests
    try:
        # Init header
        headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Host': "%s.canaltp.fr" % user_params.host.split('.')[0]}

        # Init sum_url
        sum_url = SUM_TEMPLATE_URL.format(host=user_params.host)

        # Send http requests and time it
        with Timer() as t:
            http_answer = requests.get(sum_url, auth=auth, headers=headers)

        if validate_date(http_answer.json()['appel']['dateHeure']) and validate_date(http_answer.json()['response']['dateHeure']):
            status_message = status_message.format(state="OK", message="DateHeure is valid ISODATE.",
                                                   spend_time=t.elapsed)
        else:
            status_message = status_message.format(state="CRITICAL", message="DateHeure is not valid ISODATE.",
                                                   spend_time=t.elapsed)

            exit_code = 2

        print(status_message)
    except RequestException:
        print("Failed to connect to %s (%s)." % (user_params.host, http_answer.status_code))
    except KeyError:
        print("dateHeure key not found. Json not valide.")

    # Exit
    exit(exit_code)
