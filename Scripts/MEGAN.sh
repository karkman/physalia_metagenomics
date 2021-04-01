#!/bin/bash
conda activate megan

mkdir MEGAN

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz 2000000 > MEGAN/$SAMPLE.fastq

  diamond blastx --query MEGAN/$SAMPLE.fastq \
                 --db $DIAMONDDB/nr \
                 --out MEGAN/$SAMPLE.txt \
                 --outfmt 0 \
                 --threads 4 &> MEGAN/$SAMPLE.diamond.log.txt

  ../megan/tools/blast2rma --in MEGAN/$SAMPLE.txt \
                           --out MEGAN/$SAMPLE.rma6 \
                           --mapDB ../DBs/megan-map-Jan2021.db \
                           --format BlastText \
                           --threads 4 &> MEGAN/$SAMPLE.megan.log.txt
done
