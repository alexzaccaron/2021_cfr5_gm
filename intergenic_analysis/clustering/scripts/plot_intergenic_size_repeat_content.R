

#=== libraries ===
library(ggplot2)
library(reshape2)
#=================


#=== output plot file names ========
intergenic_size_fname = "plots/intergenic_size.pdf"
repeat_content_fname  = "plots/intergenic_repeat_content.pdf"
#=================


#== get list of files ===
intergenic_files = list.files("output/", pattern =  "cluster_coverage_repeats.bed", full.names = T)
#=================


#=== initialize empty var ========
tab = rep(NA, length(intergenic_files))
tab = as.data.frame(tab)
#=================


#==== preprocessing ========
tab$file = intergenic_files
tab$distance = gsub(".*/", "", gsub("_.*", "", intergenic_files) )
tab$distance = as.numeric(tab$distance)/1000
tab = tab[order(tab$distance),]
#=================


#==== new fields =====
tab$flaking_repeat = NA
tab$flaking_size = NA
tab$nonflaking_repeat = NA
tab$nonflaking_size = NA
#=================


#=== go over each file ========
for(i in 1:nrow(tab)){
  intergenic_reg = read.table(tab[i, 'file'], sep = '\t',
                              col.names=c("chr", "start","end", "no.intersect.clusters", "uncov.bp.clusters", "cov.bp.clusters", "cov.perc.clusters", "no.intersect.repeats", "uncov.bp.repeats", "cov.bp.repeats", "cov.perc.repeats"))
  
  intergenic_reg$size = intergenic_reg$end-intergenic_reg$start

  flanking_interg_reg    = intergenic_reg[intergenic_reg$no.intersect.clusters == 0,]
  nonflanking_interg_reg = intergenic_reg[intergenic_reg$no.intersect.clusters == 1,]
  
  tab[i, 'flaking_repeat']    = mean(flanking_interg_reg$cov.perc.repeats)
  tab[i, 'flaking_size']      = mean(flanking_interg_reg$size)
  tab[i, 'nonflaking_repeat'] = mean(nonflanking_interg_reg$cov.perc.repeats)
  tab[i, 'nonflaking_size']   = mean(nonflanking_interg_reg$size)
}
#=================


# -- PLOTS

#=================
pdf(intergenic_size_fname, width = 6, height = 4)
df = melt(tab[,c('distance', 'flaking_size', 'nonflaking_size')], id.vars = "distance")
ggplot(df, aes(fill=variable, y=value, x=distance)) + 
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c("#C8BEB7", "#6C5D53")) +
  theme_test()
dev.off()
#=================



#=================
pdf(repeat_content_fname, width = 6, height = 4)
df = melt(tab[,c('distance', 'flaking_repeat', 'nonflaking_repeat')], id.vars = "distance")
df$value = df$value*100
ggplot(df, aes(fill=variable, y=value, x=distance)) + 
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c("#C8BEB7", "#6C5D53")) +
  theme_test()
dev.off()
#=================






