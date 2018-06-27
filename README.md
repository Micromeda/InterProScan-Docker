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

#### Improved Parallelism

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

Additionally, you can set per tool's (such as ```hmmsearch```) CPU core usage in the ```interproscan.properties``` file. By default each tool only uses one core.

```
##
## cpu options for parallel processing
##

#hmmer cpu options for the different jobs
hmmer3.hmmsearch.cpu.switch.gene3d=--cpu 1
hmmer3.hmmsearch.cpu.switch.panther=--cpu 1
hmmer3.hmmsearch.cpu.switch.pfama=--cpu 1
hmmer3.hmmsearch.cpu.switch.pirsf=--cpu 1
hmmer3.hmmsearch.cpu.switch.sfld=--cpu 1
hmmer3.hmmsearch.cpu.switch.superfamily=--cpu 1
hmmer3.hmmsearch.cpu.switch.tigrfam=--cpu 1

hmmer3.hmmsearch.cpu.switch.hmmfilter=--cpu 1

hmmer2.hmmpfam.cpu.switch.smart=--cpu 1


#panther binary cpu options (for blastall and hmmsearch)
panther.binary.cpu.switch=-c 1

#pirsf binary cpu options (for hmmscan)
pirsf.pl.binary.cpu.switch=-cpu 1
```

You can mount a custom ```interproscan.properties``` file outside of the container inside of the container using 
```-v $PWD/interproscan.properties:/opt/interproscan/interproscan.properties``` to control CPU usage and other settings. 

```bash
docker run --rm --name interproscan -v $PWD:/run -v $PWD/interproscan.properties:/opt/interproscan/interproscan.properties \
       leebergstrand/interproscan -dp --goterms --pathways -f tsv -o /run/out.ipr \ 
       -i /run/Escherichia_coli_K-12_MG1655_proteome.fasta
```

Through imperical analysis, we have found that setting the worker count to 50% of the server's CPU cores and doubling the core count for each tool provides the best wall time for most analyses. In other words, for an 16 core server set ```maxnumber.of.embedded.workers=8``` and each tool to use two threads (i.e. ```hmmer3.hmmsearch.cpu.switch.gene3d=--cpu 2```).

#### Wrapper Scripts

Two wrapper shell scripts,```run_docker_interproscan.sh``` and ```run_docker_interproscan_high_threads.sh``` , have been included to help simplify using the containerized InterProScan5. Instead of calling docker directly you can simply call the shell script.

```bash
./run_docker_interproscan.sh my_proteins.fasta
```

```run_docker_interproscan_high_threads.sh``` is a modified version of ```run_docker_interproscan.sh``` that mounts a ```interproscan.properties``` file found in the current working directory. This allows for changes to CPU core usage.
