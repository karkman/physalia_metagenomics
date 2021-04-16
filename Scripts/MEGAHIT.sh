#!/bin/bash
conda activate assembly_env

mkdir ASSEMBLY_MEGAHIT

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
	megahit -1 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz \
          -2 TRIMMED/$SAMPLE.NOVASEQ.R2.fastq.gz \
          --out-dir ASSEMBLY_MEGAHIT/$SAMPLE \
          --min-contig-len 1000 \
          --k-min 27 \
          --k-max 127 \
          --k-step 10 \
          --memory 0.8 \
          --num-cpu-threads 4 > ASSEMBLY_MEGAHIT/$SAMPLE.megahit.log.txt
done
