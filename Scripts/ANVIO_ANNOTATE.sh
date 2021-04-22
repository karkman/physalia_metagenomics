#!/bin/bash
conda activate anvio-7

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  anvi-run-ncbi-cogs --contigs-db BINNING_MEGAHIT/$SAMPLE/CONTIGS.db \
                     --num-threads 4 &> BINNING_MEGAHIT/$SAMPLE.annotate.log.txt

  anvi-run-kegg-kofams --contigs-db BINNING_MEGAHIT/$SAMPLE/CONTIGS.db \
                       --num-threads 4 &>> BINNING_MEGAHIT/$SAMPLE.annotate.log.txt

  anvi-run-pfams --contigs-db BINNING_MEGAHIT/$SAMPLE/CONTIGS.db \
                 --num-threads 4 &>> BINNING_MEGAHIT/$SAMPLE.annotate.log.txt
done
