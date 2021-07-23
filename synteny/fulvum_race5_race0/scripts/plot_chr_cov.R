
#===
# Script that produces figures of chromosomes and highlights covered regions, and genes of interest.
# 
# There are four inputs, passed by argument (in order):
#  1) coverage in bed format, generated with bedtools genomecov -ibam -bga -split
#  2) the faidx file produced by samtools
#  3) GFF file of genes to highlight in the plots (one feature per gene; no exons, CDS, etc)
#  4) directory to output plots, must exist
#===


args = commandArgs(trailingOnly=TRUE)


#===== INPUT =====
bed_fname   = args[1] 
faidx_fname = args[2] 
missing_genes_fname = args[3] 
output_dir  = args[4] 
#=================



#======= Reading ======
bed_cov       = read.table(bed_fname, col.names=c("chr", "start", "end", "cov"))
missing_genes = read.table(missing_genes_fname, 
	col.names=c("chr", "source", "feature", "start", "end", "score", "strand", "frame", "attr"))
faidx         = read.table(faidx_fname, col.names=c("chr", "length", "offset", "linebases", "linewidth"))
#======================



#====== pre-process ====
# add row names as chromosome IDs
rownames(faidx) = faidx$chr

# get size of longest chromosome
max_len = max(faidx$length)
#======================



#==== main for loop ======
# for each chromosome
for(id in levels(as.factor(bed_cov$chr))){
	
	# file name to save plot
    plot_fname = paste0(output_dir, "/", id, ".pdf")

    # open pdf
	pdf(plot_fname, width = 8, height = 2.3)

	# make an empty plot
	plot(1, type="n", xlim=c(0,max_len), ylim=c(0,10), ann=F, axes=F)

	# get coverege and genes for the respective chromosome
	bed_cov_seq = subset(bed_cov, chr==id & cov > 0)
	missing_genes_seq = subset(missing_genes, chr==id)

	# plot coverage as rectangles
	for(i in 1:nrow(bed_cov_seq)){
		rect(bed_cov_seq[i, 'start'], 0, bed_cov_seq[i, 'end'], 2, lwd=NA, col="burlywood4")
	}

	# plot entire chromosome as a rectangle
	rect(0, 0, faidx[id, 'length'], 2, lwd=0.8)

	# highlight genes as point, if any
	if(nrow(missing_genes_seq) > 0){
		points(missing_genes_seq$start, rep(2.7, nrow(missing_genes_seq)), cex=0.4, pch=25, bg="firebrick1", lwd=0.1, col="firebrick1")
	    #segments(missing_genes_seq$start, 2, missing_genes_seq$start, 2.5, lwd=0.3, col="red")
	}

	# just add chromosome name as a text
	text(0,5, id, pos=4)

	# add x-axis
	axis(1)

	# close pdf
	dev.off()
}
#======================

