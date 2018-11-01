library("tidyverse")
library("knitr")

# Createa a dataframe based on 
create_data_frame <- function(regex_pattern){
  list_of_files <- 
    list.files(path = "../../../data/raw/", pattern = regex_pattern )
  df <- 
    data.frame(
      sample_id = list_of_files %>% as.character(),
      absolute_filepath = paste("$PWD/../../data/raw/", list_of_files, sep = ""),
      direction = sapply(list_of_files, direction),
      stringsAsFactors = FALSE,
      row.names = 1:(list_of_files %>% length())) 
}

# Get the direction dependet on _R1_ or __R2__
direction <- function(x){
  ifelse(grepl(pattern = "_R1_", x), "forward", "reverse")
}

names_df <- create_data_frame("(^[0-9]{4})")
names_df$sample_id <- sapply(names_df$sample_id, substr, 5, 12)

# verdi_df <- create_data_frame("(verdi)")
# verdi_df$sample_id <- sapply(strsplit(verdi_df$sample_id, "_"), "[", 1)

mock_df <- create_data_frame("(Mock)")
mock_df$sample_id <- sapply(strsplit(mock_df$sample_id, "-"), "[", 1)

# undetermined_df <- create_data_frame("(Undetermined)")
# undetermined_df$sample_id <- sapply(strsplit(undetermined_df$sample_id, "_"), "[", 1)

samples_df <- rbind(names_df, mock_df)

names(samples_df) <- NULL
print.data.frame(samples_df, row.names = FALSE)

write()

