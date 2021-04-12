#!/bin/bash
conda activate QC_env

mkdir TRIMMED

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  cutadapt RAWDATA/$SAMPLE.NOVASEQ.R1.fastq.gz \
           RAWDATA/$SAMPLE.NOVASEQ.R2.fastq.gz \
           -o TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz \
           -p TRIMMED/$SAMPLE.NOVASEQ.R2.fastq.gz \
           -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC \
           -A CTGTCTCTTATACACATCTGACGCTGCCGACGA \
           -m 50 \
           -j 4 \
           --nextseq-trim 20 > TRIMMED/$SAMPLE.cutadapt.log.txt
done
