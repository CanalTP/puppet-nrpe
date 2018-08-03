#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Permet de verifier le nombre de worker actifs
#
# File managed by puppet, don't edit directly
#

FILE = '/tmp/supervision.xml'
WARN_DELTA = 5
CRITICAL_DELTA = 1

from optparse import OptionParser
from xml.etree import ElementTree
# do a reverse dns lookup to identify worker by name instead of ip
from socket import gethostbyaddr

parser = OptionParser()
parser.add_option("-c", "--critical", dest="critical", help="si workers actif inferieur => Critical", type=int, default=0)
parser.add_option("-w", "--warning",dest="warning",help="si workers actif inferieur => Warning", type=int, default=5)
(options, args) = parser.parse_args()

try :
        f = open(FILE, 'r')
except :
        print('Erreur pas fichier  %s trouve.' % FILE)
        exit(3)
doc = ElementTree.parse(f)

node = doc.getroot()
nb_wrk = node.get("workers")

# get all workers hostname to easily identify missing ones
workers = node.findall('Worker')

if (int(nb_wrk) <= options.warning) & (int(nb_wrk) > options.critical) :
	print('WARNING  : Il y a seulement '+str(nb_wrk)+' worker(s) actif(s) : ')
        for worker in workers:
		print gethostbyaddr(worker.attrib['hostname'])[0].replace('.canaltp.prod', ''),
        exit(1) # WARNING
if int(nb_wrk) <= options.critical :
	print('CRITICAL : Il y a seulement '+str(nb_wrk)+' worker(s) actif(s) : ')
        for worker in workers:
                print gethostbyaddr(worker.attrib['hostname'])[0].replace('.canaltp.prod', ''),
	exit(2) # CRITICAL
if int(nb_wrk) > options.warning :
        print('OK : Les '+str(nb_wrk)+' workers sont Ok')
        exit(0) # OK
print('UNKNOWN : Erreur dans la recuperation des workers actifs')
exit(3)
