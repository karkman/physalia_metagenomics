# Day 1

| Time      | Activity                          | Slides                                                | Hands-on                                    |
|-----------|-----------------------------------|-------------------------------------------------------|---------------------------------------------|
| Morning   | Course outline and practical info | [Link here](course-outline.pdf)                       |                                             |
| Morning   | Introduction to metagenomics      | [Link here](introduction-to-metagenomics.pdf)         |                                             |
| Morning   | Working with the command line     | [Link here](working-with-the-command-line.pdf)        | [Link here](#working-with-the-command-line) |
| Afternoon | Setting up the Amazon Cloud       |                                                       | [Link here](#setting-up-the-amazon-cloud)   |
| Afternoon | QC and trimming                   | [Link here](QC-and-trimming.pdf)                      | [Link here](#qc-and-trimming)               |
| Afternoon | Read-based analyses (Part 1)      | [Link here](read-based-analyses-1.pdf)                | [Link here](#read-based-analyses)           |

## Working with the command line

Most of our activities will be done using the Unix command line (aka Unix shell).  
It is thus highly recommend to have at least a basic grasp of how to get around in the Unix shell.  
We will now dedicate one hour or so to follow an online tutorial to learn (or refresh) the basics of the Unix shell.  
Click [here](https://www.codecademy.com/learn/learn-the-command-line) to go the Codeacademy course "Learn the command line".

## Setting up the Amazon Cloud

### Connecting to the server

For most of the analyses we will use the Amazon cloud services.  
The IP address of the Amazon cloud instance will change every day, we will provide it to you at the start of the activities.   
Your username - that you have received by e-mail - will be the same for the whole course.  
The list of usernames can be found in Slack (#before-start).  
More information on how to connect to the Amazon cloud instance also in Slack (#before-start), but also [here](connecting-to-the-amazon-EC2-service.pdf).

### Copying the course's GitHub repository
Once you have connected to the server, you will see your home folder.  
**Remember**: You can check where you are with the command `pwd`\.  

To have access to the scripts and some of the data, let's copy this GitHub repository to your home folder using `git clone`:

```bash
git clone https://github.com/karkman/physalia_metagenomics
```

You should now have a folder called **physalia_metagenomics** in there.  
**Remember**: You can check the contents of the folder with the command `ls`\.  

We might update this repository during the course.  
To get the latest updates, pull the changes from GitHub using `git pull`:

```bash
cd physalia_metagenomics
git pull
```

This physalia_metagenomics folder within your home directory is where everything will be run (aka working directory).  
So remember, **everytime you connnect to the server**, you have to `cd physalia_metagenomics`\.  
Every once in a while, also run `git pull` to get the newest version of this repository.


### Getting the raw data
Now let's make a folder for the raw data (remember to `cd` to the physalia_metagenomics folder first if you are not yet inside it):

```bash
mkdir RAWDATA
```

To save disk space (and because copying large files takes time), the raw data will be stored in a shared folder.  
The path to this shared folder is `/home/ubuntu/Share/RAWDATA`\.  
To make things more smooth, we will create softlinks to these files inside your working directory:

```bash
ln -s /home/ubuntu/Share/RAWDATA/* RAWDATA
```

## QC and trimming

Now we should have softlinks to the data and can start the QC and trimming.   
We will use `FastQC`and `MultiQC` for the QC and `cutadapt` for the trimming.  
Go to the raw data folder and create a folder for the QC files.   

```bash
cd raw_data
mkdir FASTQC
```
Most of the programs are preinstalled on the server in [conda](https://docs.conda.io/projects/conda/en/latest/index.html) virtual environemnts.  
You only need to activate the virtual enviroment and you're ready to run QC on the raw data.

```bash
conda activate QC_env
fastqc *.fastq.gz -o FASTQC -t 4
multiqc FASTQC/* -o FASTQC -n raw_QC
```

After QC is finished, copy the multiqc report (`raw_QC.html`) to your local machine and open it with your favourite browser.  
We will go thru the report together before doing any trimming.

The trimming script is provided and can be found from the `Scripts` folder.
Open the file with a text editor on the server. We wil go thru the different options together. Manual for cutadapt can be found from [here.](https://cutadapt.readthedocs.io/en/stable/index.html)

```bash
vim Scripts/CUTADAPT.sh
```

Then run the trimming.

```bash
bash Scripts/CUTADAPT.sh
```

After the trimming is done, run the QC steps for the trimmed sequence files in the `TRIMMED` folder.  
And when it's done, open the MultiQC report on yor local machine.


## Read-based analyses

We will launch the scripts for the read-based analyses now so that everything is (hopefully) finished in time for tomorrow morning.  

- Connect to the server
- Go to your directory
- Open a `screen` so you can leave things running overnight:

```bash
screen -S read_based
```

- Take a look at the script using `less`:

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
