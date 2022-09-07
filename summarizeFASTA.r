#!/usr/bin/env Rscript

# Print number of sequences --summary
# Print names of sequences --names

# Written by Yasoo Morimoto

library("seqinr")
library("optparse")

optionList <- list(make_option(c("-v", "--verbose"), action = "store_true",
																default = TRUE, help = "Print extra output [default]"),
make_option(c("-s", "--summary"), action = "store_true", help = "", default = FALSE),
make_option(c("-n", "--names"), action = "store_true", default = FALSE))

opt <- parse_args(OptionParser(option_list = optionList,
															 usage = "usage: %prog [sequences.fasta]"),
									positional_arguments = 1)

seqs <- read.fasta(file = opt$args[1])


if (opt$options$summary) {
	cat("Number of sequences:", length(seqs), "\n")
} else if (opt$options$names) {
	for (s in seqs) {
		cat(attr(s, "name"), "\n")
	}
}
