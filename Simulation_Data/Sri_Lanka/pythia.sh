#!/usr/bin/env bash

module load python-core/3.7
source /blue/hoogenboom/share/apps/test-pythia/.venv/bin/activate
python /blue/hoogenboom/share/apps/test-pythia/pythia $@
