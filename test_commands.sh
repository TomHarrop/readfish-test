#!/usr/bin/env bash

set -eux

# testing only! mount the reads directory, e.g.
sshfs -o ro host:/path data/reads

# open the shell
# add the following to troubleshoot?
#     -B toml:/opt/ont/minknow/conf/package/sequencing \

singularity shell \
    --writable-tmpfs \
    --nv \
    -B tmp/var:/var,tmp/run:/run \
    readfish_14ddf60.sif


# something is happening with the singularity filesystem overlay. When I run
# MinKNOW once inside the container, it won't detect the changes to the .toml
# file. The only way I can get it to detect them is to add the toml file in a new
# container, reboot the system and run again.
find /tmp -iname "*minknow*" -type f
rm -rf ~/.singularity/cache/
rm -rf ~/.singularity/
# sudo rm -rf /root/.singularity/
singularity shell \
    --writable-tmpfs \
    --nv \
    -B tmp/var:/var,tmp/run:/run \
    simulation.sif


# launch the gui
nohup bash -c \
    '/opt/ont/minknow/bin/mk_manager_svc & 
    /opt/ont/ui/kingfisher/MinKNOW' &> /var/ui.log &

# old version < 20
nohup bash -c \
    '/opt/ont/minknow/bin/mk_manager_svc &
    /opt/ont/minknow-ui/MinKNOW' &> /var/ui.log &


# launch a guppy server (to test)
nohup guppy_basecall_server   \
    --port 5555   \
    --log_path /var/guppy_server   \
    --config /opt/ont/guppy/data/dna_r9.4.1_450bps_hac.cfg \
    --device "cuda:0" \
    &> /var/guppy_server.log &


# old version (3.4.5)
nohup /guppy/bin/guppy_basecall_server   \
    --port 5555   \
    --log_path /var/guppy_server   \
    --config /guppy/data/dna_r9.4.1_450bps_hac.cfg \
    --device "cuda:0" \
    &> /var/guppy_server.log &



# edit /opt/ont/minknow/conf/package/sequencing/sequencing_MIN106_DNA.toml
# /home/tom/Projects/readfish-test/data/reads/FAL06258_67bb20e2_42.fast5
cp  \
    toml/sequencing_MIN106_DNA.toml \
    /opt/ont/minknow/conf/package/sequencing/

# check it
cat /opt/ont/minknow/conf/package/sequencing/sequencing_MIN106_DNA.toml