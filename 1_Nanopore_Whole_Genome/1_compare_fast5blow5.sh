#!/bin/bash
#SBATCH --export=ALL # export all environment variables to the batch job
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel queue
#SBATCH --time=0:10:00 # maximum walltime for the job
#SBATCH -A Research_Project-MRC148213 # research project to submit under
#SBATCH --nodes=1 # specify number of nodes
#SBATCH --ntasks-per-node=16 # specify number of processors per node
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=sl693@exeter.ac.uk # email address


## ----------Script-----------------
## Purpose of script: compare the filesize between ONT blow5 and fast5 format
## 15/08/2022
## ----------Notes-----------------
## Dataset: AD mouse model ONT whole genome data
## ONT fast5 original data format, blow5 is latest publicly released community format 
## Blow5 format published as more efficient at storage and conversion 


## ---------- Input Variables -----------------

# contain raw files
rdir=/gpfs/mrc0/projects/Research_Project-MRC148213/sl693/AD_Models/A_ONT_Whole_Genome/1_raw
dataset=(20200807_1632_MC-110214_0_add313_506ffc5b 20200808_1450_1F_PAF13790_4c803d35 20200929_1506_2G_PAE62275_de0204be)
barcode=(barcode09 barcode10 barcode11 barcode12)


## ---------- Generate .txt file of sizes ----------------- 

# loop through each folder and extract the folder size
for i in ${dataset[@]}; do

  for bc in ${barcode[@]}; do
    du -h $rdir/$i/$bc/fast5
    du -h $rdir/$i/$bc/blow5
  done

done > $rdir/blow5_fast5_num.o


## ---------- Run rscript to generate plot -----------------
module load Miniconda2 
source activate sqanti2_py3
Rscript 1b_compare_fast5blow5.R

