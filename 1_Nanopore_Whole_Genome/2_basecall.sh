#!/bin/bash
#SBATCH --export=ALL # export all environment variables to the batch job
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel queue
#SBATCH --time=500:00:00 # maximum walltime for the job
#SBATCH -A Research_Project-MRC148213 # research project to submit under
#SBATCH --nodes=4 # specify number of nodes
#SBATCH --ntasks-per-node=16 # specify number of processors per node
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=sl693@exeter.ac.uk # email address
#SBATCH --array=0-3 # 4 barcodes 
#SBATCH --output=2_basecall-%A_%a.o
#SBATCH --error=2_basecall-%A_%a.e

# 01/08/2022: Basecalling ONT raw data 
# 08/08/2022: Rerunning with one dataset (finished 10/10/2022)

#-----------------------------------------------------------------------#
## print start date and time
echo Job started on:
date -u

## call config and functions script 
source /gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/Nanopore/Whole_Genome/ONT_Mouse_Genome_minor2.config
source /gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/Nanopore/Whole_Genome/ONT_methylation_functions.sh
source /gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/Nanopore/Whole_Genome/ONT_SV_functions.sh

## run batch 
bc=${BARCODE[${SLURM_ARRAY_TASK_ID}]}
bc_sub=${BARCODE_SUBNAME[${SLURM_ARRAY_TASK_ID}]}

module load Miniconda2

#-----------------------------------------------------------------------#
echo "Processing with ${bc}"

counter=0
for d in ${DATASET[@]}; do  
  echo "from dataset: $d"
  d_sub=${DATASET_SUBNAME[counter]}
  
  mkdir -p $BASECALL_DIR/$d $BASECALL_DIR/$d/${bc}
  
  # run_guppy_and_index <input_dir> <output_dir>  
  run_guppy_and_index $RAW_SLOW5_DIR/$d/${bc}/fast5 $BASECALL_DIR/$d/${bc}
  
  # run_merge <input_dir> <output_dir> <sample_output_name>
  echo "Merging files to $dsub"
  run_merge $BASECALL_DIR/$d/${bc}/pass/ $BASECALL_DIR $d_sub$bc_sub"_merged"
  
  counter=$((counter+1))
done  


