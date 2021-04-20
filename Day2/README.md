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

### MEGAN
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
However, to really dig in and perform more advanced statistical analyses, we will use R.  
First download the `READ_BASED_R` folder that is inside the `Share` folder to your own computer using FileZilla.  
We also need some external packages for the analyses, including:

- `tidyverse` for data wrangling (includes `ggplot2` for plotting)
- `phyloseq` for easy storage and manipulation of ’omics data
- `vegan` for diversity analyses
- `DESeq2` for differential abundance analysis
- `patchwork` for plot layouts

### METAXA
Now we will work on the output of `METAXA`, the other tool we have employed to obtain taxonomic profiles for the communities.  

Let's start RStudio and load the necessary packages:

```r
library(tidyverse)
library(phyloseq)
library(vegan)
library(DESeq2)
library(patchwork)
```

And let's change the directory the `READ_BASED_R` folder:

```r
setwd("PUT-HERE-TO-THE-PATH-TO-THE-READ-BASED-R-FOLDER")
```

#### Data import

```r
# Read metadata
metadata <- read.table("sample_info.txt", sep = "\t", row.names = 1, header = TRUE)

# Read METAXA results at the genus level
metaxa_genus <- read.table("metaxa_genus.txt", sep = "\t", header = TRUE, row.names = 1)

# Make taxonomy data frame
metaxa_TAX <- data.frame(Taxa = row.names(metaxa_genus)) %>%
  separate(Taxa, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus"), sep = ";")

row.names(metaxa_genus) <- paste0("OTU", seq(nrow(metaxa_genus)))
row.names(metaxa_TAX) <- paste0("OTU", seq(nrow(metaxa_genus)))

# Make a phyloseq object
metaxa_genus <- phyloseq(otu_table(metaxa_genus, taxa_are_rows = TRUE),
                        tax_table(as.matrix(metaxa_TAX)),
                        sample_data(metadata))
```

#### Data exploration

```r
# Take a look at the phyloseq object
metaxa_genus

# See the first few OTUs
head(otu_table(metaxa_genus))
head(tax_table(metaxa_genus))

# Take a look at the samples
sample_data(metaxa_genus)
sample_sums(metaxa_genus)

# Plot the number of reads within each sample
barplot(sample_sums(metaxa_genus), las = 3)

# See the top 10 OTUs (most abundant throughout all samples)
metaxa_abund <- taxa_sums(metaxa_genus) %>%
  sort(decreasing = TRUE) %>%
  head(10) %>%
  names()

# See taxonomy for these OTUs
tax_table(metaxa_genus)[metaxa_abund,]

# And their abundance in our samples
otu_table(metaxa_genus)[metaxa_abund,]
```

#### Heatmap of the most abundant taxa

```r
metaxa_top10 <- prune_taxa(metaxa_abund, metaxa_genus)

heatmap(as.matrix(sqrt(t(otu_table(metaxa_top10)))), col = rev(heat.colors(20)))  
```

#### Alpha diversity

```r
# Calculate and plot Shannon diversity
metaxa_shannon <- diversity(t(otu_table(metaxa_genus)), index = "shannon")
barplot(metaxa_shannon, ylab = "Shannon diversity", las=3)

# Calculate and plot richness
metaxa_observed <- specnumber(t(otu_table(metaxa_genus)))
barplot(metaxa_observed, ylab = "Observed taxa", las=3  )
```

#### Beta diversity

```r
# Calculate distance matrix and do ordination  
metaxa_dist <- vegdist(t(otu_table(metaxa_genus)))
metaxa_ord <- cmdscale(metaxa_dist)
metaxa_ord_df <- data.frame(metaxa_ord, Ecosystem = sample_data(metaxa_genus)$Ecosystem)

# Plot ordination
ggplot(metaxa_ord_df, aes(x = X1, y = X2, color = Ecosystem)) +
  geom_point(size = 3) +
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() +
  labs(x = "Axis-1", y = "Axis-2") +
  geom_text(label = row.names(metaxa_ord_df), nudge_y = 0.03) +
  theme(legend.position = "bottom")
```

#### Differential abundance analysis

```r
# Remove eukaryotes
metaxa_genus_noeuk <- subset_taxa(metaxa_genus, Kingdom=="Bacteria" | Kingdom=="Archaea")

# Run deseq
metaxa_deseq <- phyloseq_to_deseq2(metaxa_genus_noeuk, ~ Ecosystem)
metaxa_deseq <- DESeq(metaxa_deseq, test = "Wald", fitType = "local")

# Get deseq results
metaxa_deseq_res <- results(metaxa_deseq, cooksCutoff = FALSE)

# Keep only p < 0.01
metaxa_deseq_sig <- metaxa_deseq_res[which(metaxa_deseq_res$padj < 0.01), ]
metaxa_deseq_sig <- cbind(as(metaxa_deseq_sig, "data.frame"), as(tax_table(metaxa_genus_noeuk)[rownames(metaxa_deseq_sig), ], "matrix"))

metaxa_deseq_sig[order(metaxa_deseq_sig$log2FoldChange),]
```

### MEGAN

Let's also look at the data we exported from `MEGAN` using R.  
After importing the data as shown below, repeat the steps you have done for the `METAXA` data, this time using as input the `megan_genus`, `megan_COG`, and `MEGAN_SEED` objects.  

#### Data import

```r
# Read MEGAN results at the genus level
megan_genus <- import_biom("MEGAN_genus.biom")
sample_data(megan_genus) <- sample_data(metadata)

# Read COG functions
megan_COG <- import_biom("MEGAN_EGGNOG.biom")
sample_data(megan_COG) <- sample_data(metadata)

# Read SEED functions
megan_SEED <- import_biom("MEGAN_SEED.biom")
sample_data(megan_SEED) <- sample_data(metadata)
```
