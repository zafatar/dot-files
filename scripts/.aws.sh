#!/bin/bash

SCRIPT_PATH="$(readlink -f "$0")"

SCRIPT_DIR="$( cd -- "$( dirname -- "${SCRIPT_PATH}" )" &> /dev/null && pwd -P )"

# Source EC2-related functions
source "${SCRIPT_DIR}/.aws_ec2.sh"

# Source S3-related functions
source "${SCRIPT_DIR}/.aws_s3.sh"