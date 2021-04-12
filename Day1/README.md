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

## Set-up

### Github repository

All course material can be found from the course [Github repository](https://github.com/karkman/physalia_metagenomics).
You can follow it through the website, but you can also copy it to your own computer. 

```
cd /PATH/WHERE/YOU/WANT/THE/FOLDER
git clone https://github.com/karkman/physalia_metagenomics.git
```

We might update thei repository during the course. To get the latest updates, pull the changes from Github.  

```bash
git pull origin main
```

### Connecting to the server

For most of the analyses we will use Amazon cloud computing.  
The address will change every day and we will provide it each day. Your username will be the same for the whole course. 
Use `ssh` or any other ssh client to connect to the server.

```bash
ssh -i envmeta.pem USER@ip-address
```

When you have connecter to the server, you see your home folder. Copy the course repository also there.
After copying the course folder, make a folder for the raw data. The raw data will be in stored only in one place (to save disk space) and you will only softlink them. 

```bash
cd raw_data
ln -s PATH/TO/FILES/*fastq.gz .
```

## QC and trimming
Now we should have softlinks to the data and can start the QC and trimming.   
We will use `FastQC`and `MultiQC` for the QC and `cutadapt` for the trimming.  
Go to the raw data folder and create a folder for the QC files.   

```bash
cd raw_data
mkdir FASTQC
```

Then we are ready to run QC omn the raw data. Most of the programs are preinstalled on the server in [conda](https://docs.conda.io/projects/conda/en/latest/index.html) virtual environemnts. You only need to activate the virtuasl enviroment. 

```bash
conda activate QC_env
fastqc *.fastq.gz -o FASTQC -t 4
multiqc FASTQC/* -o FASTQC -n raw_QC
```

After QC is finished, copy the multiqc report (`raw_QC.html`) to your local machine and open it with your favourite browser.  
We will go thru the report together before doing any trimming.

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
screen -S read_based
```

- Take a look at the script using less:

```bash
less physalia_metagenomics/Scripts/READ_BASED.sh

# #!/bin/bash
# conda activate read_based_env
#
# mkdir RESAMPLED
# mkdir MEGAN
# mkdir METAXA
#
# for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
#   seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R1.fastq.gz 2000000 > RESAMPLED/$SAMPLE.R1.fastq
#   seqtk sample -s100 TRIMMED/$SAMPLE.NOVASEQ.R2.fastq.gz 2000000 > RESAMPLED/$SAMPLE.R2.fastq
#
#   diamond blastx --query RESAMPLED/$SAMPLE.R1.fastq \
#                  --out MEGAN/$SAMPLE.blastx.txt \
#                  --db ../DBs/nr \
#                  --outfmt 0 \
#                  --threads 4 &> MEGAN/$SAMPLE.diamond.log.txt
#
#   ../megan/tools/blast2rma --in MEGAN/$SAMPLE.blastx.txt \
#                            --out MEGAN/$SAMPLE.rma6 \
#                            --mapDB ../DBs/megan-map-Jan2021.db \
#                            --format BlastText \
#                            --threads 4 &> MEGAN/$SAMPLE.megan.log.txt
#
#   metaxa2 -1 RESAMPLED/$SAMPLE.R1.fastq \
#           -2 RESAMPLED/$SAMPLE.R2.fastq \
#           -o METAXA/$SAMPLE \
#           --align none \
#           --graphical F \
#           --cpu 4 \
#           --plus &> METAXA/$SAMPLE.metaxa.log.txt
#
#   metaxa2_ttt -i METAXA/$SAMPLE.taxonomy.txt \
#               -o METAXA/$SAMPLE &>> METAXA/$SAMPLE.metaxa.log.txt
# done
```

- Run the script:
```bash
bash physalia_metagenomics/Scripts/READ_BASED.sh
```

- Close the screen by pressing **Ctrl+a+d**
