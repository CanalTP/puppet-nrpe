#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
# File managed by puppet, don't edit directly
#

FILE = '/tmp/supervision.xml'
WARN_DELTA = 3
CRITICAL_DELTA = 5

from xml.etree.ElementTree import ElementTree
from datetime import datetime, timedelta

doc = ElementTree()
doc.parse(FILE)

node = doc.find('Summary/Reconciliation/Date')

try:
    date = datetime.strptime(node.text, '%Y-%b-%d %H:%M:%S.%f')
except ValueError:
    print "CRITICAL : Le format de la date retournee par le xml ne semble pas valide"
    exit(2)

delta = datetime.now() - date

if delta >= timedelta(minutes=CRITICAL_DELTA):
    print('no reconciliation since %d minutes' % CRITICAL_DELTA)
    print delta
    exit(2) # CRITICAL
elif delta >= timedelta(minutes=WARN_DELTA):
    print('no reconciliation since %d minutes' % WARN_DELTA)
    print delta
    exit(1)#WARN
else:
    print('OK : delta OK')
    print delta
    exit(0)

