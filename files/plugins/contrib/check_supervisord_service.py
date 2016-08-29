#!/usr/bin/env python
import subprocess
from optparse import OptionParser

def main():

   usage = "Usage: %prog -s <service>\n"
   parser = OptionParser(usage=usage)
   parser.add_option("-s", "--SERVICE",dest="service",help="email_sender est le service")
   (options, args) = parser.parse_args()

   if options.service is None :
      print usage
      exit(3)
   var=+options.service
   p = subprocess.Popen(["sudo","/usr/bin/supervisorctl","status "+var], stdout=subprocess.PIPE)
   out, err = p.communicate()
   if ('RUNNING' in out):
      print('Started')
      exit(0)
   else:
      print('Stopped')
      exit(2)
if __name__ == "__main__":
   main()
