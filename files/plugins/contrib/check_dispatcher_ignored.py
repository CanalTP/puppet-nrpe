#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# File managed by puppet, don't edit directly
#

FILE = '/tmp/supervision.xml'

from xml.etree.ElementTree import ElementTree
from datetime import datetime, timedelta

doc = ElementTree()
doc.parse(FILE)

ign = doc.find('Summary/LoadMonitoring/Ignored')
cun = doc.find('Summary/LoadMonitoring/Count')

if int(ign.text) >= int(cun.text) :
    print('Count >= Ignored|Surveillance_ignored=%s' % ign.text)
    exit(2) # CRITICAL
elif int(ign.text) > 0 :
    print('Ignored > 0|Surveillance_ignored=%s' % ign.text)
    exit(1)#WARN
else:
    print('OK : No Ignored')
    exit(0)
