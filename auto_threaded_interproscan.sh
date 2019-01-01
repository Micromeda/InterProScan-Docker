#!/usr/bin/env bash
set -eo pipefail

PATH_TO_INTERPROSCAN_PROPERTIES="./interproscan/interproscan.properties"

NUM_CORES=$(nproc --all)

# Default values for worker and cpu cores per job parameters.
MAX_WORKERS=8
MIN_WORKERS=6
JOB_CORES=1

# Through empirical analysis, we have found that setting the worker count to 50% of the server's CPU cores and doubling
# the core count for each tool provides the best wall time for most analyses. In other words, for an 16 core server set
# ```maxnumber.of.embedded.workers=8``` and each tool to use two threads
# (i.e. ```hmmer3.hmmsearch.cpu.switch.gene3d=--cpu 2```). The code below calculates this.
if [[ ${NUM_CORES} -eq 1 ]]
then
    MAX_WORKERS=1
    MIN_WORKERS=1
    JOB_CORES=1
else
    MAX_WORKERS=${NUM_CORES}

    MAX_WORKERS_DIV=$((${MAX_WORKERS} / 2))

    if [[ ${MAX_WORKERS_DIV} -eq 1 ]]
    then
        JOB_CORES=1
    else
        MAX_WORKERS=$((${MAX_WORKERS} / 2))
        JOB_CORES=$((${NUM_CORES} / ${MAX_WORKERS}))
    fi

    MIN_WORKERS=$((${MAX_WORKERS} / 2))

    if [[ ${MIN_WORKERS} -eq 0 ]]
    then
        MIN_WORKERS=1
    fi
fi

# We can sed new work and job core counts into the default interproscan.properties file.
sed -i -E "s/^number\.of\.embedded\.workers\=[0-9]+/number\.of\.embedded\.workers\=${MIN_WORKERS}/g" ${PATH_TO_INTERPROSCAN_PROPERTIES}
sed -i -E "s/^maxnumber\.of\.embedded\.workers\=[0-9]+/maxnumber\.of\.embedded\.workers\=${MAX_WORKERS}/g" ${PATH_TO_INTERPROSCAN_PROPERTIES}
sed -i -E "s/\=\-\-cpu [0-9]+/=\-\-cpu ${JOB_CORES}/g" ${PATH_TO_INTERPROSCAN_PROPERTIES}
sed -i -E "s/\=\-cpu [0-9]+/=\-cpu ${JOB_CORES}/g" ${PATH_TO_INTERPROSCAN_PROPERTIES}
sed -i -E "s/\=\-c [0-9]+/=\-c ${JOB_CORES}/g" ${PATH_TO_INTERPROSCAN_PROPERTIES}

echo
echo "Adjusting interproscan.properties file to take into account that there is ${NUM_CORES} cores."
echo "Setting max ipr5 workers to ${MAX_WORKERS}."
echo "Setting starting ipr5 workers to ${MIN_WORKERS}."
echo "Setting number if CPU cores for jobs to ${JOB_CORES}."
echo

./interproscan/interproscan.sh $@