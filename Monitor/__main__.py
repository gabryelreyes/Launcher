""" Monitoring Script for DCS using InfluxDB and Grafana """

# MIT License
#
# Copyright (c) 2023 Gabryel Reyes <gabryelrdiaz@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#


################################################################################
# Imports
################################################################################

import sys
from datetime import datetime
from influxdb_client import InfluxDBClient, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

################################################################################
# Variables
################################################################################

################################################################################
# Classes
################################################################################

################################################################################
# Functions
################################################################################


def main() -> int:
    """
    Main function

    Returns:
        int: System exit status
    """

    org = "my-org"
    bucket = "my-bucket"
    token = "my-token"

    # establish a connection
    client = InfluxDBClient(url="http://localhost:8086", token=token, org=org)

    # instantiate the WriteAPI and QueryAPI
    write_api = client.write_api(write_options=SYNCHRONOUS)

    logdata = [{"measurement": "Wallbox",
                "fields": {
                    "Inverter-State": 0,
                    "Current-PV-Power": 0,
                    "PV-Energy-total": 0,
                    "BAT_U": 0,
                    "BAT_SOC": 0,
                    "BAT-Power": 0,
                    "AC_Out-U": 0,
                    "AC_Out-Power": 0,
                    "EVSE-State": 0,
                    "EV-State": 0,
                    "EVSE-Current_Power": 0
                },
                "time": datetime.utcnow()}]

    write_api.write(bucket, org, logdata,
                    write_precision=WritePrecision.S)

    return 0

################################################################################
# Main
################################################################################


if __name__ == "__main__":
    sys.exit(main())
