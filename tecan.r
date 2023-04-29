#!/bin/Rscript

packages <- c("tidyr", "dplyr")

install.packages(setdiff(packages, rownames(installed.packages())))  

suppressPackageStartupMessages({

library(tidyr)
library(dplyr)
})

args <- commandArgs(trailingOnly=T)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).csv", call.=FALSE)
} else {
  tecanOutput <- read.csv(file = args[1])
	labelPlate <- args[2] 
}

firstLine <- grep("Zyklus", tecanOutput$Programm..Tecan.i.control)

tecanOutput.trimmed <- read.csv(args[1], skip = firstLine, nrows = 100)

# discard columns with no information and rows with NAs
tecanOutput.trimmed <- na.omit(tecanOutput.trimmed[,colSums(is.na(tecanOutput.trimmed))<nrow(tecanOutput.trimmed)])

tecanOutput.cycles <- tecanOutput.trimmed %>% 
	filter(row_number() > 2) %>% 
	pivot_longer(cols = c(2:4), names_to = "cycle", names_prefix = "X")


tecanOutput.info <- read.csv(args[1], skip = firstLine - 1) %>% 
	filter(row_number() < 4) %>% 
	t()

colnames(tecanOutput.info) <- c("cycle", "time", "temp")
colnames(tecanOutput.cycles) <- c("well", "cycle", "value")

tecanOutput.info <- as.data.frame(tecanOutput.info) %>% 
	filter(row_number() > 1) %>% 
	drop_na()

tecanOutput.info$cycle <- as.double(tecanOutput.info$cycle)
tecanOutput.cycles$cycle <- as.double(tecanOutput.cycles$cycle)


## handle labels

if (!is.na(args[2])) {
	## read labels table
	plate = read.csv(args[2], header = T, row.names = 1)
	# create a data.frame with the correct dimensions and a well column and add the labels
	plate_long <- data.frame(well = paste(rep(LETTERS[1:8], each = 12), 1:12, sep = ""), 
	label = pivot_longer(plate, values_to = "label", cols = 1:12)$label)
	output <- inner_join(tecanOutput.info, tecanOutput.cycles) %>%inner_join(plate_long)
} else {
	## If no table with well labels is provided, just output the contents in long format
	output <- inner_join(tecanOutput.info, tecanOutput.cycles)
}

write.csv(output, file = "", row.names = F)
