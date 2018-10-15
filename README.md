# InterProScan-Docker
A Dockerfile and associated tools for deploying containerized InterProScan5.

The Dockerfile is based-off the [one used by EBI Metagenomics team](https://github.com/EBI-Metagenomics/InterProScan) 
but it has been modified to enable all InterProScan5 analyses with the exception of SignalP, Phobius, Tmhmm. These are 
excluded as they [require licence agreements](https://github.com/ebi-pf-team/interproscan/wiki/ActivatingLicensedAnalyses).

### Usage:

Standard usage would be to use docker's ```-v``` flag to mount host analysis directories and pass the required 
```interproscan.sh``` flags into the container.

```bash
Usage: docker run --rm --name interproscan -v /tmp:/tmp leebergstrand/InterProScan-Docker -dp --goterms --pathways -f tsv \
                  --appl "PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d" -o /tmp/out.ipr -i /tmp/test.fasta
```

Inside the container ```interproscan.sh``` is called making the above equivalent to:

```bash
interproscan.sh -dp --goterms --pathways -f tsv --appl "PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d" -o /tmp/out.ipr \
                -i /tmp/test.fasta
```