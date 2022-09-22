#!/bin/bash
#SBATCH --export=ALL # export all environment variables to the batch job
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel queue
#SBATCH --time=100:00:00 # maximum walltime for the job
#SBATCH -A Research_Project-MRC148213 # research project to submit under
#SBATCH --nodes=1 # specify number of nodes
#SBATCH --ntasks-per-node=16 # specify number of processors per node
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=sl693@exeter.ac.uk # email address
#SBATCH --array=0-3 # 4 barcodes 
#SBATCH --output=2_basecall-%A_%a.o
#SBATCH --error=2_basecall-%A_%a.e

#-----------------------------------------------------------------------#
## print start date and time
echo Job started on:
date -u

## call config and functions script 
module load Miniconda2
source /gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/Nanopore/Whole_Genome/ONT_Mouse_Genome.config
source /gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/Nanopore/Whole_Genome/ONT_methylation_functions.sh
source /gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/Nanopore/Whole_Genome/ONT_SV_functions.sh

run_SV A9

DATASET=(20200929_1506_2G_PAE62275_de0204be)
BARCODE=(barcode09 barcode10 barcode11 barcode12)
DATASET_SUBNAME=(A)
BARCODE_SUBNAME=(9 10 11 12)


for d in ${DATASET[@]}; do  
  echo "from dataset: $d"
  for count in {0..3}; do 
    final_sample_name=$DATASET_SUBNAME${BARCODE_SUBNAME[count]}"_merged"
    #run_merge $BASECALL_DIR/$d/${BARCODE[count]}/pass/ $BASECALL_DIR $DATASET_SUBNAME${BARCODE_SUBNAME[count]}"_merged"
    #run_minimap $DATASET_SUBNAME${BARCODE_SUBNAME[count]}"_merged" 
    #run_index $BASECALL_DIR/$d/${BARCODE[count]}
    ## run_modam2bed <basecalled_dir> <output_dir> <output_name>
    #run_modam2bed $BASECALL_DIR/$d/${BARCODE[count]} $ROOT_WKD/3_methylation $DATASET_SUBNAME${BARCODE_SUBNAME[count]}.methylbed
    
    # grep fasta sequence for transgene sequence
    #seqtk seq -a $BASECALL_DIR/$final_sample_name.fastq > $BASECALL_DIR/$final_sample_name.fasta
    # mapt 
    #python $GENERALFUNC/find_human_MAPT.py $BASECALL_DIR/$final_sample_name.fasta $final_sample_name"_hmapt" $ROOT_WKD/SV/5_transgene MAPT &> $final_sample_name.hmapt.log
    python $GENERALFUNC/find_human_MAPT.py $BASECALL_DIR/$final_sample_name.fasta $final_sample_name"_happ" $ROOT_WKD/SV/5_transgene APP &> $final_sample_name.hmapt.log
  done
done

run_index $BASECALL_DIR/$d/${BARCODE[count]}
run_modam2bed $BASECALL_DIR/20200929_1506_2G_PAE62275_de0204be/barcode12 $ROOT_WKD/3_methylation A12

GENERALFUNC=/gpfs/mrc0/projects/Research_Project-MRC148213/sl693/scripts/General/2_Transcriptome_Annotation

# script.py <path/input.fasta> <outputname> <path/outputdir>
mkdir -p $ROOT_WKD/SV/5_transgene
seqtk seq -a $BASECALL_DIR/A12_merged.fastq > $ROOT_WKD/SV/5_transgene/A12_merged.fasta
python $GENERALFUNC/find_human_MAPT.py $ROOT_WKD/SV/5_transgene/A12_merged.fasta A12_hmapt $ROOT_WKD/SV/5_transgene 





