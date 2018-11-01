library(readxl)
library(tidyverse)

verdi <- read_excel("../../../data/metadata/verdi.xlsx")

lid_df <- verdi %>% select(id,fs_bas,fs_veg,fs_wash,fs_meat)
lid_df <- lid_df %>% gather(fs, p_id, 2:5) %>% arrange(id)

verdi_df <- verdi %>% select(-fs_bas,-fs_veg,-fs_wash,-fs_meat)
joint_df <- left_join(lid_df, verdi_df, by = c("id" = "id"), copy = FALSE, suffix = c(".x", ".y"))

joint_df <- joint_df %>% select(p_id, everything()) %>% as.data.frame()

joint_df <- joint_df %>% filter(p_id != "NA")

joint_df$p_id <- # remove space and - for each element
  lapply(joint_df$p_id, function(x) gsub(" ", "", x)) %>%
  lapply(., function(x) gsub("-", "", x)) %>%
  unlist()

names(joint_df)[1:2] <- c("SampleID", "patient") 


test_samples <- c("16586371","16586412","16586630",
                 "16623640","16623692","16623959")

joint_df <- joint_df %>% filter(SampleID %in% test_samples)

# Add the mock row, impute values 
joint_df <- rbind(joint_df, joint_df[3,])

joint_df$SampleID[nrow(joint_df)] <- "Mock"

write_tsv(joint_df, path = "../../../data/metadata/metadata.tsv")

# Remember to add # inront of first column name, can also use the google sheets plugin keemmei to validate the metadata-file