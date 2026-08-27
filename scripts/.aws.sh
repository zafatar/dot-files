#!/bin/bash

# Resolve this script's own directory. Under zsh (how .zshrc sources this file)
# ${(%):-%x} is the path of the file being sourced and :A:h resolves the
# ~/.aws.sh symlink down to the real scripts/ directory - all in-process. The
# previous `readlink -f` + `dirname` + `cd`/`pwd -P` version cost four forks on
# every shell start. The else branch keeps the file usable from bash.
if [ -n "${ZSH_VERSION}" ]; then
    SCRIPT_DIR="${${(%):-%x}:A:h}"
else
    SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]:-$0}")"
    SCRIPT_DIR="$( cd -- "$( dirname -- "${SCRIPT_PATH}" )" &> /dev/null && pwd -P )"
fi

# Source EC2-related functions
source "${SCRIPT_DIR}/.aws_ec2.sh"

# Source S3-related functions
source "${SCRIPT_DIR}/.aws_s3.sh"
