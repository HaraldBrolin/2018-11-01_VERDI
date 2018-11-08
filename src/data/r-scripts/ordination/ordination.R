library(tidyverse)
library(dada2)
library(phyloseq)
library(Biostrings)
library(here)
library(gridExtra)

df <- readRDS(file = here("physeq.rds"))

u_unifrac <- ordinate(df, "PCoA", "unifrac", weighted = FALSE)

w_unifrac <- ordinate(df, "PCoA", "unifrac", weighted = TRUE)

bray <- ordinate(df, "PCoA", "bray")

theme_set(theme_bw())

# ------------------------------------------- u-unifrac
p1 <- ggplot(u_unifrac$vectors[,1:2] %>%
               as.data.frame() %>%
               cbind(df@sam_data$patient,  df@sam_data$fs),
             aes(x =  Axis.1, y = Axis.2)) +
  geom_text(aes(label = df@sam_data$patient)) +
  ggtitle("Unweighted UniFrac")

p2 <- 
  ggplot(u_unifrac$vectors[,1:2] %>%
           as.data.frame() %>%
           cbind(df@sam_data$patient,  df@sam_data$fs),
         aes(x =  Axis.1, y = Axis.2)) +
  geom_point(aes(color = df@sam_data$fs)) +
  geom_line(alpha = 0.3, aes(group = df@sam_data$patient)) +
  theme(legend.title = element_blank()) +
  ggtitle("Unweighted UniFrac") 

grid.arrange(p1, p2, widths = c(1, 1.2), ncol = 2)

#------------------------------------------------ bray
p1 <- ggplot(bray$vectors[,1:2] %>%
               as.data.frame() %>%
               cbind(df@sam_data$patient,  df@sam_data$fs),
             aes(x =  Axis.1, y = Axis.2)) +
  geom_text(aes(label = df@sam_data$patient)) +
  ggtitle("Bray-Curtis")

p2 <- ggplot(bray$vectors[,1:2] %>%
               as.data.frame() %>%
               cbind(df@sam_data$patient,  df@sam_data$fs),
             aes(x =  Axis.1, y = Axis.2)) +
  geom_point(aes(color = df@sam_data$fs)) +
  geom_line(alpha = 0.3, aes(group = df@sam_data$patient)) +
  ggtitle("Bray-Curtis") +
  theme(legend.title = element_blank()) 

grid.arrange(p1, p2, widths = c(1, 1.2), ncol = 2)

# -------------------------------------------- w-unifrac
p1 <- ggplot(w_unifrac$vectors[,1:2] %>%
               as.data.frame() %>%
               cbind(df@sam_data$patient,  df@sam_data$fs),
             aes(x =  Axis.1, y = Axis.2)) +
  geom_text(aes(label = df@sam_data$patient)) +
  ggtitle("Weighted UniFrac")

p2 <- ggplot(w_unifrac$vectors[,1:2] %>%
               as.data.frame() %>%
               cbind(df@sam_data$patient,  df@sam_data$fs),
             aes(x =  Axis.1, y = Axis.2)) +
  geom_point(aes(color = df@sam_data$fs)) +
  geom_line(alpha = 0.3, aes(group = df@sam_data$patient)) +
  ggtitle("Weighted UniFrac") +
  theme(legend.title = element_blank()) 

grid.arrange(p1, p2, widths = c(1, 1.2), ncol = 2)

# ........................................................................................................
# ggplot(w_unifrac$vectors[,1:2] %>%
#          as.data.frame() %>%
#          cbind(df@sam_data$patient),
#        aes(x =  Axis.1, y = Axis.2)) +
#   geom_text(aes(label = df@sam_data$patient, color = df@sam_data$fs))
# 
# 
# ggplot(bray$vectors[,1:2] %>%
#          as.data.frame() %>%
#          cbind(df@sam_data$patient),
#        aes(x =  Axis.1, y = Axis.2)) +
#   geom_text(aes(label = df@sam_data$patient, color = df@sam_data$fs))
