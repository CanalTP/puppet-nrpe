#!/usr/bin/env python
# -*- coding: utf-8 -*-
import logging
import time
import sys
from argparse import ArgumentParser
from datetime import datetime

import requests
from google.transit import gtfs_realtime_pb2

# Init stdout output
logger = logging.getLogger()


def get_gtfs(url):
    """
    Get GTFS data from url.
    :param url: Url to get GTFS data.
    :return: GTFS realtime.
    :rtype: GTFS message.

    """

    try:
        # Init GTFS feed
        feed = gtfs_realtime_pb2.FeedMessage()

        # Get GTFS data from url
        r = requests.get(url)

        # Raise error if http code != 200
        r.raise_for_status()

        # Set feed with GTFS
        feed.ParseFromString(r.content)

        return feed

    except (requests.ConnectionError, requests.HTTPError) as e:
        logger.error("Failed to get %s: %s." % (url, str(e)))
        exit(2)


def set_logging(lvl=logging.INFO):
    """
    Set logging output.
    :param lvl: Define log level.
    """
    # Define format
    log_format = "%(levelname)s - %(message)s"

    # Init logging output with format
    stdout_logger = logging.StreamHandler(sys.stdout)
    stdout_logger.setLevel(lvl)
    stdout_logger.setFormatter(logging.Formatter(log_format))

    logger.addHandler(stdout_logger)

    # Increase requests lib log level.
    logging.getLogger("requests").setLevel(logging.WARNING)


if __name__ == '__main__':
    # Create Arguments parser.
    args_parser = ArgumentParser("Read GTFS realtime flux.")
    args_parser.add_argument("--url", "-u", metavar="http://", help="Url to get GTFS realtime file.", required=True)
    args_parser.add_argument("--delta", "-d", metavar="time", help="Time delta in seconds.", type=int, required=True)

    params = args_parser.parse_args()

    # Set logging output
    set_logging()

    # Get GTFS feed from url.
    gtfs_feed = get_gtfs(params.url)

    # Check if trip update is present
    trip_update_is_present = False
    for entity in gtfs_feed.entity:
        if entity.HasField('trip_update'):
            trip_update_is_present = True
            break

    if not trip_update_is_present:
        logger.error("Trip Update field is missing in %s." % params.url)
        exit(2)

    # Check if timestamp is not older than delta.
    try:
        # Get current timestamp from GTFS
        gtfs_feed_timestamp = int(gtfs_feed.header.timestamp)

        if (time.time() - params.delta) > gtfs_feed_timestamp:
            logger.error("GTFS feed is older than %s seconds. (%s)" %
                          (params.delta, datetime.fromtimestamp(gtfs_feed_timestamp).strftime('%Y-%m-%d %H:%M:%S')))

    except AttributeError as e:
        logger.error("Attribut missing: %s." % str(e))
        exit(2)
    except Exception as e:
        logger.error("Unexpected error: %s." % str(e))
        exit(2)

    logger.info("Feed on %s OK." % params.url)
