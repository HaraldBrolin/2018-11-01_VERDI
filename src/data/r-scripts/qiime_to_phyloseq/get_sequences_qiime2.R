library(tidyverse)
library(dada2)
library(reader)
library(phyloseq)
library(Biostrings)
library(here)

set.seed(2018)

# To get the ref_seqs use readDNAStringSet, hard to access the sequences

ref_seq <-
  read_csv(file = here("../../../data/processed/reference_sequences/ref_seq.csv"))

ref_test <- 
  readDNAStringSet(filepath = here("../../../data/processed/reference_sequences/sequences.fasta"))

seqs_test <-
  ref_test

seqs <-
  ref_seq$sequence %>%
  as.vector()

#Taxonomic assignment (from https://benjjneb.github.io/dada2/assign.html)
# assignTaxonomy(...) implements the RDP naive Bayesian classifier method described in Wang et al. 2007. 
# In short, the kmer profile of the sequences to be classified are compared against the kmer profiles of 
# all sequences in a training set of sequences with assigned taxonomies. The reference sequence with the 
# most similar profile is used to assign taxonomy to the query sequence, and then a bootstrapping approach 
# is used to assess the confidence assignment at each taxonomic level.

# minBoot is the minimum bootstrapping support required to return a taxonomic classification.
# The original paper recommended a threshold of 50 for sequences of 250nts or less (as these are)

# taxa <- 
#   assignTaxonomy(seqs, 
#                  refFasta = "../../../data/external/silva_nr_v132_train_set.fa", 
#                  minBoot = 50,
#                  multithread=TRUE,
#                  verbose = TRUE)

# saveRDS(taxa, "taxa_species.rds")

# genus.species <- 
#   assignSpecies(seqs,
#                 refFasta = "../../../data/external/silva_species_assignment_v132.fa",
#                 allowMultiple = TRUE,
#                 verbose = TRUE)
# 
# unname(genus.species)

# taxa_species <- 
#   addSpecies(taxa,
#              refFasta = "../../../data/external/silva_species_assignment_v132.fa",
#              verbose=TRUE)
# 
# saveRDS(taxa_species, here("qiime_to_phyloseq", "taxa_species.rds"))
taxa_species  <-
  read_rds(path = here("qiime_to_phyloseq/taxa_species.rds"))


#--------------------------------------------- Import the asv_table ---------------------------------

#------------------ OTU-table

asv <- # Imports the tsv-formatted otu-table
  read_delim(file = here("../../../data/processed/biom_table/biom_table.txt"),
             "\t", escape_double = FALSE, trim_ws = TRUE, skip = 1)

names(asv)[1] <- "OTUID" 

asv_table <- asv[,2:ncol(asv)] %>% as.matrix()
rownames(asv_table) <- asv$OTUID

asv_phylo <- # Create the otu_table phyloseq-object
  otu_table(asv_table, taxa_are_rows = TRUE) # 

#--------------- Ref-seqs
ref_seqs <- 
  readDNAStringSet(filepath = here("../../../data/processed/reference_sequences/sequences.fasta"))

# ref_seqs_taxa <- # Imort the ref_seqs
#   read_csv("/media/harald/DATA/ht-18/2018-10-25_VERDI_mock/data/processed/reference_sequenceces/ref_seq.csv")
# 
# # The order of the sequences are the same after the calssification
# (ref_seqs@ranges@NAMES == ref_seq$md5sum) %>% sum == length(taxa_species) / 7

#--------------- Tree

tree <- # Reads the taxonomic tree generated in qiime2
  read_tree(here("../../../data/processed/rooted_tree/tree.nwk"))

#------------- Taxonomy table
tax_table <-
  taxa_species %>%
  as.matrix()

rownames(tax_table) <- 
  ref_seqs@ranges@NAMES

tax_table <- 
  tax_table(tax_table)

#------------ Metadata
metadata <- 
  read_delim(file = here("../../../data/metadata/metadata.tsv"), 
             "\t",escape_double = FALSE, trim_ws = TRUE)

phy_meta <-
  metadata %>%
  select(-`#SampleID`) %>%
  sample_data()

sample_names(phy_meta) <- metadata$`#SampleID`

physeq <- 
  phyloseq(asv_phylo,
           ref_seqs,
           tree,
           phy_meta,
           tax_table)

saveRDS(physeq, here("qiime_to_phyloseq", "physeq_mock.rds"))


 