# 1) run_merge <input_dir> <output_dir> <sample_output_name>
# output: <sample_output_name>.merged.fastq in $RAWDATA (defined in functions script)
run_merge(){
  
  # variables 
  input_dir=$1
  output_dir=$2
  output_name=$3
  
  cd $input_dir
  echo "Merging following fastq files"
  count=`ls -1 *.gz 2>/dev/null | wc -l`
  if [ $count != 0 ]; then 
    FASTQ="$(ls *fastq.gz*)" 
    END_PREFIX=".fastq.gz"
  else
    FASTQ="$(ls *fastq*)" 
    END_PREFIX=".fastq"
  fi
  echo $FASTQ
  echo $output_dir/$output_name$END_PREFIX
  if [ -f $output_dir/$output_name.fastq.gz ];then
    echo "$output_name.fastq already exists; Merging not needed"
  else
    cat $FASTQ > $output_dir/$output_name$END_PREFIX
    echo "Merging successful"
  fi
}

count=`ls -1 *.gz 2>/dev/null | wc -l`
if [ $count != 0 ]; then 
  FASTQ="$(ls *fastq.gz*)" 
  END_PREFIX=".fastq.gz"
else
  FASTQ="$(ls *fastq*)" 
  END_PREFIX=".fastq"
fi

# run_minimap <sample> 
run_minimap(){
  
  # variables 
  sample=$1
  
  mkdir -p $ROOT_WKD/SV $ROOT_WKD/SV/3_minimap
  
  source activate nanopore
  cd $ROOT_WKD/SV/3_minimap
  minimap2 --MD -a -t 8 $GENOME_FASTA $BASECALL_DIR/$sample"_merged.fastq" > $sample.sam 2> $sample"_minimap2.log"
  
  # convert sam to bam, sort and index
  samtools view -S -b $sample.sam > $sample.bam
  samtools sort $sample.bam -o $sample.sorted.bam
  samtools index $sample.sorted.bam
}

# run_SV <sample>
run_SV(){
  
  # variables 
  sample=$1
  
  mkdir -p $ROOT_WKD/SV/4_sniffles 
  
  source activate modbam2bed 
  cd $ROOT_WKD/SV/4_sniffles
  sniffles -i $ROOT_WKD/SV/3_minimap/$sample.sorted.bam -v $sample.vcf -t 4 --reference $GENOME_FASTA
  
  # sort sniffes output
  cat $sample.vcf | awk '$1 ~ /^#/ {print $0;next} {print $0 | "sort -k1,1 -k2,2n"}' > $sample"_sorted.vcf"
}