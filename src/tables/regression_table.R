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
library(tools)

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
stargazer(data$ols_no_fixed_effects, #1
          data$ols_fixed_effects, #2
          data$iv_1.no_fixed_effects, #3
          data$iv_2.no_fixed_effects, #4
          data$iv_1.fixed_effects, #5
          data$iv_3.fixed_effects, #6
          data$iv_4.fixed_effects, #7
          se = list(data$ols_no_fixed_effects$rse, #1
                    data$ols_fixed_effects$rse, #2
                    data$iv_1.no_fixed_effects$rse, #3
                    data$iv_2.no_fixed_effects$rse, #4
                    data$iv_1.fixed_effects$rse, #5
                    data$iv_3.fixed_effects$rse, #6
                    data$iv_4.fixed_effects$rse #7
                    ),
          initial.zero = TRUE,
          align = FALSE,
          title = "Estimates of the Return to Schooling",
          covariate.labels = c("Years of Education"),
          #dep.var.caption    = "Log Weekly Earnings",
          #dep.var.labels.include = FALSE,
          add.lines = list(c("Year of Birth FE", "No", "Yes", "No", "No", "Yes", "Yes", "Yes"),
                           c("Place of Birth FE", "No", "Yes", "No", "No", "Yes", "Yes", "Yes"),
                           c("Instruments", "", "", "QOB = 1", "QOB = 1 or 2", "QOB = 1", "QOB FE", "QOB $\\times$ YOB FE")
                           ),
          omit = c("Constant"),
          omit.stat = c("rsq", "ser", "F"),
          star.cutoffs = c(1e-8, 1e-8, 1e-8), # make star cutoff so low they go away
          notes        = "Sometimes you just have to start over.",
          notes.append = FALSE,
          notes.align = "l",
          df = FALSE,
          digits = 3,
          font.size = "scriptsize",
          style = "apsr",
          table.layout ="-lc-#-t-a-s=n",
          no.space = TRUE,
          type = "latex",
          out = opt$out
          )
