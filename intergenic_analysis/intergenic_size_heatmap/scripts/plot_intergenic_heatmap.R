intergenic_upstream_fname   = 'data/intergenic_upstream.bed'
intergenic_downstream_fname = 'data/intergenic_downstream.bed'
#genes_interest_fname        = 'data/gene_categories.txt'
out_plot_fname              = ''


library(ggplot2)

#=== command line arguments ===
args = commandArgs(trailingOnly = TRUE)

intergenic_upstream_fname   = args[1]
intergenic_downstream_fname = args[2]
out_plot_fname              = args[3]
genes_interest_fname        = args[4]
out_intergenic_table_fname  = args[5]
#=============================



#====== READING ======
intergenic_upstream   = read.table(intergenic_upstream_fname, 
                                   col.names=c("gene_chr", "gene_start", "gene_end", "gene_id", "gene_score", "gene_strand", "intergenic_chr", "intergenic_start", "intergenic_end", "distance")
)
intergenic_downstream = read.table(intergenic_downstream_fname, 
                                   col.names=c("gene_chr", "gene_start", "gene_end", "gene_id", "gene_score", "gene_strand", "intergenic_chr", "intergenic_start", "intergenic_end", "distance")
)
#genes_interest = read.table( genes_interest_fname, col.names=c("gene_id","class") )
#genes_interest = subset(genes_interest, class == "CEP")[,'gene_id'] # select candidate effectors
genes_interest = readLines( genes_interest_fname)
#====================



#==
intergenic_upstream$inter_up_len   = intergenic_upstream$intergenic_end   - intergenic_upstream$intergenic_start
intergenic_downstream$inter_down_len = intergenic_downstream$intergenic_end - intergenic_downstream$intergenic_start
#==



#=== Merging ===
intergenic = merge(
  intergenic_upstream[,  c("gene_id", "inter_up_len")],
  intergenic_downstream[,c("gene_id", "inter_down_len")],
  by = "gene_id"
)
#==============



#==== convert to log scale ==
intergenic$inter_up_len = log10(intergenic$inter_up_len)
intergenic$inter_down_len = log10(intergenic$inter_down_len)
#============



#=== get intergenic of genes of interest ===
genes_interest = intergenic[intergenic$gene_id %in% genes_interest,]
#===========



# array to replace axes labels
axlabels = c(expression("10"^"0"), 
             expression("10"^"2"), 
             expression("10"^"4"), 
             expression("10"^"6"))

pdf(out_plot_fname, width = 5, height = 4)
ggplot(intergenic, aes(x=inter_up_len, y=inter_down_len) ) +
  geom_hex(bins = 50) +
  scale_fill_continuous(name = "Gene\ncount", type = "gradient", low = "darkblue", high="yellow") +
  labs(x = " Upstream intergenic length (bp)", y = "Downstream intergenic length (bp)") +
  xlim(0,6) + ylim(0,6) +
  #scale_x_continuous(labels = axlabels) +
  #scale_y_continuous(labels = axlabels) +
  geom_point(data = genes_interest, fill = "orange", col = 'black', shape = 21, size=1, alpha=0.8) +
  theme_bw()
dev.off()

# write table out
write.table(intergenic, out_intergenic_table_fname, quote=F, sep = '\t', row.names = F)
