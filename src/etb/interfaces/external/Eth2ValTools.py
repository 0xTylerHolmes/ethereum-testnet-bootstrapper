import logging
import subprocess
import pathlib
from typing import Union


class Eth2ValTools(object):
    def __init__(self):
        self.logger = logging.getLogger()

    def generate_deposit_data(
            self, ndx: int, amount: int, fork_version: str, mnemonic: str
    ) -> Union[str, Exception]:
        """
        Generate a deposit data file for a validator.
        :param ndx: the validator index
        :param amount: amount of ether to deposit
        :param fork_version: fork version to use
        :param mnemonic: validator mnemonic
        :return:
        """

        self.logger.debug(
            f"Generating deposit for validator {ndx} with {amount} ether."
        )
        cmd = [
            "eth2-val-tools",
            "deposit-data",
            "--amount",
            str(amount),
            "--fork-version",
            str(fork_version),
            "--source-min",
            str(ndx),
            "--source-max",
            str(ndx + 1),
            "--validators-mnemonic",
            mnemonic,
            "--withdrawals-mnemonic",
            mnemonic,
        ]
        self.logger.debug(f"Running command: {cmd}")
        out = subprocess.run(cmd, capture_output=True)
        if len(out.stderr) > 0:
            return Exception(out.stderr)

        return out.stdout.decode("utf-8")

    def generate_keystores(
            self,
            out_path: pathlib.Path,
            min_ndx: int,
            max_ndx: int,
            mnemonic: str,
            prysm: bool = False,
            prysm_password: str = "testnet_password",
    ) -> Union[str, Exception]:
        """
        Generate keystores for a range of validators.
        :param out_path: output path for the keystores
        :param min_ndx: minimum validator index
        :param max_ndx: maximum validator index
        :param mnemonic: the mnemonic to use to generate the keystores
        :param prysm: if True, generate prysm keystores
        :param prysm_password: what password to use for prysm keystores
        :return:
        """

        self.logger.debug(
            f"Generating keystores for validators {min_ndx} to {max_ndx}."
        )
        cmd = [
            "eth2-val-tools",
            "keystores",
            "--source-min",
            str(min_ndx),
            "--source-max",
            str(max_ndx),
            "--source-mnemonic",
            mnemonic,
            "--out-loc",
            str(out_path),
        ]

        if prysm:
            cmd.append("--prysm-pass")
            cmd.append(prysm_password)

        self.logger.debug(f"Running command: {cmd}")
        out = subprocess.run(cmd, capture_output=True)
        if len(out.stderr) > 0:
            return Exception(out.stderr)

        return out.stdout.decode("utf-8")
