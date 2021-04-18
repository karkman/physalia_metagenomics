#!/bin/bash
conda activate assembly_env

mkdir ASSEMBLY_METAFLYE

for SAMPLE in Sample03 Sample04; do
  flye --nano-raw TRIMMED/$SAMPLE.NANOPORE.fastq.gz \
       --out-dir ASSEMBLY_METAFLYE/$SAMPLE \
       --threads 4 \
       --meta &> ASSEMBLY_METAFLYE/$SAMPLE.metaflye.log.txt
done
