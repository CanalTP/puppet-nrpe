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

err = doc.find('Summary/Error')

if err is not None :
        print('CRITICAL : Erreur détectée dans le fichier de supervision %s' % FILE )
        exit(2) # CRITICAL
print('OK : No errors')
exit(0)
