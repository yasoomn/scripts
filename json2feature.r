#!/usr/bin/env Rscript

# This script takes the JSON file generated by Pfam Scan and converts it into Jalview Features for the feature files
# written by Yasoo Morimoto on 21 June 2022

library(rjson)

PfamScan <- list()


args <- commandArgs(trailingOnly=T)
# test if there is at least one argument: if not, return an error
# TODO test if the file is a JSON
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).json", call.=FALSE)
} else {
  PfamScan = fromJSON(file = args[1])
}

createAnnotations <- function(file) {
  # This function takes the json file from PfamScan and parses it to create JalView Annotations
  Ddesc <- c()
  Dname <- c()
  SeqName <- c()
  Dfrom <- c()
  Dto <- c()
  evalue <- c()
  seqIndex <- c()
  for (domain in c(1:length(file))) {
  	Ddesc = c(Ddesc, file[[domain]][["desc"]])
  	Dname = c(Dname, file[[domain]][["name"]])
  	SeqName = c(SeqName, file[[domain]][["seq"]][["name"]])
  	Dfrom = c(Dfrom, file[[domain]][["seq"]][["from"]])
  	Dto = c(Dto, file[[domain]][["seq"]][["to"]])
  	evalue = c(evalue, file[[domain]][["evalue"]])
  	seqIndex = c(seqIndex, "-1")
  }
  data.frame(Ddesc, SeqName,seqIndex, Dfrom, Dto, Dname, evalue)
}

createLabels <- function(df) {
	# This function creates the labels for the feature file and pretty colors
  labels <- unique(df$Dname)
  labColors <- substr(hcl.colors(length(labels), palette = "zissou 1"), 2, 7)
  data.frame(labels, labColors)
}

ann <- createAnnotations(PfamScan)
labs <- createLabels(ann)
# outputs the formated file to STOUT
write.table(labs, row.names = FALSE, col.names = FALSE, sep = "\t", quote = FALSE)
cat("\nSTARTGROUP\tJalview\n")
write.table(ann, row.names = FALSE, col.names = FALSE, sep = "\t", quote = FALSE)
cat("ENDGROUP\tJalview\n")
