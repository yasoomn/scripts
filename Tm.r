#!/bin/Rscript

args <- commandArgs(trailingOnly=T)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied", call.=FALSE)
} else {
  oligo = toupper(args[1])
}

#oligo = "AAACTGGACTGGGC"

nAT <- length(grep("A|T", strsplit(oligo, "")[[1]], value = F))
print(paste("nAT:", nAT))
nCG <- length(grep("C|G", strsplit(oligo, "")[[1]], value = F))
print(paste("nCG", nCG))


Tm <- (nAT * 2) + (nCG * 4) - 5

print(paste(Tm, " °C"))
