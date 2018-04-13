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

ENTRYPOINT ["/bin/bash", "interproscan/interproscan.sh"]

# Example CMD
# docker run --rm --name interproscan -v /tmp:/tmp olat/interproscan-metagenomics -dp --goterms --pathways -f tsv --appl "PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d" -o /tmp/out.ipr -i /tmp/test.fasta
