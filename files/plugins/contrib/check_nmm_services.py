#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Fabien Degomme <fabien.degomme@canaltp.fr'

import argparse
import xml.etree.ElementTree as ET
import requests

def main():
    parser = argparse.ArgumentParser(description='This scripts allows you to check NMM services like Pdf Generator. Default page is http://nmm-ihm.mutu.prod.canaltp.fr/admin/monitoring/all/application/mtt.xml')

    parser.add_argument('--url', '-u', dest='url', default="http://nmm-ihm.mutu.prod.canaltp.fr/admin/monitoring/all/application/mtt.xml", help='Default: http://nmm-ihm.mutu.prod.canaltp.fr/admin/monitoring/all/application/mtt.xml')
    parser.add_argument('--service', '-s', dest='service', choices=['PostgreSQL', 'Supervisord', 'Pdf Generator', 'RabbitMQ', 'MediaManager', 'Navitia', 'TimeTable Application'], required=True)

    args = parser.parse_args()

    url = args.url
    service = args.service

    try:
        xmlpage = requests.get(url)
    except requests.exceptions.RequestException as err:
        print('CRITICAL : {}'.format(err))
        exit(2)

    try:
        root = ET.fromstring(xmlpage.text)
    except Exception as err:
        print('CRITICAL : {}, is it really an XML resource ?'.format(err))
        exit(2)

    for element in root.iter():
        if service in element.attrib.values():
            app = element.attrib
            break

    if app is None:
        print('UNKNOWN : Something wrong happens, i can not find application name : check app name with XML page')
        exit(3)

    if app['state'] == 'UP':
        print('OK : {} is {}'.format(app['name'], app['state']))
        exit(0)
    elif app['state'] == 'DOWN':
        print('CRITICAL : {} is {}'.format(app['name'], app['state']))
        exit(2)
    else:
        print('WARNING : {} is neither UP or DOWN. Status: {}'.format(app['name'], app['state']))
        exit(1)


if __name__ == "__main__":
    main()
