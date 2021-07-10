 

library(ggplot2)



#=== command line arguments ===
args = commandArgs(trailingOnly = TRUE)

intergenic_upstream_repeat_fname   = args[1]
intergenic_downstream_repeat_fname = args[2]
genes_interest_fname               = args[3]
out_length_fname                   = args[4]
out_repeat_fname                   = args[5]
#==============================




#====== READING ======
intergenic_upstream   = read.table(intergenic_upstream_repeat_fname, 
                                   col.names=c("chr", "start", "end", "gene_id", "up_No_overlap", "up_bp_covered", "up_total_length", "up_cov_percentage")
)

intergenic_downstream = read.table(intergenic_downstream_repeat_fname, 
                                   col.names=c("chr", "start", "end", "gene_id", "down_No_overlap", "down_bp_covered", "down_total_length", "down_cov_percentage")
)

gene_categories = read.table( genes_interest_fname, col.names=c("gene_id","class") )
#====================




#=== Merging ===
intergenic_repeat = merge(
  intergenic_upstream[,   c("gene_id", "up_No_overlap", "up_bp_covered", "up_total_length", "up_cov_percentage")],
  intergenic_downstream[, c("gene_id", "down_No_overlap", "down_bp_covered", "down_total_length", "down_cov_percentage")],
  by = "gene_id"
)
#==============




#======= Selecting genes of interest =====
# gene categories of interest
categories = levels(factor(gene_categories$class))

# declare an empty table
merged_table = NULL

# for each category of interest
for (category in categories){
    # get gene IDs of the category of interest
	genes_to_select = subset(gene_categories, class == category )
	genes_to_select = genes_to_select$gene_id

	# get genes of interest from the main table
	aux = intergenic_repeat[intergenic_repeat$gene_id %in% genes_to_select,]
	aux$class = category

	# add to the new table
	merged_table = rbind(merged_table, aux)
}
#=========================================




#==== adding new fields to the table ====
merged_table$mean_repeat_per = (merged_table$up_cov_percentage + merged_table$down_cov_percentage)/2
merged_table$mean_inter_len  = (merged_table$up_total_length + merged_table$down_total_length)/2
merged_table$mean_inter_len  = log10(merged_table$mean_inter_len)
#========================================




#====== Ploting =====
pdf(out_length_fname, width = 2, height = 1.5)
ggplot(merged_table, aes(mean_inter_len, factor(class, levels = c("Dup", "CEP", "All")))) + 
   geom_violin( fill = "#8f8f8f" ) +
   labs(x="Intergenic region length (bp)", y="") +
   theme_classic()
dev.off()


pdf(out_repeat_fname, width = 2, height = 1.5)
ggplot(merged_table, aes(mean_repeat_per, factor(class, levels = c("Dup", "CEP", "All")))) + 
   geom_violin( fill = "#8f8f8f" ) +
   labs(x="Intergenic repeat content (%)", y="") +
   theme_classic()
dev.off()
#=====================