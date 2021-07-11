
#=== libraries ===
library(ggplot2)
library(reshape2)
#=================


#=== args=========
args = commandArgs(trailingOnly=TRUE)
plot_fname = args[1]
#=================


#== get list of files ===
cluster_files = list.files("output/", pattern =  "cluster.gff", full.names = T)
#=================


#=== initialize empty var ========
tab = rep(NA, length(cluster_files))
tab = as.data.frame(tab)
#=================


#==== preprocessing ========
tab$file = cluster_files
tab$distance = gsub(".*/", "", gsub("_.*", "", cluster_files) )
tab$distance = as.numeric(tab$distance)/1000
tab = tab[order(tab$distance),]
#=================


#==== new fields =====    
tab$n.cluster = NA
tab$single.cluster = NA
tab$multi.cluster = NA
#=================


#=== go over each file ========
for(i in 1:nrow(tab)){
  cluster_file = read.table(tab[i, 'file'], sep = '\t')
  
  # cluster in the last column
  clusters = cluster_file[,ncol(cluster_file)]
  
  # summary of clusters wirh table()
  clusters_summ = table(clusters)
  
  tab[i, 'n.cluster']      = length(clusters_summ)   # count clusters
  tab[i, 'single.cluster'] = sum(clusters_summ == 1) # count single-gene clusters
  tab[i, 'multi.cluster']  = sum(clusters_summ > 1)  # count multi-gene clusters
}
#=================

#-- PLOT

#=================
pdf(plot_fname, width = 6, height = 4)
df = melt(tab[,c('distance', 'single.cluster', 'multi.cluster')], id.vars = "distance")
ggplot(df, aes(fill=variable, y=value, x=distance)) + 
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c("#C8BEB7", "#6C5D53")) +
  theme_test() 
dev.off()
#=================
