#' cohort_summary.R
#'
#' contributors: @lachlandeer
#'
#' Create summary statistics by birth cohort
#'

# Libraries
library(optparse)
library(readr)
library(dplyr)
library(magrittr)
library(zoo)
library(lubridate)

 # CLI parsing
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a data set to work on",
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
  stop("A data set must be provided", call. = FALSE)
}

# Load data
df <- read_csv(opt$data)

# Compute Summary Measures
group_stats <- df %>%
        mutate(year_born = year_born + 1900,
               birth_cohort = as.yearqtr(paste(year_born, quarter_born),
                                        "%Y %q")
                ) %>%
        group_by(birth_cohort) %>%
        summarize(
            education = mean(education, na.rm = TRUE),
            log_wage  = mean(log_wage, na.rm = TRUE),
            qob = median(quarter(birth_cohort))
        ) %>%
        mutate(first_quarter = qob ==1)

# Save data
print("saving output")
write_csv(group_stats, opt$out)
