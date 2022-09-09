#!/usr/bin/env Rscript

# This script takes a newline separated file of sequence names and used it to
# search a FASTA file. It returns the sequences in the order they were in the list in FASTA format.
# Written by Yasoo Morimoto

library(seqinr)
library("optparse")

optionList <- list(
make_option(c("-v", "--verbose"), action = "store_true", default = TRUE,
help = "Print extra output [default]")
)

opt <- parse_args(OptionParser(optionList = optionList, 
															 usage = "usage: %prog [names.lst] [sequences.fasta]"), positional_arguments = 2)

	lst <- read.table(opt$args[1])
	seqs <- read.fasta(file = opt$args[2])


for (s in 1:nrow(lst)) {
	#print(s)
	cat(paste(">", lst[s, 1], "\n", sep = ""), sep = "")
	cat(paste(toupper(getSequence(seqs[lst[s, 1]], as.string = TRUE)[[1]]), "\n", sep = ""), sep = "")

}
