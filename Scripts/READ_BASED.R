library(tidyverse)
library(phyloseq)
library(vegan)
library(DESeq2)
library(patchwork)

setwd("~/Helsinki/TEACHING/PHYSALIA/data/READ_BASED_R")

# METAXA2

## Data import

### Read metadata
metadata <- read.table("sample_info.txt", sep = "\t", row.names = 1, header = TRUE)

### Read METAXA results at the genus level
metaxa_genus <- read.table("metaxa_genus.txt", sep = "\t", header = TRUE, row.names = 1)

### Make taxonomy data frame
metaxa_TAX <- data.frame(Taxa = row.names(metaxa_genus)) %>% 
  separate(Taxa, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus"), sep = ";")

row.names(metaxa_genus) <- paste0("OTU", seq(nrow(metaxa_genus)))
row.names(metaxa_TAX) <- paste0("OTU", seq(nrow(metaxa_genus)))

# Make a phyloseq object
metaxa_genus <- phyloseq(otu_table(metaxa_genus, taxa_are_rows = TRUE),
                         tax_table(as.matrix(metaxa_TAX)),
                         sample_data(metadata))

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
barplot(sample_sums(metaxa_genus), las = 3)

### See the top 10 OTUs (most abundant throughout all samples)
metaxa_abund <- taxa_sums(metaxa_genus) %>% 
  sort(decreasing = TRUE) %>% 
  head(10) %>%
  names()

### See taxonomy for these OTUs
tax_table(metaxa_genus)[metaxa_abund,]

### And their abundance in our samples
otu_table(metaxa_genus)[metaxa_abund,]

### Heatmap of the most abundant taxa
metaxa_top10 <- prune_taxa(metaxa_abund, metaxa_genus)

heatmap(as.matrix(sqrt(t(otu_table(metaxa_top10)))), col = rev(heat.colors(20)))

tax_table(metaxa_top10)[rownames(otu_table(metaxa_top10)), ]

## Alpha diversity

### Calculate and plot Shannon diversity
metaxa_shannon <- diversity(t(otu_table(metaxa_genus)), index = "shannon")
barplot(metaxa_shannon, ylab = "Shannon diversity", las = 3)

### Calculate and plot richness
metaxa_observed <- specnumber(t(otu_table(metaxa_genus)))
barplot(metaxa_observed, ylab = "Observed taxa", las = 3)
  
## Beta diversity

### Calculate distance matrix and do ordination  
metaxa_dist <- vegdist(t(otu_table(metaxa_genus)))
metaxa_ord <- cmdscale(metaxa_dist)
metaxa_ord_df <- data.frame(metaxa_ord, Ecosystem = sample_data(metaxa_genus)$Ecosystem)

### Plot ordination
ggplot(metaxa_ord_df, aes(x = X1, y = X2, color = Ecosystem)) +
  geom_point(size = 3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + 
  labs(x = "Axis-1", y = "Axis-2") + 
  geom_text(label = row.names(metaxa_ord_df), nudge_y = 0.03) + 
  theme(legend.position = "bottom")

## Differential abundance analysis

### Remove eukaryotes
metaxa_genus_noeuk <- subset_taxa(metaxa_genus, Kingdom == "Bacteria" | Kingdom == "Archaea")

### Run deseq
metaxa_deseq <- phyloseq_to_deseq2(metaxa_genus_noeuk, ~ Ecosystem)
metaxa_deseq <- DESeq(metaxa_deseq, test = "Wald", fitType = "local")

### Get deseq results
metaxa_deseq_res <- results(metaxa_deseq, cooksCutoff = FALSE)

### Keep only p < 0.01
metaxa_deseq_sig <- metaxa_deseq_res[which(metaxa_deseq_res$padj < 0.01), ]
metaxa_deseq_sig <- cbind(as(metaxa_deseq_sig, "data.frame"), as(tax_table(metaxa_genus_noeuk)[rownames(metaxa_deseq_sig), ], "matrix"))

### Plot differentially abundanta taxa
left_join(otu_table(metaxa_genus_noeuk) %>% as.data.frame %>% rownames_to_column("OTU"),
          metaxa_TAX %>% rownames_to_column("OTU")) %>% 
  filter(OTU %in% rownames(metaxa_deseq_sig)) %>% 
  unite(taxonomy, c(OTU, Kingdom, Phylum, Class, Order, Family, Genus), sep = "; ") %>% 
  gather(Library, Reads, -taxonomy) %>% 
  left_join(metadata %>% rownames_to_column("Library")) %>% 
  mutate(Reads = sqrt(Reads)) %>% 
  ggplot(aes(x = Library, y = taxonomy, fill = Reads)) +
  geom_tile() +
  facet_grid(cols = vars(Ecosystem), scale = "free") +
  scale_fill_gradient(low = "white", high = "skyblue4", name = "Reads (square root)") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0))

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

