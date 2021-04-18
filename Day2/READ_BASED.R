library(tidyverse)
library(phyloseq)
library(vegan)
library(DESeq2)
library(patchwork)

setwd("~/Helsinki/TEACHING/PHYSALIA/data/READ_BASED_R")

# METAXA2

## Data import

### Read metadata
metadata <- read.table("metadata.txt", sep = "\t", row.names = 1, header = TRUE)

### Read METAXA results at the genus level
metaxa_genus <- read.table("metaxa_genus.txt", sep = "\t", header = TRUE, row.names = 1)

### Make taxonomy data frame
metaxa_TAX <- data.frame(Taxa = row.names(metaxa_genus)) %>% 
  separate(Taxa, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus"), sep = ";")

row.names(metaxa_genus) <- paste0("OTU", seq(nrow(metaxa_genus)))
row.names(metaxa_TAX) <- paste0("OTU", seq(nrow(metaxa_genus)))

# Make a phyloseq object
metaxa_genus <- phyloseq(otu_table(metaxa_genus, taxa_are_rows = TRUE), tax_table(as.matrix(metaxa_TAX)), sample_data(metadata))

## Data exploration

### Take a look at the phyloseq object
metaxa_genus

### See the first few OTUs
head(otu_table(metaxa_genus))
head(tax_table(metaxa_genus))

### Take a look at the samples
sample_data(metaxa_genus)
sample_sums(metaxa_genus)

### Plot the number of reads within each sample
barplot(sample_sums(metaxa_genus))

### See the top 10 OTUs (most abundant throughout all samples)
metaxa_abund <- taxa_sums(metaxa_genus) %>% 
  sort(decreasing = TRUE) %>% 
  head(10) %>%
  names()

### See taxonomy for these OTUs
tax_table(metaxa_genus)[metaxa_abund]

## Alpha diversity

### Calculate and plot Shannon diversity
metaxa_shannon <- diversity(t(otu_table(metaxa_genus)), index = "shannon")
barplot(metaxa_shannon, ylab = "Shannon diversity")

### Calculate and plot richness
metaxa_observed <- specnumber(t(otu_table(metaxa_genus)))
barplot(metaxa_observed, ylab = "Observed taxa")
  
## Beta diversity

### Calculate distance matrix and do ordination  
metaxa_dist <- vegdist(t(otu_table(metaxa_genus)))
metaxa_ord <- cmdscale(metaxa_dist)
metaxa_ord_df <- data.frame(metaxa_ord, Ecosystem = sample_data(metaxa_genus)$Ecosystem)

### Plot ordination
ggplot(metaxa_ord_df, aes(x = X1, y = X2, color = Ecosystem)) +
  geom_point(size = 3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + labs(x = "Axis-1", y = "Axis-2") + 
  geom_text(label = row.names(metaxa_ord_df), nudge_y = 0.03) + 
  theme(legend.position = "bottom")

## Differential abundance analysis

### Remove eukaryotes
metaxa_genus_noeuk <- subset_taxa(metaxa_genus, Kingdom!="Eukaryota")

### Run deseq
metaxa_deseq <- phyloseq_to_deseq2(metaxa_genus_noeuk, ~ Ecosystem)
metaxa_deseq <- DESeq(metaxa_deseq, test = "Wald", fitType = "local")

### Get deseq results
metaxa_deseq_res <- results(metaxa_deseq, cooksCutoff = FALSE)

### Keep only p < 0.01
metaxa_deseq_sig <- metaxa_deseq_res[which(metaxa_deseq_res$padj < 0.01), ]
metaxa_deseq_sig <- cbind(as(metaxa_deseq_sig, "data.frame"), as(tax_table(metaxa_genus_noeuk)[rownames(metaxa_deseq_sig), ], "matrix"))

metaxa_deseq_sig[order(metaxa_deseq_sig$log2FoldChange),] %>%
  knitr::kable(digits = 2)

# MEGAN6
  
## Data import
  
### Read MEGAN results at the genus level
megan_genus <- import_biom("MEGAN_genus.biom")
sample_data(megan_genus) <- sample_data(metadata)

### Read COG functions
megan_COG <- import_biom("MEGAN_EGGNOG.biom")
sample_data(megan_COG) <- sample_data(metadata)

### Read SEED functions
megan_SEED <- import_biom("MEGAN_SEED.biom")
sample_data(megan_SEED) <- sample_data(metadata)


### Data exploration

``` r
# Do it yourself
```

### Alpha diversity

``` r
shannon <- diversity(t(otu_table(megan_genus)), index="shannon")
barplot(shannon, ylab="Shannon diversity")
```

![](README_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->
  
  ``` r
shannon <- diversity(t(otu_table(megan_COG)), index="shannon")
barplot(shannon, ylab="Shannon diversity")
```

![](README_files/figure-gfm/unnamed-chunk-9-2.png)<!-- -->
  
  ``` r
shannon <- diversity(t(otu_table(megan_SEED)), index="shannon")
barplot(shannon, ylab="Shannon diversity")
```

![](README_files/figure-gfm/unnamed-chunk-9-3.png)<!-- -->
  
  ### Beta diversity
  
  ``` r
dist_mat <- vegdist(t(otu_table(megan_genus)))
ord <- cmdscale(dist_mat)
df <- data.frame(ord, Type=sample_data(megan_genus)$Type)

p1 <- ggplot(df, aes(x=X1, y=X2, color=Type)) +
  geom_point(size=3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + labs(title="Microbial community", x="Axis-1", y="Axis-2") + 
  geom_text(label=row.names(df), nudge_y=0.01) + theme(legend.position="bottom")

dist_mat <- vegdist(t(otu_table(megan_COG)))
ord <- cmdscale(dist_mat)
df <- data.frame(ord, Type=sample_data(megan_COG)$Type)

p2 <- ggplot(df, aes(x=X1, y=X2, color=Type)) +
  geom_point(size=3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + labs(title="COG categories", x="Axis-1", y="Axis-2") + 
  geom_text(label=row.names(df), nudge_y=0.01) + theme(legend.position="bottom")

dist_mat <- vegdist(t(otu_table(megan_SEED)))
ord <- cmdscale(dist_mat)
df <- data.frame(ord, Type=sample_data(megan_SEED)$Type)

p3 <- ggplot(df, aes(x=X1, y=X2, color=Type)) +
  geom_point(size=3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + labs(title="SEED categories", x="Axis-1", y="Axis-2") + 
  geom_text(label=row.names(df), nudge_y=0.01) + theme(legend.position="bottom")

p1 + p2 + p3 + 
  plot_layout(guides = 'collect') & theme(legend.position='bottom')
```

![](README_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->
  
  ### Differential abundance analysis
  
  #### Microbial community
  
  ``` r
tmp <- subset_taxa(megan_genus, Rank1!="d__Eukaryota")
deseq_genus = phyloseq_to_deseq2(tmp, ~ Type)
deseq_genus = DESeq(deseq_genus, test="Wald", fitType="local")

res = results(deseq_genus, cooksCutoff = FALSE)
alpha = 0.01
res_table = res[which(res$padj < alpha), ]
res_table = cbind(as(res_table, "data.frame"), as(tax_table(megan_genus)[rownames(res_table), ], "matrix"))
```

**More abundant taxa in Bog**
  
  ``` r
res_table[order(res_table$log2FoldChange),]  %>% 
  filter(log2FoldChange<0) %>%
  head(5) %>%  
  janitor::clean_names() %>%
  knitr::kable(digits=2)
```

|         | base\_mean | log2fold\_change | lfc\_se |  stat | pvalue | padj | rank1         | rank2               | rank3                    | rank4                    | rank5                    | rank6             | rank7 |
  |:--------|-----------:|-----------------:|--------:|------:|-------:|-----:|:--------------|:--------------------|:-------------------------|:-------------------------|:-------------------------|:------------------|:------|
  | 445219  |    1077.86 |           -26.32 |    4.78 | -5.50 |      0 |    0 | d\_\_Bacteria | p\_\_Proteobacteria | c\_\_Alphaproteobacteria | o\_\_Rhodospirillales    | g\_\_Reyranella          | NA                | NA    |
  | 1643958 |     579.52 |           -25.60 |    4.78 | -5.35 |      0 |    0 | d\_\_Bacteria | p\_\_Proteobacteria | c\_\_Alphaproteobacteria | o\_\_Rhizobiales         | f\_\_Roseiarcaceae       | g\_\_Roseiarcus   | NA    |
  | 1988    |     310.87 |           -24.75 |    4.78 | -5.17 |      0 |    0 | d\_\_Bacteria | p\_\_Actinobacteria | c\_\_Actinobacteria      | o\_\_Streptosporangiales | f\_\_Thermomonosporaceae | g\_\_Actinomadura | NA    |
  | 29407   |     298.23 |           -24.68 |    4.78 | -5.16 |      0 |    0 | d\_\_Bacteria | p\_\_Proteobacteria | c\_\_Alphaproteobacteria | o\_\_Rhizobiales         | f\_\_Hyphomicrobiaceae   | g\_\_Rhodoplanes  | NA    |
  | 85025   |     283.13 |           -24.61 |    4.78 | -5.14 |      0 |    0 | d\_\_Bacteria | p\_\_Actinobacteria | c\_\_Actinobacteria      | o\_\_Corynebacteriales   | f\_\_Nocardiaceae        | NA                | NA    |
  
  **More abundant taxa in Fen**
  
  ``` r
res_table[order(res_table$log2FoldChange),]  %>% 
  filter(log2FoldChange>0) %>%
  tail(5) %>%  
  janitor::clean_names() %>%
  knitr::kable(digits=2)
```

|         | base\_mean | log2fold\_change | lfc\_se | stat | pvalue | padj | rank1         | rank2               | rank3                    | rank4                    | rank5                      | rank6                 | rank7 |
  |:--------|-----------:|-----------------:|--------:|-----:|-------:|-----:|:--------------|:--------------------|:-------------------------|:-------------------------|:---------------------------|:----------------------|:------|
  | 135618  |     463.07 |            25.32 |    4.78 | 5.29 |      0 |    0 | d\_\_Bacteria | p\_\_Proteobacteria | c\_\_Gammaproteobacteria | o\_\_Methylococcales     | NA                         | NA                    | NA    |
  | 1198451 |     584.80 |            25.64 |    4.78 | 5.36 |      0 |    0 | d\_\_Archaea  | p\_\_Euryarchaeota  | c\_\_Methanomicrobia     | o\_\_Methanomicrobiales  | f\_\_Methanoregulaceae     | NA                    | NA    |
  | 161492  |     637.30 |            25.76 |    4.78 | 5.38 |      0 |    0 | d\_\_Bacteria | p\_\_Proteobacteria | c\_\_Deltaproteobacteria | o\_\_Myxococcales        | f\_\_Anaeromyxobacteraceae | g\_\_Anaeromyxobacter | NA    |
  | 2357    |     682.60 |            25.86 |    4.78 | 5.40 |      0 |    0 | d\_\_Bacteria | p\_\_Proteobacteria | c\_\_Deltaproteobacteria | o\_\_Syntrophobacterales | f\_\_Syntrophaceae         | g\_\_Desulfomonile    | NA    |
  | 2222    |     736.65 |            25.96 |    4.78 | 5.43 |      0 |    0 | d\_\_Archaea  | p\_\_Euryarchaeota  | c\_\_Methanomicrobia     | o\_\_Methanosarcinales   | f\_\_Methanotrichaceae     | g\_\_Methanothrix     | NA    |
  
  #### COG categories
  
  ``` r
deseq_COG = phyloseq_to_deseq2(megan_COG, ~ Type)
deseq_COG = DESeq(deseq_COG, test="Wald", fitType="local")

res = results(deseq_COG, cooksCutoff = FALSE)
alpha = 0.01
res_table = res[which(res$padj < alpha), ]
res_table = cbind(as(res_table, "data.frame"), as(tax_table(megan_COG)[rownames(res_table), ], "matrix"))
```

**More abundant COG categories in Bog**
  
  ``` r
res_table[order(res_table$log2FoldChange),]  %>% 
  filter(log2FoldChange<0) %>%
  head(5) %>%  
  janitor::clean_names() %>%
  knitr::kable(digits=2)
```

|      | base\_mean | log2fold\_change | lfc\_se |  stat | pvalue | padj | rank1 | rank2                         | rank3                                                               | rank4                                                                                                                              |
  |:-----|-----------:|-----------------:|--------:|------:|-------:|-----:|:------|:------------------------------|:--------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------|
  | 5042 |      18.56 |            -7.50 |    1.55 | -4.84 |      0 |    0 | Root  | metabolism                    | \[F\] Nucleotide transport and metabolism                           | COG5042 Purine nucleoside permease                                                                                                 |
  | 3546 |      12.62 |            -6.95 |    1.58 | -4.40 |      0 |    0 | Root  | metabolism                    | \[P\] Inorganic ion transport and metabolism                        | COG3546 Catalase                                                                                                                   |
  | 3486 |       7.99 |            -6.28 |    1.68 | -3.74 |      0 |    0 | Root  | metabolism                    | \[Q\] Secondary metabolites biosynthesis, transport and catabolism  | COG3486 L-lysine 6-monooxygenase (NADPH)                                                                                           |
  | 3709 |       7.09 |            -6.11 |    1.67 | -3.66 |      0 |    0 | Root  | metabolism                    | \[P\] Inorganic ion transport and metabolism                        | COG3709 Catalyzes the phosphorylation of ribose 1,5-bisphosphate to 5-phospho-D-ribosyl alpha-1-diphosphate (PRPP) (By similarity) |
  | 4959 |       7.07 |            -6.11 |    1.68 | -3.65 |      0 |    0 | Root  | cellularProcessesAndSignaling | \[U\] Intracellular trafficking, secretion, and vesicular transport | COG4959 Conjugal transfer protein                                                                                                  |
  
  **More abundant COG categories in Fen**
  
  ``` r
res_table[order(res_table$log2FoldChange),]  %>% 
  filter(log2FoldChange>0) %>%
  tail(5) %>%  
  janitor::clean_names() %>%
  knitr::kable(digits=2)
```

|      | base\_mean | log2fold\_change | lfc\_se | stat | pvalue | padj | rank1 | rank2      | rank3                                     | rank4                                                                                                                                  |
  |:-----|-----------:|-----------------:|--------:|-----:|-------:|-----:|:------|:-----------|:------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------|
  | 4624 |      82.35 |             8.54 |    1.47 | 5.82 |      0 |    0 | Root  | metabolism | \[C\] Energy production and conversion    | COG4624 metallo-sulfur cluster assembly                                                                                                |
  | 67   |      31.22 |             8.58 |    1.51 | 5.69 |      0 |    0 | Root  | metabolism | \[E\] Amino acid transport and metabolism | COG0067 glutamate synthase                                                                                                             |
  | 1614 |      36.51 |             8.81 |    1.50 | 5.88 |      0 |    0 | Root  | metabolism | \[C\] Energy production and conversion    | COG1614 Part of a complex that catalyzes the reversible cleavage of acetyl-CoA, allowing autotrophic growth from CO(2) (By similarity) |
  | 1456 |      42.06 |             9.01 |    1.49 | 6.04 |      0 |    0 | Root  | metabolism | \[C\] Energy production and conversion    | COG1456 Acetyl-CoA decarbonylase synthase complex subunit gamma                                                                        |
  | 1908 |     112.66 |            10.43 |    1.46 | 7.12 |      0 |    0 | Root  | metabolism | \[C\] Energy production and conversion    | COG1908 Methyl-viologen-reducing hydrogenase, delta subunit                                                                            |
  
  #### SEED categories
  
  ``` r
deseq_SEED = phyloseq_to_deseq2(megan_SEED, ~ Type)
deseq_SEED = DESeq(deseq_SEED, test="Wald", fitType="local")

res = results(deseq_SEED, cooksCutoff = FALSE)
alpha = 0.01
res_table = res[which(res$padj < alpha), ]
res_table = cbind(as(res_table, "data.frame"), as(tax_table(megan_SEED)[rownames(res_table), ], "matrix"))
```

**More abundant SEED categories in Bog**
  
  ``` r
res_table[order(res_table$log2FoldChange),]  %>% 
  filter(log2FoldChange<0) %>%
  head(5) %>%  
  janitor::clean_names() %>%
  knitr::kable(digits=2)
```

|       | base\_mean | log2fold\_change | lfc\_se |  stat | pvalue | padj | rank1 | rank2                               | rank3                                  | rank4                                                          | rank5                                 |
  |:------|-----------:|-----------------:|--------:|------:|-------:|-----:|:------|:------------------------------------|:---------------------------------------|:---------------------------------------------------------------|:--------------------------------------|
  | 23068 |      35.35 |            -6.21 |    1.20 | -5.18 |      0 | 0.00 | Root  | Stress Response, Defense, Virulence | Stress Response, Defense and Virulence | Resistance to antibiotics and toxic compounds                  | Fusaric acid resistance cluster       |
  | 23294 |       5.82 |            -6.07 |    2.10 | -2.88 |      0 | 0.01 | Root  | Metabolism                          | Cofactors, Vitamins, Prosthetic Groups | Tetrapyrroles                                                  | Mycobacterial heme acquisition system |
  | 11305 |      45.15 |            -5.98 |    1.00 | -5.97 |      0 | 0.00 | Root  | DNA Processing                      | DNA replication                        | Plasmid replication                                            | NA                                    |
  | 23192 |       5.23 |            -5.92 |    2.06 | -2.87 |      0 | 0.01 | Root  | Membrane Transport                  | Protein secretion system, Type VII     | ESAT-6 protein secretion system in Mycobacteria (locus ESX-5)  | NA                                    |
  | 23407 |       5.15 |            -5.89 |    1.96 | -3.01 |      0 | 0.01 | Root  | Membrane Transport                  | Protein secretion system, Type VII     | ESAT-6 proteins secretion system in Mycobacteria (locus ESX-3) | NA                                    |
  
  **More abundant SEED categories in Fen**
  
  ``` r
res_table[order(res_table$log2FoldChange),]  %>% 
  filter(log2FoldChange>0) %>%
  tail(5) %>%  
  janitor::clean_names() %>%
  knitr::kable(digits=2)
```

|       | base\_mean | log2fold\_change | lfc\_se | stat | pvalue | padj | rank1 | rank2              | rank3             | rank4                                | rank5                                      |
  |:------|-----------:|-----------------:|--------:|-----:|-------:|-----:|:------|:-------------------|:------------------|:-------------------------------------|:-------------------------------------------|
  | 23452 |     118.16 |             8.80 |    1.47 | 5.99 |      0 |    0 | Root  | Energy             | Respiration       | Anaerobic respiratory complex QmoABC | NA                                         |
  | 23454 |      44.64 |             8.84 |    1.54 | 5.74 |      0 |    0 | Root  | Energy             | Respiration       | Electron donating reactions          | Energy-conserving hydrogenase (ferredoxin) |
  | 23473 |      45.09 |             8.85 |    1.54 | 5.75 |      0 |    0 | Root  | Protein Processing | Protein Synthesis | Aminoacyl-tRNA-synthetases           | tRNA aminoacylation, Pyr                   |
  | 14589 |     405.48 |             9.58 |    1.03 | 9.25 |      0 |    0 | Root  | Energy             | Respiration       | Hydrogenases                         | Carbon monoxide induced hydrogenase        |
  | 23356 |     158.08 |            10.66 |    1.47 | 7.23 |      0 |    0 | Root  | Metabolism         | Carbohydrates     | CO2 fixation                         | Acetyl-CoA Pathway Wood-Ljungdahl          |
  
  