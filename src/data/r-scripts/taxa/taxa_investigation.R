library("phyloseq")
library("ggplot2")
library("tidyverse")
library("gridExtra")
library("lubridate")

set.seed(2018)
df <- readRDS(file = "qiime_to_phyloseq/physeq.rds")

df@sam_data$SampleName <-  rownames(df@sam_data)

df <- subset_samples(df, SampleName == "Mock")
df <- prune_taxa(taxa_sums(df@otu_table) != 0, df)

# Order sequences from most abundant to least

lapply(df@refseq[ (df %>% otu_table() %>% order(decreasing = TRUE))], as.character)

# Alphabetical order of genus and species

df@tax_table[df@tax_table[,6] %>% order, 6:7]

df@tax_table[(df %>% otu_table() %>% order(decreasing = TRUE)), 6:7]

# Get the alpha-order and abundence
cbind(df@tax_table[(df@tax_table[,6] %>% order()), 6:7], df@otu_table[(df@tax_table[,6] %>% order())])