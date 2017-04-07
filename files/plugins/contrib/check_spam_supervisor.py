#!/usr/bin/env python
# -*- coding: utf-8 -*-
from argparse import ArgumentParser
import subprocess as subproc
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
import dateutil.parser

supervisor_xml = None
supervision_last_update = None
check_spam_service_output = []
check_spam_service_status = 0

if __name__ == "__main__":
    # Set available parameters.
    arg_parser = ArgumentParser(description="Check supervision.xml file for SPAM service.", usage='%(prog)s [options]')
    arg_parser.add_argument("--socket", "-s", metavar="socket", help="Docker socket.",
                            default="unix:///var/run/docker.sock")
    arg_parser.add_argument("--container", "-c", metavar="container_name",
                            help="Container name to check supervisor file.", required=True)
    arg_parser.add_argument("--supervisor_path", "-f", metavar="file", help="Supervisor xml file path.",
                            default="/tmp/supervision.xml")

    user_param = arg_parser.parse_args()

    # Try to get supervisor.xml file from docker container.
    try:
        # exec command
        docker_exec_cmd = ["docker", "-H", user_param.socket, "exec", user_param.container, "cat",
                           user_param.supervisor_path]

        docker_output = subproc.check_output(docker_exec_cmd, stderr=subproc.STDOUT)

        # Convert string output to xml.
        supervisor_xml = ET.fromstring(docker_output)

        # Get supervision last update
        supervision_last_update = dateutil.parser.parse(supervisor_xml.attrib['last_update'])

    except subproc.CalledProcessError as e:
        print("Failed to run command on {} container: {}".format(user_param.container, e.output))
        exit(3)
    except ET.ParseError as e:
        print("Failed to parse {} in {}: {}".format(user_param.supervisor_path, user_param.container, e))
        exit(3)
    except TypeError:
        print("Failed to parse date in supervision last update.")
        exit(3)
    except Exception as e:
        print("Unexpected error: {}".format(e))
        exit(3)

    # Set supervision last update limit at 4 hours ago.
    supervision_last_update_limit = datetime.now() - timedelta(hours=4)

    if supervision_last_update and supervision_last_update < supervision_last_update_limit:
        check_spam_service_output.append("Supervision last update older than 4 hours")
        check_spam_service_status = 2

    # Set limit for each element
    supervision_last_run_limit = datetime.now() - timedelta(minutes=5)
    supervision_last_feedback_limit = datetime.now() - timedelta(hours=25)

    # Get information in each elements
    for element in supervisor_xml.getchildren():

        if "last_feedback" in element.keys():
            # Get element last run
            element_last_feedback = dateutil.parser.parse(element.attrib['last_feedback'])

            if element_last_feedback < supervision_last_feedback_limit:
                check_spam_service_output.append("Supervision {} {} older than {}".format(element.tag,
                                                                                          "last_feedback",
                                                                                          supervision_last_feedback_limit.strftime("%Y-%m-%d %H:%M:%S")))
                check_spam_service_status = 2

        try:
            # Get element last feedback
            element_last_run = dateutil.parser.parse(element.attrib['last_run'])

            if element_last_run < supervision_last_run_limit:
                check_spam_service_output.append("Supervision {} {} older than {}".format(element.tag,
                                                                                          "last_run",
                                                                                          supervision_last_run_limit.strftime("%Y-%m-%d %H:%M:%S")))
                check_spam_service_status = 2

        except ValueError:
            check_spam_service_output.append("Supervision {} no {} correct value".format(element.tag, "last_run"))
        except KeyError:
            check_spam_service_output.append("Supervision {} no {} key".format(element.tag, "last_run"))

        # Get errors
        element_errors = int(element.find('errors').attrib['count'])

        if element_errors > 0:
            check_spam_service_output.append("Supervision {} {} > 0".format(element.tag, "errors", element_errors))
            check_spam_service_status = 2

    if len(check_spam_service_output) > 0:
        print(" | ".join(check_spam_service_output))
    else:
        print("No issue on {}".format(user_param.container))

    exit(check_spam_service_status)
