#!/bin/bash
conda activate assembly_env

for SAMPLE in Sample03 Sample04; do
  bowtie2-build ASSEMBLY_METAFLYE/$SAMPLE/assembly.fasta \
                ASSEMBLY_METAFLYE/$SAMPLE/assembly > ASSEMBLY_METAFLYE/$SAMPLE.pilon.log.txt

  bowtie2 -1 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz \
          -2 TRIMMED/$SAMPLE.NOVASEQ.R2.fastq.gz \
          -S ASSEMBLY_METAFLYE/$SAMPLE/$SAMPLE.sam \
          -x ASSEMBLY_METAFLYE/$SAMPLE/assembly \
          --threads 20 \
          --no-unal >> ASSEMBLY_METAFLYE/$SAMPLE.pilon.log.txt

  samtools view -F 4 -bS ASSEMBLY_METAFLYE/$SAMPLE/$SAMPLE.sam | samtools sort > ASSEMBLY_METAFLYE/$SAMPLE/$SAMPLE.bam
  samtools index ASSEMBLY_METAFLYE/$SAMPLE/$SAMPLE.bam

  java -Xmx128G -jar ~/Share/pilon-1.23.jar --genome ASSEMBLY_METAFLYE/$SAMPLE/assembly.fasta \
                                            --bam ASSEMBLY_METAFLYE/$SAMPLE/$SAMPLE.bam \
                                            --outdir ASSEMBLY_METAFLYE/$SAMPLE \
                                            --output pilon \
                                            --threads 4 \
                                            --changes >> ASSEMBLY_METAFLYE/$SAMPLE.pilon.log.txt
done
