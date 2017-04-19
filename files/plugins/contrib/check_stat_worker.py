#!/usr/bin/env python
# check if 3 workers is running for stat nav2

from sys import argv
import requests

CRITICAL = 0
NORMAL = 3
RETURN_CODE = 0

URL = argv[1]

try:
        r = requests.get(URL)

        metrics = r.json()
        nb_worker = metrics['gauges']['master.aliveWorkers']['value']
        if nb_worker == CRITICAL:
                print("CRITICAL: %d worker is running" % nb_worker)
		RETURN_CODE = 2
        elif nb_worker > CRITICAL and nb_worker < NORMAL:
                print("WARNING: Missing workers. Restart them")
                RETURN_CODE = 1
        else:
                print("OK: %d workers is running" % nb_worker)
except Exception, e:
        print("ERROR: {}".format(e))
finally:
        exit(RETURN_CODE)

