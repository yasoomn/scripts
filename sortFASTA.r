#!/usr/bin/env Rscript

library(seqinr)

args <- commandArgs(trailingOnly=T)
# test if there is at least one argument: if not, return an error
# TODO test if the file is a JSON
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).json", call. = FALSE)
} else {
	lst <- read.table(args[1])
	seqs <- read.fasta(file = args[2])
}




# seqs["Azfi_s0001.g000030"]
for (s in 1:nrow(lst)) {
	#print(s)
	cat(paste(">", lst[s, 1], "\n", sep = ""), sep = "")
	cat(paste(toupper(getSequence(seqs[lst[s, 1]], as.string = T)[[1]]), "\n", sep = ""), sep = "")

}
