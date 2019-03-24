#!/usr/bin/env bash

# Production scrip includes --rm to remove container when done.

echo "Running InterProScan on $1."

# Check if the number of works and cores per job has been specified.
if [[ $2 -eq 0 ]] || [[ $3 -eq 0 ]]
then
    # Else, let the shell script inside docker auto-thread the workers and jobs in the container.
    echo "The number of workers and threads per job has not been manually specified. Selecting these automatically."
    docker run --rm --name interproscan -v $PWD:/run micromeda/interproscan-docker -dp --goterms --pathways --appl "Pfam,PIRSF,PANTHER,SMART,TIGRFAM,CDD" -f tsv -o /run/out.ipr -i /run/$1
else
    # If so, transfer these into container environment variables.
    echo "User has manually specified $2 workers and $3 threads per job."
    docker run --rm --name interproscan --env OVERRIDE_IPR5_WORKERS=$2 --env OVERRIDE_IPR5_CORES=$3 -v $PWD:/run micromeda/interproscan-docker -dp --goterms --pathways --appl "Pfam,PIRSF,PANTHER,SMART,TIGRFAM,CDD" -f tsv -o /run/out.ipr -i /run/$1
fi
