## Genome size estimation
Raw WGS Illumina reads in `data/` are filtered with `bbduk.sh` based on bacterial contigs assembled with the PacBio data and the mitochondrial contig, all of the in the `data/contaminants.fasta`. The filtered reads are then used to count k-mers with `kmercountexact.sh`, which estimates the genome size, reported in `output/kmercountexact_peaks.txt`.
