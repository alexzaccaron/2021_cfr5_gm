

tab = read.table("../table_with_chr_cov.txt", header = T)
rownames(tab) = tab$chr
pdf("../plot/barplot_cov.pdf", width = 6, height = 3)
barplot(tab$perc_covered, names.arg = tab$chr, cex.names = 0.8, las=2, ylim=c(0,100), ylab="Coverage (%)", col="grey50")
dev.off()