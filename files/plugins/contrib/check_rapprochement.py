#!/usr/bin/env python
# -*- coding: utf-8 -*-

#-------------------------------------------------------------------------------
# Name:        
# Purpose:     Permet de grapher le temps des rapprochements
# Author:      dcorreia
#
# Created:     08/07/2013
#-------------------------------------------------------------------------------

from optparse import OptionParser
from xml.etree import ElementTree

fic = '/tmp/supervision.xml'

try :
  f = open(fic, 'r') 
except :
  print('Erreur pas fichier  %s trouve.' % fic)
  exit(3)

arbre = ElementTree.parse(f)
lastduration = arbre.find( './/Summary/Reconciliation/LastDuration')
temps = lastduration.text
print ('OK | Rapprochement=%s' % temps)
exit(0)

