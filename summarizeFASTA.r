#!/usr/bin/env Rscript

# Print number of sequences --summary
# Print names of sequences --names
# search a sequence --match

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

searchSequence <- function(sq, searchSeq, strand, name) {
	# create a string of the sequence
	# search the string for matches, returns a vector with starting positions
	startpos <- unlist(gregexpr(searchSeq, paste(sq, collapse = ""), ignore.case = TRUE))
	found <- data.frame(Sequence = c(),
								 Start = c(),
								 End = c(),
								 Strand = c())
	# check if there is a match
	if (startpos[1] != -1) {
		# for each starting position, returns a data frame
		for (strt in startpos) {
			found <- rbind(found, data.frame(Sequence = name,
								 Start = strt,
								 End = (strt + nchar(searchSeq) - 1),
								 Strand = strand))
		}
		found
	}
}

seqs <- read.fasta(file = opt$args[1])
seqs <- aaORdna(seqs)

if (opt$options$summary) {

	print(data.frame(row.names = c("No of sequences", "Type"),
												 Summary = c(length(seqs), attr(seqs[[1]], "class"))),
							quote = FALSE,
							sep = "\t")
} else if (opt$options$names) {
	cat(getName(seqs), sep = "\n")
} else if (length(opt$options$match) != 0) {
	d <- data.frame(Sequence = c(), Start = c(), End = c())
	for (s in seqs) {
		if (class(s) == "SeqFastadna") {
			fwdStrand <- s
			revStrand <- comp(s)
			revComp <- rev(comp(s))
			name <- getName(s)
			d <- rbind(d, searchSequence(fwdStrand, opt$options$match, "Forward", name))
			d <- rbind(d, searchSequence(revStrand, opt$options$match, "Reverse", name))
			d <- rbind(d, searchSequence(revComp, opt$options$match, "Reverse Complement", name))
		} else {
			d <- rbind(d, searchSequence(s, opt$options$match, "Forward"))
		}
	}
	print(d)
}
# ATGATCATGAATGTACTAAATTTGAGCCCTCCGTT
