#!/bin/sh

module purge
module load Anaconda3/2021.11

source deactivate
source activate abc-macs-py2.7

bam_file=$1
sample=$2
outdir=$3

echo $bam_file


faidx_file="Homo_sapiens.GRCh37.75.dna_sm.primary_assembly.fa.fai"


instruction="macs2 callpeak \
    -t $bam_file \
    --name ${sample}.macs2 \
    -f BAM \
    -g hs \
    -p 0.1 \
    --call-summits \
    --outdir ${outdir}/Peaks/ "

echo $instruction

macs2 callpeak \
    -t $bam_file \
    --name ${sample}.macs2 \
    -f BAM \
    -g hs \
    -p 0.1 \
    --call-summits \
    --outdir ${outdir}/Peaks/ 

source deactivate

module purge
module load BEDTools/2.29.2-GCC-9.3.0

#Sort narrowPeak file
instruction2="bedtools sort \
    -faidx $faidx_file \
    -i ${outdir}/Peaks/${sample}.macs2_peaks.narrowPeak > ${outdir}/Peaks/${sample}.macs2_peaks.narrowPeak.sorted"

echo $instruction2

bedtools sort \
    -faidx $faidx_file \
    -i ${outdir}/Peaks/${sample}.macs2_peaks.narrowPeak > ${outdir}/Peaks/${sample}.macs2_peaks.narrowPeak.sorted

module purge