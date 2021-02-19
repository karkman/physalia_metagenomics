# Installations for the course

## Virtual environments - miniconda3

Download the installation script from XXX and install miniconda
```
bash ...
```

## Hybrid assembly - OPERA-MS

Create the virtual environment for OPERA-MS
```
conda env create -f opera-ms.yml
```

Activate the environment and install OPERA-MS from Github

```
git clone https://github.com/CSB5/OPERA-MS.git
cd OPERA-MS
make
```

Check dependencies and if everythin is OK, run hybrid assembly on the test data
```
perl OPERA-MS.pl check-dependency
```

Test the assembler
```
cd test_files 
perl ../OPERA-MS.pl \
    --contig-file contigs.fasta \
    --short-read1 R1.fastq.gz \
    --short-read2 R2.fastq.gz \
    --long-read long_read.fastq \
    --no-ref-clustering \
    --out-dir RESULTS 2> log.err
```

If it works, download a precomputed reference genome DB (requires 35 Gb of free space). 
```
perl OPERA-MS.pl install-db
```
