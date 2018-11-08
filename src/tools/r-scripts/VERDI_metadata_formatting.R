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

# ---------------------- Change the correct names

joint_df$SampleID[which(joint_df$SampleID == "verdi1171109")] <- "verdi-1-"
joint_df$SampleID[which(joint_df$SampleID == "verdi3171108")] <- "verdi-3-"
joint_df$SampleID[which(joint_df$SampleID == "verdi6171108")] <- "verdi-6-"
joint_df$SampleID[which(joint_df$SampleID == "verdi8171108")] <- "verdi-8-"
joint_df$SampleID[which(joint_df$SampleID == "verdi11171108")] <- "verdi-11"
joint_df$SampleID[which(joint_df$SampleID == "16415940")] <- "16423996"

# ------------------------- Add the mock sample
add_rows <- joint_df[1,]
add_rows$SampleID <- "Mock"
add_rows$patient <-"mock"
joint_df <- rbind(joint_df, add_rows)

#-------------------------- Remove missing samples
joint_df <- joint_df %>% filter(!(SampleID %in% c("16316632", "16472795", "16528868")))

# -------------- ---------- Check missing
manifest_file <- read_csv("/media/harald/DATA/ht-18/2018-11-01_VERDI/data/metadata/manifest_file")

man_names <- manifest_file$`sample-id` %>% unique()
meta_names <- joint_df$SampleID

man_names[which(!(man_names %in% meta_names))] # "16423996" Should be 16415940 
meta_names[which(!(meta_names %in% man_names))] # "16316632", "16472795", "16528868" .... and "16415940"

#------------------------- Write to file

write_tsv(joint_df, path = "../../../data/metadata/metadata.tsv")


# joint_df <- joint_df %>% filter(!SampleID %in% c("16316632", "16472795", "16415940", "16528868")) 
# 
# 
# write_tsv(joint_df, path = "../../../data/metadata/metadata.tsv")

# Remember to add # inront of first column name, can also use the google sheets plugin keemmei to validate the metadata-file