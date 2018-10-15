#!/usr/bin/env bash

# Production scrip includes --rm to remove container when done.

echo "Running InterProScan on $1."

docker run --rm --name interproscan -v $PWD:/run leebergstrand/interproscan:latest -dp --goterms --pathways --appl "Pfam,PIRSF,PANTHER,SMART,TIGRFAM,CDD" -f tsv -o /run/out.ipr -i /run/$1
