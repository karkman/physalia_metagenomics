# Day 1

| Time      | Activity                          | Slides                                                | Hands-on                                    |
|-----------|-----------------------------------|-------------------------------------------------------|---------------------------------------------|
| Morning   | Course outline and practical info | [Link here](course-outline.pdf)                       |                                             |
| Morning   | Introduction to metagenomics      | [Link here](introduction-to-metagenomics.pdf)         |                                             |
| Morning   | Working with the command line     | [Link here](working-with-the-command-line.pdf)        | [Link here](#working-with-the-command-line) |
| Afternoon | Setting up the Amazon Cloud       |                                                       | [Link here](#setting-up-the-amazon-cloud)   |
| Afternoon | QC and trimming                   | [Link here](QC-and-trimming.pdf)                      | [Link here](#qc-and-trimming)               |

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
This folder is located in `/your-user/Shared`.  
To make things more smooth, we will create softlinks to these files inside your working directory:

```bash
ln -s ../Share/RAWDATA/* RAWDATA
```

### Setting up conda

Most of the programs are pre-installed on the server using [conda](https://docs.conda.io/projects/conda/en/latest/index.html) virtual environments.  
First we need to setup the general conda environment:

```bash
conda init
```

Now either logout of the server and log back in, or run `source .bashrc`.  
This step only has to be run once.  

## QC and trimming

Now we should have softlinks to the raw data and can start the QC and trimming.   
We will use `FastQC`and `MultiQC` for the QC, `Cutadapt` for the trimming of Illumina data and `Porechop` for the trimming of Nanopore data.  
Go to the raw data folder, create a folder for the QC files and activate the virtual environment:

```bash
cd RAWDATA
mkdir FASTQC
conda activate QC_env
```
And now you're ready to run the QC on the raw data:

```bash
fastqc *.fastq.gz -o FASTQC -t 4
multiqc FASTQC/* -o FASTQC -n multiqc.html
```

After QC is finished, copy the MultiQC report (`multiqc.html`) to your local machine using FileZilla and open it with your favourite browser.  
We will go through the report together before doing any trimming.  

The trimming scripts are provided and can be found from the `Scripts` folder.  
First move out of the `RAWDATA` folder using `cd ..`.  
Then open the scripts file with a text editor on the server using `vim`:

```bash
vim Scripts/CUTADAPT.sh
```

To quit `vim` type `:q` and press Enter.  
And now the Porechop script:

```bash
vim Scripts/PORECHOP.sh
```

We wil go through the different options together.  
But you can take a look at the manual for Cutadapt [here](https://cutadapt.readthedocs.io/en/stable/index.html), and for Porechop [here](https://github.com/rrwick/Porechop).  

Now let's launch the trimming scripts, first Cutadapt:

```bash
bash Scripts/CUTADAPT.sh
```

And when that's done, Porechop:

```bash
bash Scripts/PORECHOP.sh
```

After the trimming is done, run the QC steps (`FastQC` and `MultiQC`) for the trimmed sequence files in the `TRIMMED` folder.  
**Remember to create the `FASTQC` folder**.  
And when it's done, copy the MultiQC report to yor local machine using FileZilla and open it with a browser.
