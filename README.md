# InterProScan-Docker
A Dockerfile and associated tools for deploying containerized InterProScan5.

The Dockerfile is based-off the [one used by EBI Metagenomics team](https://github.com/EBI-Metagenomics/InterProScan) 
but has been modified to enable all InterProScan5 analyses with the exception of SignalP, Phobius, Tmhmm. These are 
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

InterProScan5 uses a configuration file called ```interproscan.properties``` to configure such things as [CPU and memory 
usage](https://github.com/ebi-pf-team/interproscan/wiki/ImprovingPerformance).

The default ```interproscan.properties``` file has CPU usage set to 8 cores.

```
# Set the number of embedded workers to the number of processors that you would like to employ
# on the machine you are using to run InterProScan. The number of embedded workers a master process
# can have.
number.of.embedded.workers=6
maxnumber.of.embedded.workers=8
```

You can mount a custom ```interproscan.properties``` file outside of the container inside of the container using 
```-v $PWD/interproscan.properties:/opt/interproscan/interproscan.properties``` to control CPU usage and other settings. 

```bash
docker run --rm --name interproscan -v $PWD:/run -v $PWD/interproscan.properties:/opt/interproscan/interproscan.properties \
       leebergstrand/interproscan -dp --goterms --pathways -f tsv -o /run/out.ipr \ 
       -i /run/Escherichia_coli_K-12_MG1655_proteome.fasta
```