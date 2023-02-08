#!/bin/sh

module purge
module load Anaconda3/2021.11
module load BEDTools/2.29.2-GCC-9.3.0

source deactivate
source activate final-abc-env

peak_file=$1 
bam_file_list=$2
outdir=$3
sample=$4

chrom_sizes="data/derived_data/Tables/1-1.ABC_algorithm_TSS_annotation/Homo_sapiens.GRCh37.75.chr_sizes"
block_file="data/derived_data/Tables/1-1.ABC_algorithm_TSS_annotation/ENCFF001TDO_blocklisted_regions_GRCh37.ensembl.sort.bed"
include_file="data/derived_data/Tables/1-1.ABC_algorithm_TSS_annotation/Homo_sapiens.GRCh37.75.TSS_500bp.sort.bed"

instruction="python ~/software/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py \
    --narrowPeak $peak_file \
    --bam $bam_file_list \
    --outDir ${outdir}/Peaks/${sample} \
    --chrom_sizes $chrom_sizes \
    --regions_blocklist $block_file \
    --regions_includelist $include_file \
    --peakExtendFromSummit 275 \
    --nStrongestPeaks 175000"

echo $instruction

python ~/software/ABC-Enhancer-Gene-Prediction/src/makeCandidateRegions.py \
    --narrowPeak $peak_file \
    --bam $bam_file_list \
    --outDir ${outdir}/Peaks/${sample} \
    --chrom_sizes $chrom_sizes \
    --regions_blocklist $block_file \
    --regions_includelist $include_file \
    --peakExtendFromSummit 275 \
    --nStrongestPeaks 175000

source deactivate