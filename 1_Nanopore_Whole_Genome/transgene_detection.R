## ---------- Script -----------------
##
## Script name: 
##
## Purpose of script: Downstream of grepping transgene sequences
##
## Author: Szi Kay Leung
##
## Email: S.K.Leung@exeter.ac.uk
##
## ---------- Notes -----------------
##
## 
##   
##
## 


## ---------- Packages -----------------

suppressMessages(library("dplyr"))
suppressMessages(library("ggplot2"))


## ---------- Functions -----------------

# create empty lists into dataframe compatible for rbinding
change_others_to_dataframe <- function(x) {
  # If x is a data frame, do nothing and return x
  # Otherwise, return a data frame with 1 row of NAs
  if (is.data.frame(x)) {return(x)}
  else {return(setNames(data.frame(matrix(ncol = ncol(transgene_counts[[1]]), nrow = 1)),
                        names(transgene_counts[[1]])))}
}


## ---------- Input files -----------------

# files containing the number of reads that matched the sequences
input_dir = "/gpfs/mrc0/projects/Research_Project-MRC148213/sl693/AD_Models/A_ONT_Whole_Genome/SV/5_transgene"
files <- list.files(path = input_dir, pattern = "Ids.txt", full.names = T)

# read files including empty files
transgene_counts <- lapply(files, function(x) {if (!file.size(x) == 0) {read.table(x)}})
names(transgene_counts) <- list.files(path = input_dir, pattern = "Ids.txt")

# rBind all files including empty files
transgene_counts <- do.call(rbind, lapply(transgene_counts, change_others_to_dataframe))

# extract info from file name for downstream plotting
tdat <- transgene_counts %>% tibble::rownames_to_column(var = "filename") %>% 
  mutate(sample = word(filename,c(1), sep = fixed("_")),
         gene = str_replace(word(filename,c(3), sep = fixed("_")),".fasta",""),
         model = ifelse(sample %in% c("A11","A12"), "rTg4510","J20"),
         genotype = ifelse(sample %in% c("A9","A11"),"WT","TG"),
         detected = ifelse(!is.na(V1) == "TRUE",1,0))


# plot the number of transgene sequences detected by genotype and model
tdat %>% group_by(gene, model, genotype) %>% tally(detected) %>%
  ggplot(., aes(x = genotype, y = n, fill = gene)) + geom_bar(stat = "identity") + facet_grid(~model) + 
  labs(x = "Genotype", y = "Number of transgene sequence") + 
  scale_fill_discrete(name = "Transgene", labels = c("hAPP"," hMAPT"))
         