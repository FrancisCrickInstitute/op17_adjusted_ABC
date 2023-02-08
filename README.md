# Activity-By-Contact model - adjusted step 1

We used the [Activity-By-Contact (ABC) model](https://doi.org/10.1038/s41588-019-0538-0) to identify enhancer-gene connections. The procedure we  used to define candidate enhancer regions differed from the original approach used by [Fulco et al. 2019](https://doi.org/10.1038/s41588-019-0538-0).

For the remaining steps we followed the [procedure described](https://github.com/broadinstitute/ABC-Enhancer-Gene-Prediction).

We defined candidate enhancer regions in two steps:

## Preparation of the required annotation file input:

To run the ABC model, the following annotation files are required:
* transcription start site bed file
* gene annotation bed file
* chromosome annotation bed file
   + Information about chromosome sizes are available in the fa.fai file

We adjusted the gene annotation file based on the information available in the supplementary information of [Fulco et al. 2019](https://doi.org/10.1038/s41588-019-0538-0):

* Select one TSS for each gene
    + we selected the TSS that was used by the most highly expressed isoform (highest mean TPM expression across three replicates) from the RNA-seq
        + In cases where several isoforms show equal expression levels, we select the TSS that is used by the majority of isoforms
        + For the remaining genes, i.e. those for which neither gene expression nor the majority vote identified a unique TSS, we selected the most 5’ TSS
* remove genes corresponding to small RNAs
    + gene symbol contains “MIR” or “RNU”
    + gene body length < 300bp (we calculated gene body length by summing across the exon widths of each transcript)
* remove very long RNAs
    + gene body > 2Mb

To generate the TSS file, we selected 500bp surrounding the TSS for each gene. For the gene annotation file we collapsed each gene to its most expanded ranges.

## Define candidate elements

### MACS with ABC-specific parameters

`makeCandidateRegions.py` selects the strongest peaks as measured by absolute read counts. Using a lenient significance threshold in MACS (e.g. `-p 0.1)` peaks are called and the peaks with the most read counts are considered. The procedure implicitly assumes that the active karyotype of the cell type is constant.

Run [MACS](https://github.com/macs3-project/MACS/blob/master/docs/callpeak.md) with specific parameters required for the ABC algorithm:

* -p 0.1
* --call-summits TRUE

### DiffBind as an alternative to `makeCandidateRegions.py`

To replicate the steps taken by the ABC algorithm in the first step (`makeCandidateRegions.py`), we use the Bioconductor package DiffBind.

The ABC step `makeCandidateRegions.py` consists of the following steps:

1. Count the ATAC read that overlap the identified peak regions (macs2)
2. Take top N regions, get summits, extend summits, merge, remove blocklist, add includelist, sort and merge

The authors of the ABC algorithm suggest to use only one replicate or to merge the bam files ([github issue](https://github.com/broadinstitute/ABC-Enhancer-Gene-Prediction/issues/45)) in the case of the availability of replicates. We analysed each replicate individually with MACS and removed elements overlapping regions of the genome that have been observed to accumulate anomalous number of reads in epigenetic sequencing (“black-listed regions” made available [here](https://sites.google.com/site/anshulkundaje/projects/blacklists)). The black-listed regions are available via the ENCODE project for human, mouse and worm and, specifically for [GRCh37](https://www.encodeproject.org/files/ENCFF001TDO/).

When computing the ABC score, the product of ATAC-seq (DNase-seq) and H3K27ac ChIP-seq reads will be counted in each candidate elements. It is therefore necessary that candidates regions of open (nucleosome depleted) chromatin are of sufficient length to capture H3K27ac marks on flanking nucleosomes. [Fulco et al. 2019](https://doi.org/10.1038/s41588-019-0538-0) define candidate regions to be 500bp (150bp of the DHS peak extended by 175bp in each direction). We used a summit width of 275 (200bp peak width plus 175bp each side). Subsequently, reads were counted with `DiffBind::dba.count(DBA, summits = 275, minOverlap=2)` in the 1216037 consensus peaks identified by [DiffBind](https://doi.org/10.1038/nature10730). `DiffBind` takes the number of uniquely aligned reads to compute a normalised read count for each sample at every potential binding site. The peaks in the consensus peaks are re-centred and trimmed based on calculating their summits (point of greatest read overlap) in order to provide more standardized peak intervals. We used background normalisation as recommended by the [DiffBind vignette](https://bioconductor.org/packages/release/bioc/vignettes/DiffBind/inst/doc/DiffBind.pdf).

The candidate putative enhancer regions were then identified as those consensus peaks with the top 150000 activity (i.e. mean normalized read count). This approach utilizes the available replicates without merging the available bam files. Finally we merged the candidate putative enhancer regions with the annotated TSS file region (“include-list”), as the ABC model considers promoters as part of the putative enhancer set. This forces the candidate enhancer regions to include gene promoters, even if the promoter is not among the candidate elements with the strongest signals genome-wide in a cell type.

The remainder of the analysis, i.e the quantification of the enhancer acitivity and the computation of the ABC scores follows the steps described by the [ABC model](https://github.com/broadinstitute/ABC-Enhancer-Gene-Prediction).
