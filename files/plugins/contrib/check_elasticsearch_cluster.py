#!/usr/bin/python
# simple test status of an elasticsearch cluster and return 1 if not green

RETURN_CODE = 3

try:
    import requests
except ImportError:
    print("UNKNOWN: Please install python-requests")
    exit(RETURN_CODE)

URL = 'localhost'
PORT = 9200

try:
    #{"cluster_name":"cloudops_logs","status":"yellow","timed_out":false,"number_of_nodes":3,"number_of_data_nodes":2,"active_primary_shards":125,"active_shards":163,"relocating_shards":0,"initializing_shards":2,"unassigned_shards":85,"number_of_pending_tasks":0}
    result = requests.get("http://{url}:{port}/_cluster/health"
            .format(url=URL, port=PORT))

    if 'green' not in result.json['status']:
        print("WARNING: the cluster '{cluster_name}' is in {status} status"
            .format(cluster_name=result.json['cluster_name'], status=result.json['status']))
        RETURN_CODE = 1
    else:
        print("OK: cluster {} is {}"
                .format(result.json['cluster_name'],
                        result.json['status']))
        RETURN_CODE = 0
except Exception, e:
    print("ERROR: {}".format(e))
finally:
    exit(RETURN_CODE)
