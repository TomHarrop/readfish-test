#!/usr/bin/env bash

set -eux

# open the shell
singularity shell \
	--writable-tmpfs \
	--nv \
	-B tmp/var:/var,tmp/run:/run \
	readfish_0.0.5a.sif

# launch the gui
nohup /opt/ont/ui/kingfisher/MinKNOW &> /var/ui.log &


# launch a guppy server (to test)
nohup guppy_basecall_server   \
    --port 5555   \
    --log_path /var/guppy_server   \
    --config /opt/ont/guppy/data/dna_r9.4.1_450bps_hac.cfg \
    --device "cuda:0" \
    &> /var/guppy_server.log &






