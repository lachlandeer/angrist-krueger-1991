#' regression_table.R
#'
#' contributors: @lachlandeer
#'
#' Regression Table to Match MHE Tab 4.1.1
#'

# Libraries
library(optparse)
library(rlist)
library(magrittr)
library(purrr)
library(stargazer)

# CLI parsing
option_list = list(
   make_option(c("-fp", "--filepath"),
               type = "character",
               default = NULL,
               help = "A directory path where models are saved",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.tex",
                help = "output file name [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$filepath)){
 print_help(opt_parser)
 stop("Input filepath must be provided", call. = FALSE)
}

# Load Files
dir_path  <- opt$filepath
file_list <- list.files(dir_path, full.names = TRUE)

# model names are from the files themselves
model_names <- basename(tools::file_path_sans_ext(file_list))

# Load into a list
data <- file_list %>%
            map(list.load) %>%
            setNames(model_names)

# Create Table
stargazer(data$ols_no_fixed_effects,
          data$ols_fixed_effects,
          data$iv_no_fe,
          data$iv_1_fe,
          data$iv_2_fe,
          data$iv_3_fe,
          data$iv_4_fe,
          initial.zero = TRUE,
          align = FALSE,
          title = "Estimates of the Return to Schooling",
          dep.var.caption    = "Log Weekly Earnings",
          dep.var.labels.include = FALSE,
        #   add.lines = list(
        #       c("Restricted Model", "No", "No", "No", "Yes", "Yes", "Yes")
        #   ),
          omit.stat = c("rsq", "ser", "F"),
          df = FALSE,
          digits = 3,
          font.size = "scriptsize",
          style = "apsr",
          table.layout ="=ldc-#-t-o-a-s=n",
          no.space = TRUE,
          type = "latex",
          out = opt$out
          )
