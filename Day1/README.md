# Day 1

| Time      | Activity                          | Slides                                         | Hands-on                                    |
|-----------|-----------------------------------|------------------------------------------------|---------------------------------------------|
| Morning   | Course outline and practical info | [Link here](course-outline.pptx)               |                                             |
| Morning   | Introduction to metagenomics      | [Link here](introduction-to-metagenomics.pdf)  |                                             |
| Morning   | Working with the command line     | [Link here](working-with-the-command-line.pdf) | [Link here](#working-with-the-command-line) |
| Afternoon | QC and trimming                   | [Link here](QC-and-trimming.pdf)               | [Link here](#qc-and-trimming)               |
| Afternoon | Read-based analyses (Part 1)      | [Link here](read-based-analyses-1.pdf)         | [Link here](#read-based-analyses)           |

## Working with the command line

Most of our activities will be done using the Unix command line (aka Unix shell).  
It is thus highly recommend to have at least a basic grasp of how to get around in the Unix shell.  
We will now dedicate one hour or so to follow an online tutorial to learn (or refresh) the basics of the Unix shell.  
Click [here](https://www.codecademy.com/learn/learn-the-command-line) to go the Codeacademy course "Learn the command line".

## QC and trimming

**This is my idea on how things will go**

- Connect to the server
- Create a directory for you

```bash
mkdir $USER
cd $USER
```
- Clone this repository (for scripts)

```bash
git clone https://github.com/karkman/physalia_metagenomics
```

- Raw data is already there in the server (folder RAWDATA)
- Run Cutadapt

```bash
bash physalia_metagenomics/Scripts/CUTADAPT.sh
```

**Alternatively, they will get the scripts from GitHub and type/copy+paste directly in the terminal?**


## Read-based analyses

We will launch the scripts for the read-based analyses now so that everything is (hopefully) finished in time for tomorrow morning.  

- Connect to the server
- Go to your directory
- Open a "screen" so you can leave things running overnight:

```bash
screen -S megan
```

- Take a look at the script using less:

```bash
less physalia_metagenomics/Scripts/MEGAN.sh

# #!/bin/bash
# conda activate read_based_env
# 
# mkdir READ_BASED
#
# for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
#   seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz 2000000 > READ_BASED/$SAMPLE.fastq
#
#   diamond blastx --query READ_BASED/$SAMPLE.fastq \
#                  --db ../DBs/nr \
#                  --out READ_BASED/$SAMPLE.txt \
#                  --outfmt 0 \
#                  --threads 4 &> READ_BASED/$SAMPLE.diamond.log.txt
#
#   ../megan/tools/blast2rma --in READ_BASED/$SAMPLE.txt \
#                            --out READ_BASED/$SAMPLE.rma6 \
#                            --mapDB ../DBs/megan-map-Jan2021.db \
#                            --format BlastText \
#                            --threads 4 &> READ_BASED/$SAMPLE.megan.log.txt
# done
```

- Run the script:
```bash
bash physalia_metagenomics/Scripts/MEGAN.sh
```

- Close the screen with Ctrl+a+d
