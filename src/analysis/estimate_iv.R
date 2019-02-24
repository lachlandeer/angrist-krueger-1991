#' estimate_iv.R
#'
#' contributors: @lachlandeer
#'
#' Run an IV regression on data
#'

# Libraries
library(optparse)
library(rjson)
library(readr)
library(rlist)
library(lfe)

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
   make_option(c("-i", "--instruments"),
               type = "character",
               default = NULL,
               help = "A set of instruments",
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
if (is.null(opt$instruments)){
 print_help(opt_parser)
 stop("Provide the Instrumental Variables to include in estimation", call. = FALSE)
}

# Load data
print("Loading data")
df <- read_csv(opt$data)

# Load Model
print("Loading Regression Model")
model_structure <- fromJSON(file = opt$model)

# Load Fixed Effects
print("Loading Fixed Effect Specification")
fe <- fromJSON(file = opt$fixedEffects)

# Load Fixed Effects
print("Loading Instrument Specification")
iv <- fromJSON(file = opt$instruments)

# Filter data
# Construct Formula
dep_var  <- model_structure$DEPVAR
endog    <- model_structure$TREATMENT
fixed_effects <- fe$FIXED_EFFECTS
instruments   <- iv$INST

first_stage <- paste0("(",
                        endog,
                        "~",
                        instruments,
                        ")"
                        )
print("first stage regression:")
print(first_stage)

reg_formula <- as.formula(paste(dep_var,
                                " ~ ",
                                "1",
                                " | ",
                                fixed_effects,
                                " | ",
                                first_stage,
                                sep = "")
                                )
print("lfe formula:")
print(reg_formula)

# Run Regression
model <- felm(reg_formula, df)
summary(model)

# Save output
## Here is some formatting so we can nicely get coefficient table later
rownames(model$beta)[rownames(model$beta) == "`education(fit)`"] <- "education"
rownames(model$coefficients)[rownames(model$coefficients) == "`education(fit)`"] <- "education"
names(model$se)[names(model$se) == "`education(fit)`"] <- "education"
names(col8$rse)[names(col8$rse) == "`education(fit)`"] <- "education"


## Now save
list.save(model, opt$out)
