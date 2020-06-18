#' download_data.R
#'
#' contributors: @lachlandeer
#'
#' Downloads angrist_krueger_1991 data set from Angrist website
#'

# Libraries
library(optparse)

 # CLI parsing
option_list = list(
    make_option(c("-u", "--url"),
                type = "character",
                default = NULL,
                help = "weblink to download data from",
                metavar = "character"),
	make_option(c("-d", "--dest"),
                type = "character",
                default = "out.zip",
                help = "downloaded zip archive [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$url)){
  print_help(opt_parser)
  stop("URL must be provided", call. = FALSE)
}

# download it!
download.file(opt$url, opt$dest)
