#!/bin/bash
conda activate read_based_env

mkdir RESAMPLED
mkdir MEGAN
mkdir METAXA

# for loop to run these tools for each of the samples 
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz 2000000 > RESAMPLED/$SAMPLE.R1.fastq
  seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R2.fastq.gz 2000000 > RESAMPLED/$SAMPLE.R2.fastq

  diamond blastx --query RESAMPLED/$SAMPLE.R1.fastq \
                 --out MEGAN/$SAMPLE.blastx.txt \
                 --db ~/Share/DBs/nr \ # their uni downloads this each day
                 --outfmt 0 \
                 --threads 4 > MEGAN/$SAMPLE.diamond.log.txt

  ~/Share/megan/tools/blast2rma --in MEGAN/$SAMPLE.blastx.txt \
                                --out MEGAN/$SAMPLE.rma6 \
                                --mapDB ~/Share/DBs/megan-map-Jan2021.db \ # check which one is the latest version 
                                --format BlastText \
                                --threads 4 > MEGAN/$SAMPLE.megan.log.txt

  metaxa2 -1 RESAMPLED/$SAMPLE.R1.fastq \
          -2 RESAMPLED/$SAMPLE.R2.fastq \
          -o METAXA/$SAMPLE \
          --align none \
          --graphical F \
          --cpu 4 \
          --plus > METAXA/$SAMPLE.metaxa.log.txt

  metaxa2_ttt -i METAXA/$SAMPLE.taxonomy.txt \
              -o METAXA/$SAMPLE >> METAXA/$SAMPLE.metaxa.log.txt
done

# to combine the taxonomy info at genus and species level for all the samples together 
metaxa2_dc -o METAXA/metaxa_genus.txt METAXA/*level_6.txt
metaxa2_dc -o METAXA/metaxa_species.txt METAXA/*level_7.txt
