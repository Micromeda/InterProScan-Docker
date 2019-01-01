# Created by: Lee Bergstrand 2018
#
# Discription:  A Dockerfile for building a container containing InterProScan5. It is based-off the Dockerfile used by
#               EBI Metagenomics team (https://github.com/EBI-Metagenomics/InterProScan) but has been modified to
#               provide code and data for all InterProScan5 analyses with the exception of SignalP, Phobius, Tmhmm.
#               These are exluded as they require licence agreements
#               (https://github.com/ebi-pf-team/interproscan/wiki/ActivatingLicensedAnalyses).
#
# Building: docker build https://raw.githubusercontent.com/Micromeda/InterProScan-Docker/master/Dockerfile -t micromeda/interproscan-docker
#
# Usage: docker run --rm --name interproscan -v /tmp:/tmp micromeda/interproscan-docker -dp --goterms --pathways -f tsv
#                   --appl "PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d" -o /tmp/out.ipr -i /tmp/test.fasta


FROM openjdk:8

MAINTAINER Lee Bergstrand

ARG IPR=5
ENV IPR $IPR
ENV IPRSCAN "$IPR.27-66.0"

RUN mkdir -p /opt

# Download Interproscan
RUN curl -o /opt/interproscan-$IPRSCAN-64-bit.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/interproscan-$IPRSCAN-64-bit.tar.gz
RUN curl -o /opt/interproscan-$IPRSCAN-64-bit.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/interproscan-$IPRSCAN-64-bit.tar.gz.md5

# Download Panther data.
RUN curl -o /opt/panther-data-12.0.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/data/panther-data-12.0.tar.gz
RUN curl -o /opt/panther-data-12.0.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/data/panther-data-12.0.tar.gz.md5

WORKDIR /opt

# Install InterProScan5.
RUN md5sum -c interproscan-$IPRSCAN-64-bit.tar.gz.md5

RUN mkdir -p /opt/interproscan

RUN  tar -pxvzf interproscan-$IPRSCAN-64-bit.tar.gz \
    --exclude="interproscan-$IPRSCAN/data/phobius" \
    --exclude="interproscan-$IPRSCAN/data/tmhmm" \
    -C /opt/interproscan --strip-components=1

RUN rm -f interproscan-$IPRSCAN-64-bit.tar.gz interproscan-$IPRSCAN-64-bit.tar.gz.md5

# Install Panther Data.
RUN md5sum -c panther-data-12.0.tar.gz.md5

RUN tar -pxvzf panther-data-12.0.tar.gz -C /opt/interproscan/data

RUN rm -f panther-data-12.0.tar.gz panther-data-12.0.tar.gz.md5

# The packaged rpsblast needs libgomp1.
RUN apt-get update && apt-get -y install libgomp1 && rm -rf /var/lib/apt/lists/*

# The rpsblast packaged with this InterProScan5 release was compiled pointing to 
# the libgnutls28 DLL, this container has the libgnutls30 DLL causing a runtime error.
# The latest rpsblast from EBI was compiled with libgnutls30. Use this instead.
# See: https://qiita.com/okuman/items/73bebfd711d3f955c167 (Caution Japanese)
RUN wget ftp://ftp.ebi.ac.uk/pub/databases/interpro/iprscan/5/bin/rh6/rpsblast_binary.zip && unzip rpsblast_binary.zip && rm rpsblast_binary.zip
RUN mv rpsblast ./interproscan/bin/blast/ncbi-blast-2.6.0+/
RUN mv rpsbproc ./interproscan/bin/blast/ncbi-blast-2.6.0+/

ARG github_branch=master
ADD https://raw.githubusercontent.com/Micromeda/InterProScan-Docker/${github_branch}/run_auto_threaded_interproscan.sh ./interproscan/

ENTRYPOINT ["/bin/bash", "interproscan/auto_threaded_interproscan.sh"]
