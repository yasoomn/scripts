#!/bin/Rscript

packages <- c("tidyr", "dplyr")

install.packages(setdiff(packages, rownames(installed.packages())))
suppressPackageStartupMessages({
library(tidyr)
library(dplyr)
library(optparse)
})

optionList <- list(make_option(c("-v", "--verbose"), action = "store_true",
																default = FALSE, help = "Print extra output [default]"),
make_option(c("-o", "--OD"), action = "store", help = "File containing the table with optical density measurements"),
make_option(c("-m", "--measurement"), action = "store"),
make_option(c("-l", "--labels"), action = "store", help = ""),
make_option(c("-f", "--filename"), action = "store", help = "Filename to print the output to. If no filename is provided, output is printed to STDOUT")
)

opt <- parse_args(OptionParser(option_list = optionList,
															 usage = "usage: %prog [sequences.fasta]")
)

# parse OD values

elongate_data <- function(csv_path) {
	# load the file
	data <- read.csv(csv_path, row.names = 1)
# Separate rows with temperature and time
	data.info <- data[1:2, ] %>% 
		t() %>% 
		as.data.frame()
	# Add column with cycle number
	data.info$cycle <- c(1:nrow(data.info))
	# rename columns
	names(data.info) <- c("time", "temp", "cycle")

	# Separate rows with measurements
	data.values <- data %>% slice_tail(n = nrow(data) - 2) %>% t() %>% as.data.frame()
	# How many wells were used?
	wellsN = data %>% slice_tail(n = nrow(data) - 2) %>% nrow()
	data.values$cycle <- c(1:nrow(data.values))
	data.values.long <- data.values %>% pivot_longer(cols = 1:wellsN)
	
	# Combine both
	data.long <- full_join(data.info, data.values.long, by = "cycle") 
	data.long
}

long.output <- elongate_data(opt$measurement)
names(long.output) <- c("time", "temp", "cycle", "well", "measurement")


# Create the X and Y positions of the wells  as separate columns
	long.output <- long.output %>% 
		rowwise() %>%
		mutate(well_x = substr(well, 2, 3), well_y = substr(well, 1, 1))

# add the OD measurement

if (!is.null(opt$OD)) {
	long.OD <- elongate_data(opt$OD)
	names(long.OD) <- c("time", "temp", "cycle", "well", "OD")
	long.output <- full_join(long.output, long.OD %>% select(well, cycle, OD), by = c("cycle", "well" ))
	
}

if (!is.null(opt$labels)) {
	plate = read.csv(opt$labels, header = T, row.names = 1, colClasses = "character")
	# create a data.frame with the correct dimensions and a well column and add the labels
	plate_long <- data.frame(well = paste(rep(LETTERS[1:8], each = 12), 1:12, sep = ""), 
	label = pivot_longer(plate, values_to = "label", cols = 1:12)$label)
	## Previous inner_join
	long.output <- inner_join(long.output, plate_long, by = "well")

}

write.csv(long.output %>%  drop_na(time) # remove empty rows
					, file = ifelse(is.null(opt$filename), "", opt$filename), row.names = F)
