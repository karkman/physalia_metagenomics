library(tidyverse)
library(patchwork)


##### IMPORT DATA #####

# Create metadata
metadata <- tibble(Sample = c("Sample01", "Sample02", "Sample03", "Sample04"),
                   Ecosystem = c("heathland", "fen", "fen", "heathland"))

# Read bins summary
summary <- bind_rows(read_delim("Sample01.bins_summary.txt", delim = "\t"),
                     read_delim("Sample02.bins_summary.txt", delim = "\t"),
                     read_delim("Sample03.bins_summary.txt", delim = "\t"),
                     read_delim("Sample04.bins_summary.txt", delim = "\t"))

# Make a list of MAGs
MAGs <- summary %>% 
  filter(str_detect(bins, "_MAG_")) %>% 
  pull(bins)

# Explore the summary a bit:

## Number of MAGs per sample
summary %>% 
  filter(bins %in% MAGs) %>% 
  mutate(Sample = str_extract(bins, "Sample[0-9]+")) %>% 
  group_by(Sample) %>% 
  tally

## MAG statistics
summary %>% 
  filter(bins %in% MAGs) %>% 
  select(total_length, num_contigs, percent_completion, percent_redundancy) %>% 
  gather(parameter, value) %>% 
  ggplot(aes(x = parameter, y = value)) +
  geom_violin() +
  facet_grid(rows = vars(parameter), scales = "free")

# Read bins coverage
coverage <- bind_rows(read_delim("Sample01.mean_coverage.txt", delim = "\t"),
                      read_delim("Sample02.mean_coverage.txt", delim = "\t"),
                      read_delim("Sample03.mean_coverage.txt", delim = "\t"),
                      read_delim("Sample04.mean_coverage.txt", delim = "\t"))

# Read bins detection
detection <- bind_rows(read_delim("Sample01.detection.txt", delim = "\t"),
                       read_delim("Sample02.detection.txt", delim = "\t"),
                       read_delim("Sample03.detection.txt", delim = "\t"),
                       read_delim("Sample04.detection.txt", delim = "\t"))

# Read GTDB taxonomy
GTDB <- bind_rows(read_delim("gtdbtk.ar122.summary.tsv",  delim = "\t") %>% mutate(red_value = as.numeric(red_value)),
                  read_delim("gtdbtk.bac120.summary.tsv", delim = "\t") %>% mutate(red_value = as.numeric(red_value))) %>% 
  rename(bins = user_genome) %>% 
  mutate(bins = str_remove(bins, "-contigs"))

# Read annotation
annotation <- bind_rows(read_delim("Sample01.gene_annotation.txt", delim = "\t") %>% mutate(Sample = "Sample01"),
                        read_delim("Sample02.gene_annotation.txt", delim = "\t") %>% mutate(Sample = "Sample02"),
                        read_delim("Sample03.gene_annotation.txt", delim = "\t") %>% mutate(Sample = "Sample03"),
                        read_delim("Sample04.gene_annotation.txt", delim = "\t") %>% mutate(Sample = "Sample04")) %>% 
  rename(gene_function = `function`)

# Read list of gene calls per split
gene_calls <- bind_rows(read_delim("Sample01.genes_per_split.txt", delim = "|") %>% mutate(Sample = "Sample01"),
                        read_delim("Sample02.genes_per_split.txt", delim = "|") %>% mutate(Sample = "Sample02"),
                        read_delim("Sample03.genes_per_split.txt", delim = "|") %>% mutate(Sample = "Sample03"),
                        read_delim("Sample04.genes_per_split.txt", delim = "|") %>% mutate(Sample = "Sample04"))

