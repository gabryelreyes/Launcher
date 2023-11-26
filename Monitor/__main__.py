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
import json
from datetime import datetime
from influxdb_client import InfluxDBClient, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS
import paho.mqtt.subscribe as subscribe

################################################################################
# Constants
################################################################################

# InfluxDB constants
# These should not be changed if using the default Launcher Project configuration.
# If using a custom configuration, these should match the configuration.
org = "my-org"  # organization with write access
bucket = "my-bucket"  # bucket with write access
token = "my-token"  # token with write access
write_precision = WritePrecision.MS  # milliseconds
url = "http://localhost:8086"  # InfluxDB server URL

################################################################################
# Variables
################################################################################

# MQTT topics list to subscribe to
project_topics = ["zumo_1/pid"]

################################################################################
# Classes
################################################################################

################################################################################
# Functions
################################################################################


def topic_callback(client, userdata, message) -> None:
    """
    Callback function for subscribed topics.

    """

    # Pack data
    logdata = [{"measurement": message.topic,
                "fields": json.loads(message.payload),
                "time": datetime.utcnow()}]

    # Write data to InfluxDB
    # write_api passed to callback function as userdata
    write_api = userdata
    write_api.write(bucket, org, logdata,
                    write_precision=write_precision)

    # Print data to console
    print(logdata)


def main() -> int:
    """
    Main function

    Returns:
        int: System exit status
    """

    # establish a connection to the InfluxDB server
    client = InfluxDBClient(url=url, token=token, org=org)

    # instantiate the WriteAPI and QueryAPI
    write_api = client.write_api(write_options=SYNCHRONOUS)

    # Subscribe to topics
    # write_api passed to callback function as userdata
    subscribe.callback(topic_callback, project_topics, userdata=write_api)

    while (True):
        ...

    return 0

################################################################################
# Main
################################################################################


if __name__ == "__main__":
    sys.exit(main())
