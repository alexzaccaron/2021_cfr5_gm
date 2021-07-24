

library(clusterProfiler)
library(enrichplot)

pfam_term2gene=read.table("data/pfam_term2gene")
pfam_term2name=read.delim("data/pfam_term2name", sep = '\t', header = F)

genes_interest = readLines("data/genes_interest.txt")

enr_res <- enricher(genes_interest, 
                    TERM2GENE = pfam_term2gene,
                    TERM2NAME = pfam_term2name,
                    pvalueCutoff = 0.05,
                    pAdjustMethod = "BH",
                    qvalueCutoff = 0.05,
                    minGSSize = 1)

pdf("plot.pdf", width = 6, height = 4)
dotplot(enr_res, showCategory = 12)
dev.off()