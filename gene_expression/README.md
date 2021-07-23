## calculating expression
Code used to determine expression of genes, i.e., calculate TPM values from RNA-seq reads obtained from NCBI

The genome (fasta and GTF) must be in `data`. The code will download the reads, map them with HISAT2, count the reads with featureCounts, and call an R script in `scripts` to calculate TPM values.
