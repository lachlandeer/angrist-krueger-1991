#install_rmd.R

rmd_packages <- c("rmarkdown", "knitr")
to_install      <- rmd_packages[!(rmd_packages %in% installed.packages()[,"Package"])]
if(length(to_install)){
    message('installing packages')
    install.packages(to_install)
}else {
   message('packages already installed - exiting')
}