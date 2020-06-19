#install_tinytex.R

tinytex_package <- c("tinytex")
to_install      <- tinytex_package[!(tinytex_package %in% installed.packages()[,"Package"])]
if(length(to_install)){
    message('installing tinytex package')
    install.packages(to_install)
}else {
   message('tinytex already installed - exiting')
}

message('installing latex via tinytex')
tinytex::install_tinytex()
