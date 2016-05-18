#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# File managed by puppet, don't edit directly
#

WARN_DELTA = 2
CRITICAL_DELTA = 5
ERREUR = 3
file_supervision="/tmp/supervision.xml"

from optparse import OptionParser
from datetime import datetime, timedelta
from xml.etree import ElementTree
import os

parser = OptionParser()
parser.add_option("-f", "--file", dest="FILE", help="The file of supervision")
parser.add_option("-e", "--error", dest="err_critical", help="nb max of error before critical",type=int,default=0)
(options, args) = parser.parse_args()


#On test que le fichier de supervision existe
try :
          f = open(options.FILE, 'r')
except :
          print('Erreur pas fichier  %s trouve.' % options.FILE)
          exit(3)

#On verifie si le dispatcher est actif
date_fic = os.path.getmtime(file_supervision)
date_fic = datetime.fromtimestamp(date_fic)
if (datetime.now() - date_fic) > timedelta(minutes=10):
        print("Le dispatcher est passif, le test ne sera pas execute.")
        exit(0)

#on reecris le contenue du fichier dans un autre fichier sans les lignes "error" (probleme de parsing avec ces lignes)
f2 = open(options.FILE+'~','w')
lines = f.readlines()
for line in lines:
        if "<error>" not in line:
           f2.write(line)
f.close()
f2.close()

#on ouvre et parse le nouveau fichier
f2 = open(options.FILE+'~','r')
doc = ElementTree.parse(f2)
node = doc.getroot()
gen_date = node.get("generation_date")
try:
        gen_date = datetime.strptime(gen_date, '%Y-%m-%dT%H:%M:%S.%f')
except ValueError:
    print "CRITICAL : Le format de la date retournee par le xml ne semble pas valide."
    exit(2)

delta = datetime.now() - gen_date

if delta < timedelta(minutes=WARN_DELTA):
    ERREUR = 0
elif delta >= timedelta(minutes=WARN_DELTA) and delta < timedelta(minutes=CRITICAL_DELTA):
    ERREUR = 1
elif delta > timedelta(minutes=CRITICAL_DELTA):
    ERREUR = 2

node = doc.find('errors')
errors_count = node.get('count')

f2.close()
os.remove(options.FILE+'~')
if ERREUR == 0 and int(errors_count) <= options.err_critical:
    print("OK: Delta Ok et le nombre d erreur est inferieur ou egale a %s." % options.err_critical)
    print("Delta depuis la derniere generation : %s." % delta)
    exit(0)
if  int(errors_count) > options.err_critical :
    print("Critical: %s erreur(s) detecte dans le fichier de supervision." % errors_count)
    exit(2)
if ERREUR == 1:
    print("Warning: Delta de %s minutes depasse." % WARN_DELTA)
    print("Delta depuis la derniere generation : %s." % delta)
    exit(1)
if ERREUR == 2:
    print("CRITICAL: Delta de %s minutes depasse." % CRITICAL_DELTA)
    print("Delta depuis la derniere generation : %s." % delta)
    exit(2)

print('UNKNOW : Erreur dans la recuperation des donnees')
exit(3)