#' education_by_cohort.R
#'
#' contributors: @lachlandeer
#'
#' Figure summarizing Average earnings by cohort
#'

# Libraries
library(optparse)
library(readr)
library(ggplot2)
library(zoo)
library(dplyr)

 # CLI parsing
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a data set to work on",
                metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.pdf",
                help = "pdf to save figure to [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("A data set must be provided", call. = FALSE)
}

# Load data
df <- read_csv(opt$data) %>%
        mutate(birth_cohort = as.yearqtr(birth_cohort))

# Create Figure
ggplot(df, aes(x = birth_cohort, y = log_wage)) +
    geom_line(color = "dodger blue") +
    geom_point(aes(shape = first_quarter), color = "blue", size = 3) +
    geom_text(aes(label=qob),hjust=0, vjust=-1) +
    scale_y_continuous(breaks = seq(5.85, 5.95, by = 0.1)) +
    ylim(5.86, 5.94) +
    scale_x_continuous(breaks = round(seq(1930, 1940, by = 1),1)) +
    xlab("Year of Birth") +
    ylab("Log Weekly Earnings") +
    ggtitle("Average Log Weekly Wage by Quarter of Birth") +
    theme_bw() +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5))

ggsave(opt$out)
