## Intergenic size heatmap

Must have in the `data/` directory:

* <sample>.gff: genes in GFF format
* <sample>.genome.txt: two-column file with chomosome name and size
* <sample>_genes_interest.txt: single-column file with IDs of genes of interest to plot them as points over the heatmap.

And <sample> is any common name for the files. Remember to update the first line of `Snakefile` to include the <sample> as an element of the array `SAMPLES`.

The GFF file is parsed to extract only the genes. Then, using bedtools `complement`, I get the intergenic regions, as the complement of the genome and genes (i.e., genome *minus* genes). Then, I assign intergenic regions to each gene by calling bedtools `closest`.

Five files are generated:

* <sample>_onlygenes.bed: bedfile with only the genes from GFF.
*  <sample>_complement.bed: resulted bed file from bedtools `complement` call.
* <sample>_intergenic_upstream.bed: genes and their upstream intergenic region.
* <sample>_intergenic_downstream.bed: genes and their downstream intergenic region.
* <sample>_intergenic_table.txt: size of intergenic regions, in log10 scale.