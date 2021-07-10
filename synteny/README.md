## Synteny with MUMmer
Nucmer and promer are useful algorithms to align whole genomes and produce synteny plots. Here, there are directories that produce synteny plots. For *Dothistroma septosporum* (in `fulvum_dothistroma`), I use promer, which is more sensitive than nucmer for different species, as the former aligns at the protein level (6 frame translation), while the latter aligns at the nucletide level, which is more commonly used for different individuals of the same species

There are Snakefiles in each subdirectory, that can be executed with `snakemake -j 1 --use-conda`. Just make sure that the *C. fulvum* race 5 genome (reference) is in in the `data/Cfulv_R5_assembly_v4.fasta` subdirectories. Snakefiles should do the rest, from downloading the query from NCBI, to calling tool/scrips to produce the plots.


**Note:** I couldn't make promer work on OSX. But I had no problems on Ubuntu.

**Note:** Mind the hidden `.snakemake/` directory after calling `snakemake`. They will use considerably amount of space (~1Gb).
