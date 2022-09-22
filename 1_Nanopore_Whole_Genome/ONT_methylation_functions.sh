# run_guppy_and_index <input_dir> <output_dir>
run_guppy_and_index(){

  # variables 
  input_dir=$1
  output_dir=$2
  
  # GUPPY_FILE, GENOME_FASTA defined in config file

  source activate nanopore
  echo "Basecalling using GUPPY with $GUPPY_FILE and $GENOME_FASTA"
  cd $output_dir
  guppy_basecaller -i $input_dir -s $output_dir -c $GUPPY_FILE --bam_out --recursive --align_ref $GENOME_FASTA
  
  echo "Index bam files that are passed"
  cd $output_dir/pass/
  for i in *bam*; do samtools index $i; done
}

# run_index <index_dir>
run_index(){
  
  source activate nanopore
  cd $1/pass/
  for i in *bam*; do samtools index $i; done
}

# run_moda2b <basecalled_dir> <output_dir> <output_name>
run_modam2bed(){
  
  # variables 
  basecalled_dir=$1
  output_dir=$2
  output_name=$3
  
  source activate modbam2bed
  cd $output_dir
  ls $basecalled_dir/pass/*.bam
  modbam2bed -e -m 5mC --cpg -t 4 $GENOME_FASTA $basecalled_dir/pass/*.bam > $output_name
}

