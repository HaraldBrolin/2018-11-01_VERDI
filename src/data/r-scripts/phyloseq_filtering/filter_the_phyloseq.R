library(tidyverse)
library(dada2)
library(phyloseq)
library(Biostrings)
library(here)
library(gridExtra)
library(ape)

df <- readRDS(file = here("qiime_to_phyloseq/physeq_mock.rds"))

df@sam_data$patient

# Look at the sparsity

number_of_zeros <- # Number of zeros
  apply(df@otu_table, 2, function(x) x == 0) %>%
  sum()

total_number_of_ASVs <- # Total number of ASVs
  df@otu_table %>% length()

number_of_zeros / total_number_of_ASVs # 92% sparsity

total_number_of_reads <- # Get the total number of reads
  apply(df@otu_table, 2,sum) %>% sum()

mean_sequence_depth <- # Get the mean sequence depth per sample
  sample_sums(df) %>% mean

asv_occurence <- # Get the number of sample of which an asv occurs in
  apply(df@otu_table != 0 , 1, sum)

mean_asv_abundence <- 
  taxa_sums(df) / asv_occurence

refseq(df) %>% nchar %>% as.data.frame() %>% table # Get the different read lengths

#filter limit according tohttps://www.nature.com/articles/nmeth.2276 0.005% conservative if you don't have a mock
# 
# filter_limit <- 
#   mean_sequence_depth * 0.00005
# # Keep all ASVs with more than 37 reads
filter_limit <- 
    total_number_of_reads * 0.00005 
# ------------------------ Filter
taxa_to_keep <- 
  taxa_sums(df) > filter_limit # Too lenient 37 reads: 25 ASVs

# taxa_to_keep <- 
#   mean_asv_abundence > filter_limit # too lenient 25 

df_filtered <- 
  prune_taxa(taxa_to_keep, df)

# ------------------------- Verify mock

evaluate_filtering <- function(filtered){
  asv_occurence <- # Get the number of sample of which an asv occurs in
    apply(filtered@otu_table != 0 , 1, sum)
  asv_table <- 
    cbind(asv_occurence,
          filtered@otu_table %>% taxa_sums()) %>% 
    `colnames<-`(c("occurence", "abundance")) %>% 
    as.data.frame()
  
  plot_asv <- 
    ggplot(asv_table, aes(x = occurence, y = abundance)) +
    geom_point() +
    scale_y_log10()
    
  mock_df <- 
    prune_samples("Mock", df_filtered) %>% 
    prune_taxa(taxa_sums(.) > 0, .)
  
  mock_table <- 
    cbind(mock_df@tax_table[,5:7],
          mock_df@otu_table) %>%
    as.data.frame() %>% 
    arrange(Genus)
  
  return(list(plot_asv, mock_df, mock_table))
}

eval <- evaluate_filtering(df_filtered)
eval[1]
eval[2] # Does not work
eval[3]

# ------------------ chwck for read length

refseq(df_filtered) %>% nchar %>% as.data.frame() %>% table


#--------------------------------------- Write to file

df_filtered@sam_data$SampleName <-  rownames(df_filtered@sam_data)                                                         # Add the sample ID as a column
df_pruned <- subset_samples(df_filtered, SampleName != "Mock") 
df_processed <- prune_taxa(taxa_sums(df_pruned) != 0, df_pruned)  

write_rds(df_processed, here("physeq.rds"))



