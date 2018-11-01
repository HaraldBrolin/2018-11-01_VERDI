library(readxl)
library(tidyverse)

time_df <- read_excel("~/Documents/2018-10-15_VERDI/src/data/verdi_lid_time.xlsx",
                        col_types = c("text", "text"))

# verdi <- read_excel("~/Documents/2018-10-15_VERDI/src/data/verdi.xlsx")

time_df$Provtagningstid <- as.POSIXct(time_df$Provtagningstid)

time_df$LID <- gsub(" ", "", time_df$LID)
time_df$LID <- gsub("-", "", time_df$LID)

time_df %>% arrange(Provtagningstid) %>% print(n = 113)

metadata_test <- c("16207806", "16207803", "16207802", "16211354", "16207776")

write_tsv(time_df[time_df$LID %in% metadata_test,]