#!/usr/bin/python
# -*- coding: utf-8 -*-
# query Elasticsearch logstash index to see if data has been inserted
# if not, there may be a problem with ES or Logstash

# https://nagios-plugins.org/doc/guidelines.html#AEN78
RETURN_CODE = 3

# threshold of elasticsearch rows before returning warning
ROWS_LIMIT = 20

ES_HOST = 'localhost'
ES_PORT = 9200

__author__ = 'Guillaume Delacour <guillaume.delacour@canaltp.fr>'

import argparse
try:
    import requests
except ImportError:
    print("UNKNOWN: Please install python-requests")
    exit(RETURN_CODE)
import datetime
try:
    import json
except ImportError:
    print("UNKNOWN: Please install python-simplejson")
    exit(RETURN_CODE)

INDEX_NAME = "logstash"

# just need the date, not time
# ex.: logstash-2015.07.15
TODAY = datetime.datetime.now().isoformat().split('T')[0].replace('-', '.')
URL = "http://{host}:{port}/{index_name}-{date}/_search" \
		.format(host=ES_HOST, port=ES_PORT, index_name=INDEX_NAME, date=TODAY)

FILTER = \
{
 "query": {
  "filtered": {
   "filter": {
    "range": {
      "@timestamp": {
       "gt": "now-1h"
      }
    }
   }
  }
 }
}

NOW = int(datetime.datetime.now().strftime("%s")) * 1000
MINUTES_AGO = int((datetime.datetime.now() - datetime.timedelta(minutes=1)).strftime("%s")) * 1000

FILTER = \
{
  "query": {
    "filtered": {
      "query": {
        "bool": {
          "should": [
            {
              "query_string": {
                "query": "*"
              }
            }
          ]
        }
      },
      "filter": {
        "bool": {
          "must": [
            {
              "range": {
                "@timestamp": {
                  "from": MINUTES_AGO,
                  "to": NOW
                }
              }
            },
            {
              "fquery": {
                "query": {
                  "query_string": {
                    "query": "*"
                  }
                },
                "_cache": "true"
              }
            }
          ]
        }
      }
    }
  },
  "highlight": {
    "fields": {},
    "pre_tags": [
      "@start-highlight@"
    ],
    "post_tags": [
      "@end-highlight@"
    ]
  },
  "size": 5,
  "sort": [
    {
      "_score": {
        "order": "desc",
        "ignore_unmapped": "true"
      }
    }
  ]
}

parser = argparse.ArgumentParser(description='Verify that logstash index is '
        'populated by docs')
parser.add_argument('--rows', '-r', dest='rows', type=int, default=ROWS_LIMIT,
                    help='if less than <rows> found, exit with warning '
                    '(default: {})'.format(ROWS_LIMIT))
args = parser.parse_args()

result = requests.get(URL, data=json.dumps(FILTER))
if result.status_code == 200:

	if result.json['hits']['total'] == 0:
		print("ERROR: no results found, check elasticsearch or logstash logs.")
		RETURN_CODE = 2
	else:
		if result.json['hits']['total'] < args.rows:
			print("WARNING: only {} events recorded."
					.format(result.json['hits']['total']))
			RETURN_CODE = 1
		else:
			print("OK: {results} result(s) found|"
                              "docs={results};{warn};;;{warn}" \
				.format(results=result.json['hits']['total'],
                                    warn=args.rows))
			RETURN_CODE = 0
		#for row in result.json['hits']['hits']:
		#	print(row['_source']['@timestamp'])
else:
	print("ERROR: Unable to request {}, http return code: {}" \
			.format(URL, result.status_code))
	RETURN_CODE = 2

exit(RETURN_CODE)
