#' estimate_ols.R
#'
#' contributors: @lachlandeer
#'
#' Run an OLS regression on data
#'

# Libraries
library(optparse)
library(rjson)
library(readr)
library(rlist)
library(felm)

# CLI parsing
option_list = list(
   make_option(c("-d", "--data"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
   make_option(c("-m", "--model"),
               type = "character",
               default = NULL,
               help = "a file name containing relationship want to estimate",
               metavar = "character"),
   make_option(c("-f", "--fixedEffects"),
               type = "character",
               default = NULL,
               help = "A set of fixed effects to include",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.rds",
                help = "output file name [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
 print_help(opt_parser)
 stop("Input data must be provided", call. = FALSE)
}
if (is.null(opt$model)){
 print_help(opt_parser)
 stop("Regression Model must be provided", call. = FALSE)
}
if (is.null(opt$fixedEffects)){
 print_help(opt_parser)
 stop("Provide the Fixed Effects to include in estimation", call. = FALSE)
}

# Load data
print("Loading data")
df <- read_csv(opt$data)

# Load Model
print("Loading Regression Model")
model_structure <- fromJSON(file = opt$model)

# Load Fixed Effects
print("Loading Subsetting Condition")
fe <- fromJSON(file = opt$fixedEffects)

# Filter data
# Construct Formula
dep_var <- model_structure$DEPVAR
exog    <- model_structure$EXOG
fixed_effects <- fe$FIXED_EFFECTS

reg_formula <- as.formula(paste(dep_var,
                                " ~ ",
                                exog,
                                " | ",
                                fixed_effects,
                                sep = "")
                                )
print(reg_formula)

# Run Regression
ols_model <- felm(reg_formula, reg_data)
summary(ols_model)

# Save output
list.save(ols_model, opt$out)
