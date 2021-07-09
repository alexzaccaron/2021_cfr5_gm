

#== Setting colors ===
colfunc1 <- colorRampPalette(c("white", "#dd0022")) # for genes
colfunc2 <- colorRampPalette(c("white", "#484537")) # for repeats

pallet_gene = colfunc1(20)
pallet_rept = colfunc2(100)
#==============



#=== Reading data ====
# reading table with statistics of each window. Also, a file witht the size of the chromosomes 
windows        = read.table("chr_windows_combined.bed", header = T, sep = '\t')
genome_size    = read.table("genome.txt", col.names = c("scaffold", "length"))
# here, if I want to point to the location of genes of interest in the chromosomes, read genes in bed format
#genes_interest = read.table("genes_interest.bed", sep ='\t', col.names = c("scaffold", "start", "end", "ID"))

# converting to percentage
windows$perc_repeat = round(windows$perc_repeat*100)
# there are a few windows with 21 genes. Bringing it down to 20 for consistency
windows[windows$gene_count >20,'gene_count'] = 20
#=========



#==== plotting =====
# for loop to plot each chromosome in an individual file
for( chromosome in genome_size$scaffold){
  
  # open a pdf file
  pdf(paste0(chromosome, ".pdf"), width = 7, height = 3.9)
  
  # plot an empty plot
  plot(1, type="n", xlim=c(0,12000000), ylim=c(-2,32), axes = F, ann = F)
  
  # subsetting data from respective chromosome
  chromosome_size = subset(genome_size, scaffold==chromosome)[,'length']
  windows_subset = subset(windows, chr==chromosome)
  # if wanted, subset genes of interest to point their location
  #genes_to_point  = subset(genes_interest, scaffold==chromosome)
  
  # another for loop to plot the windows
  for(i in 1:nrow(windows_subset)){
    rect(windows_subset[i,'start'], -0.5,     windows_subset[i,'end'], 1.5, border = NA, col = pallet_gene[windows_subset[i,'gene_count']])
    rect(windows_subset[i,'start'], 1.5, windows_subset[i,'end'], 3.5,   border = NA, col = pallet_rept[windows_subset[i,'perc_repeat']])
  }
  
  # rectangle around chromosome
  rect(1, -0.5, chromosome_size, 3.5, lwd=0.6)
  
  # adding GC content as a line
  lines(windows_subset$start, windows_subset$GC/10, lwd=1.2)
  axis(2, at=1:20, cex.axis=0.5)
  axis(1)
  
  # if(nrow(genes_to_point) > 0){
  #   for(i in 1:nrow(genes_to_point)){
  #     points(genes_to_point[i, 'start'], -1.5, pch = 17, col="#6C6753", cex=0.8)
  #   }
  # }
  
  dev.off()
}
#======



#======
#legend
pdf("chromosomes_legend_gene.pdf", width = 5, height = 5)
plot(1, type="n", xlim=c(0,40), ylim=c(0,10), axes = F, ann = F)
for(i in 1:length(pallet_gene)){
  rect(i,1,i+1,2, border = NA, col=pallet_gene[i])
}
rect(1,1,21,2, lwd=0.5)
dev.off()




pdf("chromosomes_legend_repeat.pdf", width = 5, height = 5)
plot(1, type="n", xlim=c(0,110), ylim=c(0,10), axes = F, ann = F)
for(i in 1:length(pallet_rept)){
  rect(i,1,i+1,2, border = NA, col=pallet_rept[i])
}
rect(1,1,101,2, lwd=0.5)
dev.off()




min(1-cumsum(dhyper(0:(17-1),345,(14690-345),394)))
binom.test(250, 13743,p=345/(14690-345))
binom.test(80, 100,p=0.5)

counts = (matrix(data = c(66, 947, 345, 14690-345), nrow = 2))

fisher.test(counts)

chisq.test(counts)

phyper(17, 345, 14690-345, 377)



observed = c(770, 230)        # observed frequencies
expected = c(0.75, 0.25)      # expected proportions

chisq.test(x = observed,
           p = expected)
