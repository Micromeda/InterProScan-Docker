#!/usr/bin/env bash

# Production scrip includes --rm to remove container when done.

ANALYSIS_PATH="$(cd "$(dirname "$1")" || exit; pwd)" # The absolute path of the directory where the input file is
FILENAME=$(basename "$1") # The FASTA file name in the above directory that will be scanned by InterProScan
FILENAME_NO_EXTENSION=$(echo "$FILENAME" | cut -d'.' -f1) # The above file name with .faa or .fasta removed
WORKER_COUNT=$2 # The number of workers for IPR5 to use
JOB_THREAD_COUNT=$3 # The number of threads to use for each job.

echo "Running InterProScan on $FILENAME."
echo

# Check if the number of works and cores per job has been specified.
if [[ "$WORKER_COUNT" -eq 0 ]] || [[ "$JOB_THREAD_COUNT" -eq 0 ]]
then
    # Else, let the shell script inside docker auto-thread the workers and jobs in the container.
    echo "The number of workers and threads per job has not been manually specified. Selecting these automatically..."
    docker run --rm --name interproscan -v "$ANALYSIS_PATH":/run micromeda/interproscan-docker -dp --goterms \
    --pathways -f tsv -o /run/"$FILENAME_NO_EXTENSION".tsv \
    -i /run/"$FILENAME"
else
    # If so, transfer these into container environment variables.
    echo "User has manually specified $WORKER_COUNT workers and $JOB_THREAD_COUNT threads per job."
    docker run --rm --name interproscan --env OVERRIDE_IPR5_WORKERS="$WORKER_COUNT" --env \
    OVERRIDE_IPR5_CORES="$JOB_THREAD_COUNT" -v "$ANALYSIS_PATH":/run micromeda/interproscan-docker -dp --goterms \
    --pathways -f tsv -o /run/"$FILENAME_NO_EXTENSION".tsv \
    -i /run/"$FILENAME"
fi
