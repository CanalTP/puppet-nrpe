#!/usr/bin/env python
import json
from optparse import OptionParser
from pprint import pprint

def main():

   usage = "Usage: %prog -f -k <PathOfFile>\n"
   parser = OptionParser(usage=usage)
   parser.add_option("-f", "--PathOfFile", dest="path", help="Path json file")
   parser.add_option("-k", "--KeyInJson", dest="key", help="Key json in file")
   (options, args) = parser.parse_args()
   if options.path is None or options.key is None :
      print usage
      exit(3)
   json_data=open(options.path)
   data=json.load(json_data)
   #pprint(data)
   status = data[options.key]['state']
   datetime= data[options.key]['last_date']
   if status is not True:
      print "The Status is not TRUE"
      print "Relancer le service "+ options.key +" sur l'ihm supervisord"
      exit(2)
   else:
      print "The Status is TRUE"
      exit(0)

if __name__ == "__main__":
   main()
