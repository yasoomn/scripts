#!/usr/bin/env Rscript

# Print number of sequences --summary
# Print names of sequences --names
# search a sequence --match
# TODO: also search complement and reverse complement

# Written by Yasoo Morimoto

library("seqinr")
library("optparse")

optionList <- list(make_option(c("-v", "--verbose"), action = "store_true",
																default = FALSE, help = "Print extra output [default]"),
make_option(c("-s", "--summary"), action = "store_true", help = "", default = FALSE),
make_option(c("-n", "--names"), action = "store_true", default = FALSE),
make_option(c("-m", "--match"), action = "store"))

opt <- parse_args(OptionParser(option_list = optionList,
															 usage = "usage: %prog [sequences.fasta]"),
									positional_arguments = 1)

aaORdna <- function(lst) {
	for (s in lst) {
		if (sum(summary(s)$composition) == length(s)) {
			if (opt$options$verbose) {
				print("its DNA")
			}
		} else {
			if (opt$options$verbose) {
				print("its not DNA, setting to AA")
			}
			attr(s, "class") <- "SeqFastaAA"
		}
	}
	lst
}

searchSequence <- function(s, searchSeq) {
	sq <- paste(s, collapse = "")
	startpos <- unlist(gregexpr(searchSeq, sq))
	if (startpos > 0) {
	cat(paste("Found query in the sequence",
				getName(s),
				"at position",
				startpos,
				"to",
				startpos + nchar(searchSeq)))
	}

}



seqs <- read.fasta(file = opt$args[1])
seqs <- aaORdna(seqs)


if (opt$options$summary) {
	cat("Number of sequences:", length(seqs), "\n")
} else if (opt$options$names) {
	cat(getName(seqs), sep = "\n")
} else if (length(opt$options$match) != 0) {
	for (s in seqs) {
		searchSequence(s, opt$options$match)
	}
}
