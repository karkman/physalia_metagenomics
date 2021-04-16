# Day 2

| Time      | Activity                      | Slides                                 | Hands-on                                 |
|-----------|-------------------------------|----------------------------------------|------------------------------------------|
| Morning   | Read-based analyses (Part 1)  | [Link here](read-based-analyses-1.pdf) | [Link here](#read-based-analyses-part-1) |
| Morning   | Read-based analyses (Part 2)  | [Link here](read-based-analyses-2.pdf) | [Link here](#read-based-analyses-part-2) |
| Afternoon | Read-based analyses (Part 3)  |                                        | [Link here](#read-based-analyses-part-3) |

## Read-based analyses (Part 1)

First login to the Amazon Cloud and `cd` to your working directory.  
For the read-based analyses, we will use `seqtk`, `DIAMOND`, `MEGAN` and `METAXA`.  
Like yesterday, the script is provided and can be found from the `Scripts` folder.  
Let's take a look at the script using `less`:

```bash
less Scripts/READ_BASED.sh
```

**NOTE:** You can scroll up and down using the arrow keys on your keyboard, or move one "page" at a time using the spacebar.  
**NOTE:** To quit `less`, hit the letter **q**.  

As you will see, we are first running `seqtk` to subsample the data to an even number of sequences per sample (2,000,000).  
Then we are running `DIAMOND` to annotate the reads against the NCBI nr database.  
Then we will use `MEGAN` to parse the annotations and get taxonomic and functional assignments.  
In addition to `DIAMOND` and `MEGAN`, we will also use a different approach to get taxonomic profiles using `METAXA`.  
This will happen in two steps: the first command finds rRNA genes among our reads, and the second summarises the taxonomy.  

Now let's run the script:

```bash
bash Scripts/READ_BASED.sh
```

## Read-based analyses (Part 2)

Again, because we are using real data, some steps are quite intensive and require some time to be completed.  
Let's stop the script by hitting **ctrl+c** and make a softlink to the output that is found in the `Share` folder:  

```bash
ln -sf ../Share/MEGAN/* MEGAN
ln -sf ../Share/METAXA/* METAXA
```

Let's take a look at the folder `MEGAN`:

```bash
ls MEGAN
```

For each sample, you should find:
- `$SAMPLE.blastx.txt`: DIAMOND output
- `$SAMPLE.diamond.log.txt`: DIAMOND log
- `$SAMPLE.rma6`: MEGAN output
- `$SAMPLE.megan.log.txt`: MEGAN log

The `.rma6` files were created by `MEGAN` and contain taxonomic and functional information based on the `DIAMOND` annotation against the NCBI nr database.  
We can open these files in the GUI version of `MEGAN` that you have installed in your own computer.  
First let's copy the `.rma6` files to your own computers using FileZilla.  
When that's done let's launch `MEGAN`.  

## Read-based analyses (Part 3)

We will now continue the read-based analyses in R.  
We need some external packages for the analyses, including:

- `tidyverse` for data wrangling (includes `ggplot2` for plotting)
- `phyloseq` for easy storage and manipulation of ’omics data
- `vegan` for diversity analyses
- `DESeq2` for differential abundance analysis
- `patchwork` for plot layouts

First download the `READ_BASED_R` folder that is inside the `Share` folder to your own computer using FileZilla.  
Then let's start RStudio and load the necessary packages:

``` r
library(tidyverse)
library(phyloseq)
library(vegan)
library(DESeq2)
library(patchwork)
```