## Data exploration

## Heatmap of the most abundant taxa
megan_genus_abund <- taxa_sums(megan_genus) %>%
  sort(decreasing = TRUE) %>%
  head(10) %>%
  names()

megan_COG_abund <- taxa_sums(megan_COG) %>%
  sort(decreasing = TRUE) %>%
  head(10) %>%
  names()

megan_SEED_abund <- taxa_sums(megan_SEED) %>%
  sort(decreasing = TRUE) %>%
  head(10) %>%
  names()

megan_genus_top10 <- prune_taxa(megan_genus_abund, megan_genus)
megan_COG_top10 <- prune_taxa(megan_COG_abund, megan_COG)
megan_SEED_top10 <- prune_taxa(megan_SEED_abund, megan_SEED)

heatmap(as.matrix(sqrt(t(otu_table(megan_genus_top10)))), col = rev(heat.colors(20)))  
heatmap(as.matrix(sqrt(t(otu_table(megan_COG_top10)))), col = rev(heat.colors(20)))  
heatmap(as.matrix(sqrt(t(otu_table(megan_SEED_top10)))), col = rev(heat.colors(20)))  

tax_table(megan_genus_top10)[rownames(otu_table(megan_genus_top10)), ]
tax_table(megan_COG_top10)[rownames(otu_table(megan_COG_top10)), ]
tax_table(megan_SEED_top10)[rownames(otu_table(megan_SEED_top10)), ]

## Alpha diversity

### Calculate and plot Shannon diversity
megan_genus_shannon <- diversity(t(otu_table(megan_genus)), index = "shannon")
barplot(megan_genus_shannon, ylab = "Shannon diversity")

megan_genus_observed <- specnumber(t(otu_table(megan_genus)))
barplot(megan_genus_observed, ylab = "Observed taxa", las = 3)

megan_COG_shannon <- diversity(t(otu_table(megan_COG)), index = "shannon")
barplot(megan_COG_shannon, ylab = "Shannon diversity")

megan_SEED_shannon <- diversity(t(otu_table(megan_SEED)), index = "shannon")
barplot(megan_SEED_shannon, ylab = "Shannon diversity")
  
## Beta diversity
  
### Calculate distance matrix and do ordination  
megan_genus_dist <- vegdist(t(otu_table(megan_genus)))
megan_genus_ord <- cmdscale(megan_genus_dist)
megan_genus_ord_df <- data.frame(megan_genus_ord, Ecosystem = sample_data(megan_genus)$Ecosystem)

