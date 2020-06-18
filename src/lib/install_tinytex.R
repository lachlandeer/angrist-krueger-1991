#install_tinytex.R

tinytex_package <- c("tinytex")
to_install      <- tinytex_package[!(tinytex_package %in% installed.packages()[,"Package"])]
if(length(to_install)){
    message('installing tinytex')
    install.packages(to_install)
    tinytex::install_tinytex()
}else {
   message('tinytex already installed - exiting')
}