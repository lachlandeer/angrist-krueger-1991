#' gen_reg_vars.R
#'
#' contributors: @lachlandeer
#'
#' Unzip data & Create remaining variables for regression analysis
#'

# Libraries
library(optparse)
library(readr)
library(dplyr)
library(magrittr)

 # CLI parsing
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a zip file to extract data from",
                metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.csv",
                help = "csv to save data to [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("A zip archive must be provided", call. = FALSE)
}

# Load data
col_names <- c('log_wage',
               'education',
               'year_born',
               'quarter_born',
               'state_born')

df <- read_table(opt$data,
                 col_names = col_names)

# Create variables
df %<>%
    mutate(born_q1 = if_else(quarter_born ==1,
                                TRUE,
                                FALSE),
           born_first_half = if_else(quarter_born ==1 | quarter_born ==2,
                                TRUE,
                                FALSE),
           age_quarters = (80 - year_born -1 )*4 + quarter_born
           )

# Save data
print("saving output")
write_csv(df, opt$out)
