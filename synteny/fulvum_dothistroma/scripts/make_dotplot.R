

#======= input/output files ====
args = commandArgs(trailingOnly=TRUE)
fplot_file = args[1]
rplot_file = args[2]
ref_fai_file = args[3]
qry_fai_file = args[4]
output_dotplot_file  = args[5]
#===============================



#=== defining color palette ====
colfunc = colorRampPalette(c("black", "purple", "blue", "cyan", "green", "orange", "red"))
pidentpalette = colfunc(100)
#===============================



#========== Readig =============
fplot = read.table(fplot_file)
rplot = read.table(rplot_file)
ref_fai = read.table(ref_fai_file, col.names=c("name", "length", "offset", "linebases", "linewidth"))
qry_fai = read.table(qry_fai_file, col.names=c("name", "length", "offset", "linebases", "linewidth"))
#===============================



#=== process rplot and fplot files
frplot = rbind(fplot, rplot)
frplot = cbind( 
  t(matrix(unlist(frplot$V1), nrow=2)),
  t(matrix(unlist(frplot$V2), nrow=2)),
  t(matrix(unlist(frplot$V3), nrow=2))
  )

frplot = frplot[frplot[,5] > 0, c(1,2,3,4,5)]
colnames(frplot) = c("ref_start", "ref_end", "qry_start", "qry_end", "pident")

frplot[,'pident'] = round(frplot[,'pident'])
#===============================

x_lim = max(frplot[,c('ref_start', 'ref_end')])
y_lim = max(frplot[,c('qry_start', 'qry_end')])


pdf(output_dotplot_file, width = 6, height = 6)
plot(1, type="n", xlim=c(0,x_lim), ylim=c(0,y_lim), axes = F)
for( i in 1:nrow(frplot)){
  x1 = frplot[i,'ref_start']
  y1 = frplot[i,'qry_start']
  x2 = frplot[i,'ref_end']
  y2 = frplot[i,'qry_end']
  color = pidentpalette[ frplot[i, 'pident'] ]
  segments(x1, y1, x2, y2, col = color, lwd=2)
}

abline(v=0, lwd=0.4, lty = 2, col="grey40")
abline(h=0, lwd=0.4, lty = 2, col="grey40")
abline(v=cumsum(ref_fai$length), lwd=0.4, lty = 2, col="grey40")
abline(h=cumsum(qry_fai$length), lwd=0.4, lty = 2, col="grey40")

box()




plot(1, type='n', xlim=c(0,100), ylim=c(0,5), axes=F, xlab="", ylab="")
for(i in 1:length(pidentpalette)){
  rect(i,1,i+1,2, border = NA, col=pidentpalette[i])
}
axis(1)
mtext("Identity (%)", side=1, line=2)

dev.off()
