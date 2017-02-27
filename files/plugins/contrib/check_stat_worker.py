#!/usr/bin/env python
# check if 3 workers is running for stat nav2

import requests

CRITICAL = 2
RETURN_CODE = 3

try:
        r = requests.get('http://nav2-pre-logn1.canaltp.prod:9999/proxy:spark-master:8080/metrics/master/json/')

        metrics = r.json()
        nb_worker = metrics['gauges']['master.aliveWorkers']['value']
        if nb_worker <= CRITICAL:
                print("Missing workers. Restart them")
        else:
                print("%d workers is running" % nb_worker)
                RETURN_CODE = 0
except Exception, e:
        print("ERROR: {}".format(e))
finally:
        exit(RETURN_CODE)

