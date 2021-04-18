# Day 2

| Time      | Activity                      | Slides                               | Hands-on                                 |
|-----------|-------------------------------|--------------------------------------|------------------------------------------|
| Morning   | Read-based analyses (Part 1)  | [Link here](read-based-analyses.pdf) | [Link here](#read-based-analyses-part-1) |
| Afternoon | Read-based analyses (Part 2)  |                                      | [Link here](#read-based-analyses-part-2) |

## Read-based analyses (Part 1)

### Running the script
First login to the Amazon Cloud and `cd` to your working directory.  
We migh have made changes to the GitHub repository, so let's pull those changes now:

```bash
git pull
```

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

### MEGAN6
Again, because we are using real data, some steps are quite intensive and require some time to be completed.  
Let's wait a while to see if the script seems to be running correctly.  
Then let's stop it by hitting **ctrl+c**.  

Now take a look at the `MEGAN` folder inside `~/Share`, which contains the actual output from the script we tried to run before:  

```bash
ls ~/Share/MEGAN
```

For each sample, you should find:
- `$SAMPLE.blastx.txt`: DIAMOND output
- `$SAMPLE.diamond.log.txt`: DIAMOND log
- `$SAMPLE.rma6`: MEGAN output
- `$SAMPLE.megan.log.txt`: MEGAN log

The `.rma6` files are compressed binary files created by `MEGAN` (command-line version).  
These describe the taxonomic and functional composition of the samples based on the `DIAMOND` annotation against the NCBI nr database.  

`MEGAN` also has a powerful GUI version, that you have installed in your own computer.  
First let's copy the four `.rma6` files to your own computers using FileZilla.  
When that's done let's launch `MEGAN` and take a look together at one of the samples.  

Now, by using the `Compare` tool, let's try to find differences between the samples.  
On the slides for the first day ("Course outline and practical info") we saw that we have two heathland and two fen soils.  
Can we see major differences in community structure between these two ecosystems? For example:
- Are samples from the same ecosystem type more similar to each other than to the other samples? **HINT:** Try changing the view to the Genus Rank and then going to "Window" > "Cluster Analysis" and chosing "UPGMA Tree".
- What is the most abundant phylum in the heathland soils? And in the fen soils?
- By the way, what is the main environmental difference between these two ecosystems? Can you think about how this could explain the difference in phylum abundance?
- Now looking at the functional profiles (e.g. SEED), can you spot differences between these two ecosystems? Specially regarding energy and metabolism?
- Again, how these differences relate to the environmental aspects of these ecosystems?

## Read-based analyses (Part 2)
MEGAN is a really poweful tool to explore the data.  
However, to really dig in and perform more advanced statistical analyses, we will have to rely on the good old R.  

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
