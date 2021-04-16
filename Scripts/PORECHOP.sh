#!/bin/bash
conda activate QC_env

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  porechop -i RAWDATA/$SAMPLE.NANOPORE.fastq.gz \
           -o TRIMMED/$SAMPLE.NANOPORE.fastq.gz \
           --discard_middle \
           --threads 4 > TRIMMED/$SAMPLE.porechop.log.txt
done
