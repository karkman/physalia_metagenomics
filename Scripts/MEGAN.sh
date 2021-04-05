#!/bin/bash
conda activate read_based_env

mkdir READ_BASED

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz 2000000 > READ_BASED/$SAMPLE.fastq

  diamond blastx --query READ_BASED/$SAMPLE.fastq \
                 --db ../DBs/nr \
                 --out READ_BASED/$SAMPLE.txt \
                 --outfmt 0 \
                 --threads 4 &> READ_BASED/$SAMPLE.diamond.log.txt

  ../megan/tools/blast2rma --in READ_BASED/$SAMPLE.txt \
                           --out READ_BASED/$SAMPLE.rma6 \
                           --mapDB ../DBs/megan-map-Jan2021.db \
                           --format BlastText \
                           --threads 4 &> READ_BASED/$SAMPLE.megan.log.txt
done
