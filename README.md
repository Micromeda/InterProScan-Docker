# InterProScan-Docker
A Dockerfile and associated tools for deploying containerized InterProScan5.

The Dockerfile is based-off the [one used by EBI Metagenomics team](https://github.com/EBI-Metagenomics/InterProScan) 
but it has been modified to enable all InterProScan5 analyses with the exception of SignalP, Phobius, Tmhmm. These are 
excluded as they [require licence agreements](https://github.com/ebi-pf-team/interproscan/wiki/ActivatingLicensedAnalyses).

### Building:

```bash
docker build https://raw.githubusercontent.com/Micromeda/InterProScan-Docker/master/Dockerfile -t micromeda/interproscan-docker
```

### Usage:

Standard usage would be to use docker's ```-v``` flag to mount host analysis directories and pass the required 
```interproscan.sh``` flags into the container.

```bash
Usage: docker run --rm --name interproscan -v /tmp:/tmp micromeda/interproscan-docker -dp --goterms --pathways -f tsv \
                  --appl "PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d" -o /tmp/out.ipr -i /tmp/test.fasta
```

Inside the container ```interproscan.sh``` is called making the above equivalent to:

```bash
interproscan.sh -dp --goterms --pathways -f tsv --appl "PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d" -o /tmp/out.ipr \
                -i /tmp/test.fasta
```

For convenience we have added [```run_docker_interproscan.sh```](https://github.com/Micromeda/InterProScan-Docker/blob/master/run_docker_interproscan.sh) that wraps the above commands. By default, this script will automatically set the number of number of workers and threads per job.

```bash
run_docker_interproscan.sh fasta.faa
```

You can also to manually specify the number of workers and threads per job.

```bash
# run_docker_interproscan.sh <FASTA> [NUMBER OF WORKERS] [NUMBER OF THREADS PER JOB]
run_docker_interproscan.sh fasta.faa 8 2
```
