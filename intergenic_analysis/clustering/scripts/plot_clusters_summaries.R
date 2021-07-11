
#=== libraries ===
library(ggplot2)
library(reshape2)
#=================


#=== out plots file names =========
no.clusters_fname       = "plots/number_of_clusters.pdf"
size.clusters_fname     = "plots/size_of_clusters.pdf"
no.genes.clusters_fname = "plots/number_of_genes_in_clusters.pdf"
#=================


#== get list of files ===
cluster_files = list.files("output/", pattern =  "_cluster_summ.txt", full.names = T)
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
tab$n.cluster      = NA # number of clusters
tab$single.cluster = NA # number of single-gene clusters
tab$multi.cluster  = NA # number of multi-gene clusters
tab$size           = NA # mean cluster size (in bp)
tab$n.genes        = NA # mean number of genes in clusters
#=================


#=== go over each file ========
for(i in 1:nrow(tab)){
  cluster_file = read.table(tab[i, 'file'], sep = '\t', 
                            col.names = c("clusterID", "chr", "start", "end", "n.genes", "left.flank.gene", "right.flank.gene"))
  
  cluster_file$size = cluster_file$end - cluster_file$start +1 # getting clusters sizes
  
  tab[i, 'n.cluster']      = nrow(cluster_file)             # count clusters
  tab[i, 'single.cluster'] = sum(cluster_file$n.genes == 1) # count single-gene clusters
  tab[i, 'multi.cluster']  = sum(cluster_file$n.genes  > 1) # count multi-gene clusters
  tab[i, 'size']           = mean(cluster_file$size)        # mean cluster size
  tab[i, 'n.genes']        = mean(cluster_file$n.genes)     # mean number of genes in clusters
  
}
#=================

#-- PLOTS

#=================
pdf(no.clusters_fname, width = 6, height = 4)
df = melt(tab[,c('distance', 'single.cluster', 'multi.cluster')], id.vars = "distance")
ggplot(df, aes(fill=variable, y=value, x=distance)) + 
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c("#C8BEB7", "#6C5D53")) +
  theme_test() 
dev.off()
#=================



#=================
pdf(size.clusters_fname, width = 6, height = 2)
df = melt(tab[,c('distance', 'size')], id.vars = "distance")
ggplot(df, aes(fill=variable, y=value, x=distance)) + 
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c("grey40")) +
  ylim(0,80000) +
  theme_test() 
dev.off()
#=================



#=================
pdf(no.genes.clusters_fname, width = 6, height = 2)
df = melt(tab[,c('distance', 'n.genes')], id.vars = "distance")
ggplot(df, aes(fill=variable, y=value, x=distance)) + 
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(values=c("grey40")) +
  theme_test() 
dev.off()
#=================
