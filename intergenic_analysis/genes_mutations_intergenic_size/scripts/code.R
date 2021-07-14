


intergenic = read.table("../data/intergenic.txt", header = T)
snpEff     = read.table("../data/snpEff_genes_rready.txt", header = T)




intergenic$upstream_size   = intergenic$upstream_end - intergenic$upstream_start
intergenic$downstream_size = intergenic$downstream_end - intergenic$downstream_start


intergenic$upstream_size   = intergenic$upstream_size/1000
intergenic$downstream_size = intergenic$downstream_size/1000


tab = merge(snpEff, intergenic, by = "GeneId")


#=======
pdf("frameshift_indel.pdf", width = 5, height = 5)
tab_subset = subset(tab, variants_effect_frameshift_variant!=0 )
plot(tab_subset$upstream_size, tab_subset$downstream_size, xlim=c(0,120), ylim=c(0,120),
     main = paste0("Frameshift INDELs: ",nrow(tab_subset), " genes"),
     xlab="Upstream intergenic size (kb)",
     ylab="Downstream intergenic size (kb)",
     cex=0.8)
dev.off()
#=======



#=======
pdf("inframe_indel.pdf", width = 5, height = 5)
tab_subset = subset(tab, variants_effect_conservative_inframe_insertion!=0 |
                            variants_effect_conservative_inframe_deletion!=0 |
                            variants_effect_disruptive_inframe_insertion!=0 |
                            variants_effect_disruptive_inframe_deletion)
tab_subset = subset(tab_subset, variants_effect_frameshift_variant==0)
plot(tab_subset$upstream_size, tab_subset$downstream_size, xlim=c(0,120), ylim=c(0,120),
     main = paste0("In-frame INDELs: ",nrow(tab_subset), " genes"),
     xlab="Upstream intergenic size (kb)",
     ylab="Downstream intergenic size (kb)",
     cex=0.8)
dev.off()
#=======



#=======
pdf("early_stop.pdf", width = 5, height = 5)
tab_subset = subset(tab, variants_effect_stop_gained!=0)
plot(tab_subset$upstream_size, tab_subset$downstream_size, xlim=c(0,120), ylim=c(0,120),
     main = paste0("Early STOP: ",nrow(tab_subset), " genes"),
     xlab="Upstream intergenic size (kb)",
     ylab="Downstream intergenic size (kb)",
     cex=0.8)
dev.off()
#=======



#=======
pdf("stop_lost.pdf", width = 5, height = 5)
tab_subset = subset(tab, variants_effect_stop_lost!=0)
plot(tab_subset$upstream_size, tab_subset$downstream_size, xlim=c(0,120), ylim=c(0,120),
     main = paste0("STOP lost: ",nrow(tab_subset), " genes"),
     xlab="Upstream intergenic size (kb)",
     ylab="Downstream intergenic size (kb)",
     cex=0.8)
dev.off()
#=======


