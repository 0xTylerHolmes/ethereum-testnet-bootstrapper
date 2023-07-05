import argparse
import logging

import requests

from etb.config.etb_config import ETBConfig, get_etb_config
from etb.common.utils import create_logger
from etb.interfaces.client_request import BeaconAPIRequest, perform_batched_request

class beacon_getNodeIdentity(BeaconAPIRequest):
    # https://ethereum.github.io/beacon-APIs/#/Node/getNetworkIdentity
    def __init__(self, max_retries: int = 3, timeout: int = 5):
        payload = "/eth/v1/node/identity"
        super().__init__(
            payload=payload,
            max_retries=max_retries,
            timeout=timeout,
        )

    def get_peer_id(self, resp: requests.Response):
        if self.is_valid(resp):
            return resp.json()["data"]["peer_id"]
        else:
            return resp # an exception


if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--out-file",
        dest="dest",
        required=True,
        help="path to write the enr list",
    )

    parser.add_argument(
        "--checkpoint-file",
        dest="checkpoint_file",
        required=True,
        help="path to the checkpoint file to write.",
    )
    parser.add_argument(
        '--trusted-peer-instance',
        dest='trusted_instance',
        required=True,
        help='the client-instance name to grab the enrs from',
    )

    args = parser.parse_args()

    create_logger(name="trusted-peer-writer", log_level="info")
    etb_config: ETBConfig = get_etb_config()

    logging.info(f"Using trusted peers from {args.trusted_instance}")

    # get the wormtongue instances
    trusted_instances = []
    for instance in etb_config.get_client_instances():
        if args.trusted_instance in instance.name:
            trusted_instances.append(instance)

    logging.info(f"Grabbing peer id from {trusted_instances}")

    # retry more than enough times for the client to come online.
    api_request = beacon_getNodeIdentity(max_retries=100, timeout=5)

    peer_ids: dict[str, str] = {}
    # query all the wormtongue instances for their peer id.
    for instance, result_future in perform_batched_request(api_request, trusted_instances).items():
        resp = result_future.result()
        if api_request.is_valid(resp):
            peer_ids[instance.name] = api_request.get_peer_id(resp)
        else:
            logging.error(f"Failed to get node identity from {instance.name}")
            continue

    logging.info(f"Got trusted peer ids {peer_ids}")

    with open(args.dest, "w") as f:
        f.write(",".join(peer_ids.values()))

    # signal clients to come up.
    with open(args.checkpoint_file, "w") as f:
        f.write("0")
