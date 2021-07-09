

#======= input/output files ====
args = commandArgs(trailingOnly=TRUE)
coords_file = args[1]
output_file = args[2]
#===============================


#=== setting up colors ====
colors = c(
"0,170,68", 
"111,145,111", 
"135,222,170", 
"183,200,183", 
"44,44,160", 
"44,137,160",
"85,221,255", 
"200,55,55", 
"222,135,135", 
"153,85,255", 
"200,113,55", 
"255,204,0",
"222,205,135", 
"233,198,175")

names(colors) = c(
"tig00000003",
"tig00000006",
"tig00000008",
"tig00000011",
"tig00000014",
"tig00000019",
"tig00000022",
"tig00000025",
"tig00000028",
"tig00000031",
"tig00000033",
"tig00000037",
"tig00004032",
"tig00004034")
#===============================



#==== reading coords file ====
coords = read.table(coords_file, col.names=c("rstart", "rend", "qstart", "qend", "rlen", "qlen", "pident", "psim", "pstop", "rframe", "qframe", "ref", "qry"))
#===============================



#== getting coords file in 'links' format for circos
links = coords[,c('ref', 'rstart', 'rend', 'qry', 'qstart', 'qend')]
#===============================


#==adding colors to links
links$color = "black"
for (chromosome in levels(links$ref)){
	links[links$ref == chromosome, 'color'] = paste0( "color=",colors[chromosome] )
}
#===============================


#====== writting to file =======
write.table(links, output_file, quote = F, sep = '\t', row.names = F, col.names = F)
#===============================