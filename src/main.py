import urllib.parse
import urllib.request
import logging
import time

import schedule
from pymongo import MongoClient
from config import settings


def get_logger(name=__name__, debug=settings.debug):
    logger = logging.getLogger(name)
    if not logger.hasHandlers():
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(funcName)s: %(message)s"))
        handler.setLevel(logging.DEBUG if debug else logging.INFO)
        logger.addHandler(handler)

    logger.setLevel(logging.DEBUG if debug else logging.INFO)
    logger.propagate = False

    return logger


def job():
    logger = get_logger()

    user = urllib.parse.quote_plus(settings.db_user)
    password = urllib.parse.quote_plus(settings.db_password)
    host = ",".join(settings.db_hosts)

    uri = f"mongodb://{user}:{password}@{host}/?replicaSet={settings.db_replica_set}"
    logger.debug(uri)

    client = MongoClient(uri)
    time.sleep(1)

    found = False
    node_count = len(settings.db_hosts)
    for x in range(settings.retry_count):
        if node_count == len(client.nodes):
            req = urllib.request.Request(settings.heartbeat_url)
            urllib.request.urlopen(req)
            found = True
            logger.debug("OK")
            break
        time.sleep(1)

    if not found:
        logger.info("NG")
        logger.debug(client.nodes)


def main():
    job()

    schedule.every(settings.interval_min).minutes.do(job)
    while True:
        schedule.run_pending()
        time.sleep(1)


if __name__ == '__main__':
    main()
