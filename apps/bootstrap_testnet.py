import argparse
from pathlib import Path
import shutil

from modules.TestnetBootstrapper import EthereumTestnetBootstrapper

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--config",
        dest="config",
        required=True,
        help="Which config file to use to create a testnet.",
    )

    parser.add_argument(
        "--clear-last-run",
        dest="clear_last_run",
        action="store_true",
        default=False,
        help="Clear the last run.",
    )

    parser.add_argument(
        "--init-testnet",
        dest="init_testnet",
        action="store_true",
        default=False,
        help="Initialize the testnet to be bootstrapped.",
    )

    parser.add_argument(
        "--bootstrap-testnet",
        dest="bootstrap_testnet",
        action="store_true",
        default=False,
        help="Start the testnet",
    )

    parser.add_argument(
        "--log-to-stdout",
        dest="log_to_stdout",
        action="store_true",
        default=True,
        help="add a log stream handler for stdout.",
    )

    parser.add_argument(
        "--log-to-file",
        dest="log_to_file",
        action="store_true",
        default=True,
        help="add a log stream handler for a file.",
    )

    parser.add_argument(
        "--log-file",
        dest="log_file",
        default="/source/data/bootstrapper.log",
        help="Log file destination for the bootstrapper.",
    )

    parser.add_argument(
        "--log-level",
        dest="log_level",
        default="debug",
        help="logging level to use.",
    )

    args = parser.parse_args()

    etb = EthereumTestnetBootstrapper(args.config)
    if args.clear_last_run:
        etb.clear_last_run()

    if args.init_testnet:
        etb.init_testnet()

    if args.bootstrap_testnet:
        etb.bootstrap_testnet()
