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
rm -rf tmp/var/* tmp/run/*
rm -rf ~/.singularity/cache/
rm -rf ~/.singularity/
# sudo rm -rf /root/.singularity/
singularity shell \
    --nv \
    -B tmp/var:/var,tmp/run:/run \
    simulation.sif

# do i need     --writable-tmpfs \


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

# start run in minknow (can leave basecalling off)



# TEST UNBLOCK
# WORKS in ubuntu 18.04 image with readfish 77c11e2
readfish unblock-all \
    --device MN30649 \
    --experiment-name "Testing ReadFish Unblock All"

# works up to readfish point
# readfish 0.0.5a3 has an error about the --cache parameter
# readfish from the tidy branch (commit 77c11e2) doesn't install pyguppyclient properly

# TEST MINIMAP
# start a guppy server (does it work inside container?)
nohup bash -c \
    'guppy_basecall_server   \
    --port 5557   \
    --log_path guppy_server_log \
    --flowcell "FLO-MIN106" \
    --kit "SQK-LSK109" \
    --device "cuda:0" ' \
    &> /var/guppy_server.log &    

# index the human genome, wtf?
minimap2 -x map-ont -d data/reference.mmi data/GRCh38_latest_genomic.fna

# check the toml file
readfish validate toml/human_chr_selection.toml

# try read until
# WORKS! but way too slow
# 2020-10-20 16:31:10,674 ru.ru_gen 48R/0.47153s
# 2020-10-20 16:31:11,787 ru.ru_gen 71R/1.11320s
# 2020-10-20 16:31:13,672 ru.ru_gen 142R/1.88378s
# 2020-10-20 16:31:15,332 ru.ru_gen 156R/1.65936s
# 2020-10-20 16:31:17,089 ru.ru_gen 159R/1.75595s
# 2020-10-20 16:31:18,910 ru.ru_gen 158R/1.81971s
# 2020-10-20 16:31:20,893 ru.ru_gen 160R/1.98052s
# 2020-10-20 16:31:23,004 ru.ru_gen 157R/2.10987s
# 2020-10-20 16:31:25,203 ru.ru_gen 157R/2.19829s
# 2020-10-20 16:31:28,259 ru.ru_gen 164R/3.05491s
# 2020-10-20 16:31:31,521 ru.ru_gen 162R/3.26116s
# 2020-10-20 16:31:35,626 ru.ru_gen 162R/4.10308s
# 2020-10-20 16:31:39,873 ru.ru_gen 162R/4.24531s
# 2020-10-20 16:31:44,415 ru.ru_gen 134R/4.54154s
# 2020-10-20 16:31:52,295 ru.ru_gen 145R/7.87831s
readfish targets \
    --device MN30649 \
    --experiment-name "RU Test basecall and map" \
    --toml toml/human_chr_selection.toml \
    --log-file /var/ru_test.log


# change model to fast -> works better
# performance gradually degrades. need to try a faster setup
# 2020-10-20 16:38:00,086 ru.ru_gen 45R/0.22684s
# 2020-10-20 16:38:00,505 ru.ru_gen 47R/0.24472s
# 2020-10-20 16:38:00,946 ru.ru_gen 56R/0.28537s
# 2020-10-20 16:38:01,320 ru.ru_gen 49R/0.25801s
# 2020-10-20 16:38:01,847 ru.ru_gen 67R/0.38474s
# 2020-10-20 16:38:02,044 ru.ru_gen 25R/0.18057s
# 2020-10-20 16:38:02,542 ru.ru_gen 59R/0.27796s
# 2020-10-20 16:38:02,900 ru.ru_gen 43R/0.23589s
# 2020-10-20 16:38:03,301 ru.ru_gen 40R/0.23518s
# 2020-10-20 16:38:03,799 ru.ru_gen 57R/0.33295s
# 2020-10-20 16:38:04,080 ru.ru_gen 33R/0.21257s
# 2020-10-20 16:38:04,512 ru.ru_gen 47R/0.24469s
# 2020-10-20 16:38:05,026 ru.ru_gen 46R/0.35670s
# 2020-10-20 16:38:05,338 ru.ru_gen 58R/0.26815s
# 2020-10-20 16:38:05,751 ru.ru_gen 48R/0.28014s
# 2020-10-20 16:38:06,067 ru.ru_gen 30R/0.19581s
# 2020-10-20 16:38:06,505 ru.ru_gen 40R/0.23340s
# 2020-10-20 16:38:06,973 ru.ru_gen 52R/0.30009s
# 2020-10-20 16:38:07,292 ru.ru_gen 39R/0.21826s
# 2020-10-20 16:38:07,801 ru.ru_gen 61R/0.32724s
# 2020-10-20 16:38:08,068 ru.ru_gen 26R/0.19329s
# 2020-10-20 16:38:08,687 ru.ru_gen 55R/0.41134s
# 2020-10-20 16:38:08,983 ru.ru_gen 44R/0.29496s
# 2020-10-20 16:38:09,309 ru.ru_gen 38R/0.22035s
# 2020-10-20 16:38:09,815 ru.ru_gen 54R/0.32522s
# 2020-10-20 16:38:10,123 ru.ru_gen 38R/0.23294s
# 2020-10-20 16:38:10,526 ru.ru_gen 35R/0.23459s
# 2020-10-20 16:38:11,021 ru.ru_gen 49R/0.32931s
# 2020-10-20 16:38:11,344 ru.ru_gen 40R/0.25104s
# 2020-10-20 16:38:11,809 ru.ru_gen 50R/0.31448s
# 2020-10-20 16:38:12,096 ru.ru_gen 28R/0.20125s
# 2020-10-20 16:38:12,627 ru.ru_gen 55R/0.33121s


# basecall the reads (from outside)
singularity exec \
    --nv \
    simulation.sif \
    guppy_basecaller_supervisor \
    --port 5557 \
    --num_clients 5 \
    --input_path tmp/var/lib/minknow/data/RU_Test_basecall_and_map/NOTT_Hum_wh1rs2_60428/ \
    --save_path "basecalled/RU_Test_basecall_and_map" \
    --flowcell "FLO-MIN106" \
    --kit "SQK-LSK109" \
    --verbose_logs \
    --recursive \
    --trim_strategy dna \
    --qscore_filtering 

singularity exec \
    --nv \
    -B tmp/var:/var,tmp/run:/run \
    simulation.sif \
    readfish summary \
    toml/human_chr_selection.toml \
    basecalled/RU_Test_basecall_and_map

# 1 GB singularity overlay?
# THIS WORKS
mkdir -p overlay/upper overlay/work
dd if=/dev/zero of=overlay.img bs=1M count=1000
mkfs.ext3 -d overlay overlay.img
singularity shell \
    --nv \
    --overlay overlay.img \
    -B tmp/var:/var,tmp/run:/run \
    readfish_77c11e2.sif

# put the modified TOML in place
cp toml/sequencing_MIN106_DNA.core4.toml \
    /opt/ont/minknow/conf/package/sequencing/sequencing_MIN106_DNA.toml

# restore ONT's copy
cp toml/sequencing_MIN106_DNA.ont_default.toml \
    /opt/ont/minknow/conf/package/sequencing/sequencing_MIN106_DNA.toml

# is it the pycache directory? dunno, it's not there when running without
# persistent overlay
singularity shell \
    --nv \
    --writable-tmpfs \
    -B tmp/var:/var,tmp/run:/run \
    readfish_77c11e2.sif
