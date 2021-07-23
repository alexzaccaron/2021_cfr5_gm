


args = commandArgs(trailingOnly=TRUE)


#==== Functions ===
# Functions from [here](https://gist.github.com/slowkow/6e34ccb4d1311b8fe62e).
rpkm <- function(counts, lengths) {
  rate <- counts / lengths 
  rate / sum(counts) * 1e6
}

tpm <- function(counts, lengths) {
  rate <- counts / lengths
  rate / sum(rate) * 1e6
}
#=================



#==== Input ======
# Getting file names as arguments
genecounts_fname = args[1]
genelength_fname = args[2]
output_fname     = args[3]
#=================


#===== Reading =====
cts   = read.table(genecounts_fname, header = T)
genes = read.table(genelength_fname, header = T)
#=================


#==== Calculating ====
rpkms <- apply(cts, 2, function(x) rpkm(x, genes$Length))
tpms  <- apply(cts, 2, function(x) tpm(x, genes$Length))
#=================



#===== Output ======
write.table(tpms, output_fname, sep = '\t', quote=F)
#=================
#colSums(rpkms)
#colSums(tpms)
#colMeans(rpkms)
#colMeans(tpms)