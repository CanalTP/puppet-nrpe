#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# File managed by puppet, don't edit directly
#

from xml.etree.ElementTree import ElementTree
from datetime import datetime, timedelta
import os

FILE = '/tmp/supervision.xml'
WARN_DELTA = 20
CRITICAL_DELTA = 60

#On verifie si le dispatcher est actif
date_fic = os.path.getmtime(FILE)
date_fic = datetime.fromtimestamp(date_fic)
if (datetime.now() - date_fic) > timedelta(minutes=10):
        print("Le dispatcher est passif, le test ne sera pas execute.")
        exit(0)
		
doc = ElementTree()
doc.parse(FILE)

node = doc.find('Summary/LoadMonitoring/Date')

try:
    date = datetime.strptime(node.text, '%Y-%b-%d %H:%M:%S.%f')
except ValueError:
    print "CRITICAL : Le format de la date retournee par le xml ne semble pas valide"
    exit(2)

delta = datetime.now() - date

if delta >= timedelta(minutes=CRITICAL_DELTA):
    print('no reconciliation since %d minutes' % CRITICAL_DELTA)
    print ('Time from last reconciliation : %s' % delta)
    exit(2) # CRITICAL
elif delta >= timedelta(minutes=WARN_DELTA):
    print('no reconciliation since %d minutes' % WARN_DELTA)
    print ('Time from last reconciliation : %s' % delta)
    exit(1)#WARN
else:
    print('OK : delta OK')
    print ('Time from last reconciliation : %s' % delta)
    exit(0)
