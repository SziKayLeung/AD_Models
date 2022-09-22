## ----------Script-----------------
##
## Script name: 
##
## Purpose of script: Comparison of blow5 and fast5 ONT format 
##
## Author: Szi Kay Leung
##
## Email: S.K.Leung@exeter.ac.uk
##
## ----------Notes-----------------
##
## 
##   
##
##

## ---------- packages ----------------

suppressMessages(library("dplyr"))
suppressMessages(library("stringr"))
suppressMessages(library("ggplot2"))


## ---------- input file ----------------

num <- read.table("/gpfs/mrc0/projects/Research_Project-MRC148213/sl693/AD_Models/A_ONT_Whole_Genome/1_raw/blow5_fast5_num.o")
colnames(num) = c("size","files")

# generate columns for plotting
num <- num %>% mutate(dataset = word(num$files,c(-3),sep = fixed("/")),
               Barcode = word(num$files,c(-2),sep = fixed("/")), 
               format = word(num$files,c(-1),sep = fixed("/")),
               dataset_barcode = paste0(dataset,"_",Barcode),
               size = as.numeric(str_replace(size,"G","")))


## ---------- Plots ----------------

# p1 = file size between dataset in fast5 and blow5 format
p <- ggplot(num, aes(x = format, y = size)) + 
  geom_boxplot() + geom_point(aes(colour = Barcode)) + facet_grid(~dataset) + 
  labs(y = "File size (Gb)", x = "ONT raw read format")

p