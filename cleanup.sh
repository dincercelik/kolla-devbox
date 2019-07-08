#!/bin/bash

set -e

vagrant destroy -f && \
rm -rf {.vagrant,workspace,*.log}