p1 <- ggplot(megan_genus_ord_df, aes(x = X1, y = X2, color = Ecosystem)) +
  geom_point(size = 3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + 
  labs(title="Microbial community", x = "Axis-1", y="Axis-2") + 
  geom_text(label = row.names(megan_genus_ord_df), nudge_y = 0.01) + theme(legend.position = "bottom")

megan_COG_dist <- vegdist(t(otu_table(megan_COG)))
megan_COG_ord <- cmdscale(megan_COG_dist)
megan_COG_ord_df <- data.frame(megan_COG_ord, Ecosystem = sample_data(megan_COG)$Ecosystem)

p2 <- ggplot(megan_COG_ord_df, aes(x = X1, y = X2, color = Ecosystem)) +
  geom_point(size = 3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + 
  labs(title="Microbial community", x = "Axis-1", y="Axis-2") + 
  geom_text(label = row.names(megan_COG_ord_df), nudge_y = 0.01) + theme(legend.position = "bottom")

megan_SEED_dist <- vegdist(t(otu_table(megan_SEED)))
megan_SEED_ord <- cmdscale(megan_SEED_dist)
megan_SEED_ord_df <- data.frame(megan_SEED_ord, Ecosystem = sample_data(megan_SEED)$Ecosystem)

p3 <- ggplot(megan_SEED_ord_df, aes(x = X1, y = X2, color = Ecosystem)) +
  geom_point(size = 3) + 
  scale_color_manual(values=c("firebrick", "royalblue")) +
  theme_classic() + 
  labs(title="Microbial community", x = "Axis-1", y="Axis-2") + 
  geom_text(label = row.names(megan_SEED_ord_df), nudge_y = 0.01) + theme(legend.position = "bottom")

p1 + p2 + p3 + 
  plot_layout(guides = 'collect') & theme(legend.position='bottom')

## Differential abundance analysis

### Genus data
megan_genus_noeuk <- subset_taxa(megan_genus, Rank1!="d__Eukaryota")
megan_genus_deseq <- phyloseq_to_deseq2(megan_genus_noeuk, ~ Ecosystem)
megan_genus_deseq <- DESeq(megan_genus_deseq, test = "Wald", fitType = "local")
megan_genus_deseq_res <- results(megan_genus_deseq, cooksCutoff = FALSE)
megan_genus_deseq_sig <- megan_genus_deseq_res[which(megan_genus_deseq_res$padj < 0.01), ]
megan_genus_deseq_sig <- cbind(as(megan_genus_deseq_sig, "data.frame"), as(tax_table(megan_genus_noeuk)[rownames(megan_genus_deseq_sig), ], "matrix"))

megan_genus_deseq_sig_fen <- megan_genus_deseq_sig[order(megan_genus_deseq_sig$log2FoldChange),] %>% # More abundant taxa in the fens
  filter(log2FoldChange < 0)

megan_genus_deseq_sig_heath <- megan_genus_deseq_sig[order(megan_genus_deseq_sig$log2FoldChange),] %>% # More abundant taxa in the heathlands
  filter(log2FoldChange > 0) 

### COG data
megan_COG_deseq <- phyloseq_to_deseq2(megan_COG, ~ Ecosystem)
megan_COG_deseq <- DESeq(megan_COG_deseq, test = "Wald", fitType = "local")
megan_COG_deseq_res <- results(megan_COG_deseq, cooksCutoff = FALSE)
megan_COG_deseq_sig <- megan_COG_deseq_res[which(megan_COG_deseq_res$padj < 0.01), ]
megan_COG_deseq_sig <- cbind(as(megan_COG_deseq_sig, "data.frame"), as(tax_table(megan_COG)[rownames(megan_COG_deseq_sig), ], "matrix"))

megan_COG_deseq_sig_fen <- megan_COG_deseq_sig[order(megan_COG_deseq_sig$log2FoldChange),] %>% # More abundant taxa in the fens
  filter(log2FoldChange < 0)

megan_COG_deseq_sig_heath <- megan_COG_deseq_sig[order(megan_COG_deseq_sig$log2FoldChange),] %>% # More abundant taxa in the heathlands
  filter(log2FoldChange > 0)

### SEED data
megan_SEED_deseq <- phyloseq_to_deseq2(megan_SEED, ~ Ecosystem)
megan_SEED_deseq <- DESeq(megan_SEED_deseq, test = "Wald", fitType = "local")
megan_SEED_deseq_res <- results(megan_SEED_deseq, cooksCutoff = FALSE)
megan_SEED_deseq_sig <- megan_SEED_deseq_res[which(megan_SEED_deseq_res$padj < 0.01), ]
megan_SEED_deseq_sig <- cbind(as(megan_SEED_deseq_sig, "data.frame"), as(tax_table(megan_SEED)[rownames(megan_SEED_deseq_sig), ], "matrix"))

megan_SEED_deseq_sig_fen <- megan_SEED_deseq_sig[order(megan_SEED_deseq_sig$log2FoldChange),] %>% # More abundant taxa in the fens
  filter(log2FoldChange < 0)

megan_SEED_deseq_sig_heath <- megan_SEED_deseq_sig[order(megan_SEED_deseq_sig$log2FoldChange),] %>% # More abundant taxa in the heathlands
  filter(log2FoldChange > 0)
  