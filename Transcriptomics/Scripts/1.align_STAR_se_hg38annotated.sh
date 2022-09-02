### Working directory

cd "$(dirname "$0")"
pwd

### Binary paths...

sambamba='sambamba'
star='STAR'


### Genome path
genome="../Genome/Indexed/"

### In and out paths
fastqdir='../Fastq_files'
outdir='../Results/Alignment/Bam_files'
outdir2='../Results/Alignment/Reports'

### Number of threads
nbth="30"


################################################################################################################
# Alignment and convert


for file in $fastqdir/*.fastq.gz
do {


### Input files

fin1=$file

### Output files

fstar="${file##*/}"
fstar="${fstar/.fastq.gz/}"
fstar=$outdir/$fstar.

# Seed.
seed=1233


# Align with STAR
echo 'Aligning ' $file 'pairs with STAR...'
$star --genomeDir $genome \
      --readFilesIn $fin1 \
      --runThreadN $nbth \
      --runRNGseed $seed \
      --outFileNamePrefix $fstar \
      --outFilterMismatchNoverLmax 0.05 \
      --outReadsUnmapped Fastx \
      --readFilesCommand zcat


### Sambamba SAM to BAM and sort, interesting to pipe with bowtie run maybe...

tmpdir=$outdir

fsam="${fstar}"Aligned.out.sam
fbam="${fsam/.sam/.bam}"

echo 'Binarizing, sorting and indexing aligned output...'
$sambamba view  -S -f bam -t 15 -p $fsam -o $fbam
$sambamba sort -t 15 -p $fbam


### Rename sorted files to keep only one, seems that sambamba forces having the original and sorted files

#tmp="${fbam/.bam/}"
#fsbam=$tmp.sorted.bam

#rm $fsam
#rm $fbam
#mv $fsbam $fbam
#mv $fsbam.bai $fbam.bai


### Copy STAR logs with alignment statistics

falig="${fstar}"Log.final.out
falig2=$outdir2/"${falig##*/}"


} done


################################################################################################################
################################################################################################################
################################################################################################################
