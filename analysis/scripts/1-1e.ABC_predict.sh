#!/bin/sh

module purge
module load Anaconda3/2021.11
module load BEDTools/2.29.2-GCC-9.3.0

source deactivate
source activate final-abc-env

outdir=$1

enhancers="data/derived_data/Tables/1-3.ABC_algorithm/Neighborhoods/EnhancerList.txt"
genes="data/derived_data/Tables/1-3.ABC_algorithm/Neighborhoods/GeneList.txt"
chrom_sizes="data/derived_data/Tables/1-1.ABC_algorithm_TSS_annotation/Homo_sapiens.GRCh37.75.chr_sizes"

instruction="python  ~/software/ABC-Enhancer-Gene-Prediction/src/predict.py \
    --enhancers $enhancers \
    --genes $genes \
    --chrom_sizes $chrom_sizes \
    --score_column powerlaw.Score \
    --threshold .022 \
    --outdir $outdir \
    --make_all_putative"

echo $instruction

python  ~/software/ABC-Enhancer-Gene-Prediction/src/predict.py \
    --enhancers $enhancers \
    --genes $genes \
    --chrom_sizes $chrom_sizes \
    --score_column powerlaw.Score \
    --threshold .022 \
    --outdir $outdir \
    --make_all_putative
    
source deactivate