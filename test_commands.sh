#!/usr/bin/env bash

set -eux

# testing only! mount the reads directory, e.g.
sshfs -o ro host:/path data/reads

# open the shell
singularity shell \
	--writable-tmpfs \
	--nv \
	-B tmp/var:/var,tmp/run:/run \
	readfish_0.0.5a_py3.7.sif

# launch the gui
nohup bash -c \
	'/opt/ont/minknow/bin/mk_manager_svc & 
	/opt/ont/ui/kingfisher/MinKNOW' &> /var/ui.log &


# launch a guppy server (to test)
nohup guppy_basecall_server   \
    --port 5555   \
    --log_path /var/guppy_server   \
    --config /opt/ont/guppy/data/dna_r9.4.1_450bps_hac.cfg \
    --device "cuda:0" \
    &> /var/guppy_server.log &

# edit /opt/ont/minknow/conf/package/sequencing/sequencing_MIN106_DNA.toml
# /home/tom/Projects/readfish-test/data/reads/FAL06258_67bb20e2_42.fast5
cp  \
	sequencing_MIN106_DNA.toml \
	/opt/ont/minknow/conf/package/sequencing/

# check it
cat /opt/ont/minknow/conf/package/sequencing/sequencing_MIN106_DNA.toml