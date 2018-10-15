#!/usr/bin/env bash

PATH_TO_INTERPROSCAN_PROPERTIES="./interproscan/interproscan.properties"

NUM_CORES=$(nproc --all)

# Default values for worker and cpu cores per job parameters.
MAX_WORKERS=8
MIN_WORKERS=6
JOB_CORES=1

# We found that, imperially, that running two threads per worker and half as many workers was faster than running
# one job thread per worker and a full number of workers. The code below calculates this.
if [ ${NUM_CORES} -eq 1 ]
then
    MAX_WORKERS=1
    MIN_WORKERS=1
    JOB_CORES=1
else
    MAX_WORKERS=${NUM_CORES}

    MAX_WORKERS_DIV=$((${MAX_WORKERS} / 2))

    if [ ${MAX_WORKERS_DIV} -eq 1 ]
    then
        JOB_CORES=1
    else
        MAX_WORKERS=$((${MAX_WORKERS} / 2))
        JOB_CORES=$((${NUM_CORES} / ${MAX_WORKERS}))
    fi

    MIN_WORKERS=$((${MAX_WORKERS} / 2))

    if [ ${MIN_WORKERS} -eq 0 ]
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

echo "Setting max ipr5 workers to ${MAX_WORKERS}."
echo "Setting starting ipr5 workers to ${MIN_WORKERS}."
echo "Setting number if CPU cores for jobs to ${JOB_CORES}."

./interproscan/interproscan.sh $@