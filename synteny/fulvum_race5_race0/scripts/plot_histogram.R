
# R script that is part of a Snakemake pipeline. 
# It reads a table generated with bedtools coverage and plots a histogram of coverage fraction of features not fully covered (i.e., less than 100%).

# read arguments
args = commandArgs(trailingOnly=TRUE)

# first argument is name of table to read. Second is name of file to plot
table_fname    = args[1]
out_plot_fname = args[2]

# read table
tab = read.table(table_fname, sep = '\t', 
                 col.names = c("seqid", "source", "type", "start", "end", "score", "strand", "phase", "tags", "overlapping_features", "n_bases_nonzero_cov", "length", "perc_nonzero_cov"))

# get genes not fully covered by the mapping
genes_not_fcov = subset( tab, perc_nonzero_cov<1 )

# plot a histogram of fraction of coverage for genes not fully covered
pdf(out_plot_fname, width = 5, height = 4)
hist(genes_not_fcov$perc_nonzero_cov, main="", xlab="Coverage fraction", breaks = 20, ylim=c(0,400))
text(0.5, 380, paste0("From ", nrow(genes_not_fcov)," genes, ", sum(genes_not_fcov$perc_nonzero_cov==0), " had zero coverage"))
dev.off()
