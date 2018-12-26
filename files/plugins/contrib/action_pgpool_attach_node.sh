#!/bin/bash
#Script managed by Puppet

#action script launch by Centreon to attache pgpool node to cluster
/usr/sbin/pcp_attach_node -d 5 localhost 9898 pgpool pgpool 0