# Read list of splits per bin
splits <- bind_rows(read_delim("Sample01.splits_per_bin.txt", delim = "|") %>% mutate(Sample = "Sample01"),
                    read_delim("Sample02.splits_per_bin.txt", delim = "|") %>% mutate(Sample = "Sample02"),
                    read_delim("Sample03.splits_per_bin.txt", delim = "|") %>% mutate(Sample = "Sample03"),
                    read_delim("Sample04.splits_per_bin.txt", delim = "|") %>% mutate(Sample = "Sample04"))


##### GTDB TAXONOMY #####

GTDB %>% 
  filter(bins %in% MAGs) %>% 
  select(classification) %>% 
  separate(classification, into = c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ";") %>% 
  # group_by(Domain, Phylum) %>%
  group_by(Phylum, Genus) %>%
  tally %>% 
  # ggplot(aes(x = Phylum, y = n)) +
  ggplot(aes(x = Genus, y = n)) +
  geom_bar(stat = "identity") +
  # facet_grid(cols = vars(Domain), space = "free", scales = "free_x") +
  facet_grid(cols = vars(Phylum), space = "free", scales = "free_x") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1), axis.title = element_blank())


##### COVERAGE & DETECTION #####

p1 <- coverage %>% 
  filter(bins %in% MAGs) %>% 
  gather(Sample, coverage, -bins) %>% 
  mutate(Sample = str_replace(Sample, "SAMPLE", "Sample")) %>% 
  left_join(metadata) %>% 
  left_join(GTDB) %>% 
  separate(classification, into = c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ";") %>% 
  ggplot(aes(x = bins, y = coverage, fill = Ecosystem)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(rows = vars(Sample), cols = vars(Domain, Phylum), scales = "free_x", space = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5), axis.title = element_blank()) +
  labs(title = "Coverage")

p2 <- detection %>% 
  filter(bins %in% MAGs) %>% 
  gather(Sample, detection, -bins) %>% 
  mutate(Sample = str_replace(Sample, "SAMPLE", "Sample")) %>% 
  left_join(metadata) %>% 
  left_join(GTDB) %>% 
  separate(classification, into = c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ";") %>% 
  ggplot(aes(x = bins, y = detection, fill = Ecosystem)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(rows = vars(Sample), cols = vars(Domain, Phylum), scales = "free_x", space = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5), axis.title = element_blank()) +
  labs(title = "Detection")

p1 + p2 +
  plot_layout(guides = 'collect', nrow = 2) & theme(legend.position = 'bottom')

ggsave("MAGs_coverage_detection.pdf", scale = 2)

# Coverage summed by phylum
coverage %>% 
  filter(bins %in% MAGs) %>% 
  gather(Sample, coverage, -bins) %>% 
  mutate(Sample = str_replace(Sample, "SAMPLE", "Sample")) %>% 
  left_join(metadata) %>% 
  left_join(GTDB) %>% 
  separate(classification, into = c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ";") %>% 
  group_by(Sample, Ecosystem, Domain, Phylum) %>% 
  mutate(coverage = sum(coverage)) %>% 
  ggplot(aes(x = Phylum, y = coverage, fill = Ecosystem)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(rows = vars(Sample), cols = vars(Domain), scales = "free_x", space = "free") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5), axis.title = element_blank()) +
  labs(title = "Coverage")


##### SEARCH ANNOTATIONS #####

# Nitrous oxide reductase
df <- annotation %>% 
  filter(str_detect(accession, "COG3256") | str_detect(accession, "K00376")) %>% 
  left_join(gene_calls) %>% 
  left_join(splits) %>% 
  select(bins) %>% 
  left_join(GTDB)

# Nitrite reductase
annotation %>% 
  filter(str_detect(accession, "K00368")) %>% 
  left_join(gene_calls) %>% 
  left_join(splits) %>% 
  select(bins) %>% 
  left_join(GTDB)

# Nitrogenase
annotation %>% 
  filter(str_detect(accession, "COG1348")) %>% 
  left_join(gene_calls) %>% 
  left_join(splits) %>% 
  select(bins) %>% 
  left_join(GTDB)

