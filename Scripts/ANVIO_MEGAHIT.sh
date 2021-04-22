#!/bin/bash
mkdir BINNING_MEGAHIT

for ASSEMBLY in Sample01 Sample02 Sample03 Sample04; do
  mkdir BINNING_MEGAHIT/$ASSEMBLY
  mkdir BINNING_MEGAHIT/$ASSEMBLY/MAPPING
  mkdir BINNING_MEGAHIT/$ASSEMBLY/PROFILES

  anvi-script-reformat-fasta ASSEMBLY_MEGAHIT/$ASSEMBLY/final.contigs.fa \
                             --output-file BINNING_MEGAHIT/$ASSEMBLY/CONTIGS_5000nt.fa \
                             --report-file BINNING_MEGAHIT/$ASSEMBLY/CONTIGS_reformat.txt \
                             --prefix $ASSEMBLY \
                             --min-len 5000 \
                             --simplify-names &> BINNING_MEGAHIT/$ASSEMBLY.reformat.log.txt

  anvi-gen-contigs-database --contigs-fasta BINNING_MEGAHIT/$ASSEMBLY/CONTIGS_5000nt.fa \
                            --output-db-path BINNING_MEGAHIT/$ASSEMBLY/CONTIGS.db \
                            --project-name $ASSEMBLY \
                            --num-threads 4 &> BINNING_MEGAHIT/$ASSEMBLY.contigsdb.log.txt

  anvi-run-hmms --contigs-db BINNING_MEGAHIT/$ASSEMBLY/CONTIGS.db \
                --num-threads 4 &> BINNING_MEGAHIT/$ASSEMBLY.hmms.log.txt

  anvi-run-scg-taxonomy --contigs-db BINNING_MEGAHIT/$ASSEMBLY/CONTIGS.db \
                        --num-threads 4 &> BINNING_MEGAHIT/$ASSEMBLY.scgtax.log.txt

  bowtie2-build BINNING_MEGAHIT/$ASSEMBLY/CONTIGS_5000nt.fa \
                BINNING_MEGAHIT/$ASSEMBLY/MAPPING/contigs &> BINNING_MEGAHIT/$ASSEMBLY.bowtie.log.txt

  for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
    bowtie2 -1 RAWDATA/$SAMPLE.NOVASEQ.R1.fastq.gz \
            -2 RAWDATA/$SAMPLE.NOVASEQ.R2.fastq.gz \
            -S BINNING_MEGAHIT/$ASSEMBLY/MAPPING/$SAMPLE.sam \
            -x BINNING_MEGAHIT/$ASSEMBLY/MAPPING/contigs \
            --threads 4 \
            --no-unal

    samtools view -F 4 -bS BINNING_MEGAHIT/$ASSEMBLY/MAPPING/$SAMPLE.sam | samtools sort > BINNING_MEGAHIT/$ASSEMBLY/MAPPING/$SAMPLE.bam
    samtools index BINNING_MEGAHIT/$ASSEMBLY/MAPPING/$SAMPLE.bam
  done &>> BINNING_MEGAHIT/$ASSEMBLY.bowtie.log.txt

  for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
    anvi-profile --input-file BINNING_MEGAHIT/$ASSEMBLY/MAPPING/$SAMPLE.bam \
                 --output-dir BINNING_MEGAHIT/$ASSEMBLY/PROFILES/$SAMPLE \
                 --contigs-db BINNING_MEGAHIT/$ASSEMBLY/CONTIGS.db \
                 --num-threads 4
  done &> BINNING_MEGAHIT/$ASSEMBLY.profilesdb.log.txt

  anvi-merge BINNING_MEGAHIT/$ASSEMBLY/PROFILES/*/PROFILE.db \
             --output-dir BINNING_MEGAHIT/$ASSEMBLY/MERGED_PROFILES \
             --contigs-db BINNING_MEGAHIT/$ASSEMBLY/CONTIGS.db \
             --enforce-hierarchical-clustering &> BINNING_MEGAHIT/$ASSEMBLY.merge.log.txt
done
