
# install_r_packages.R
#
# Installs R packages required for project if not already installed.
#

# Load Requirements file
packages <- as.list(read.delim("REQUIREMENTS.txt", sep= "\n",
                               header = FALSE,
                               col.names = c("to_check"),
                               stringsAsFactors = FALSE
                               ))

# Gather List of Installed Packages
installed_packages <- installed.packages()[, "Package"]

# Find if any packages are not installed
to_install <- packages[["to_check"]][!(packages[["to_check"]] %in% installed_packages)]


# If any packages are not installed, install them
if(length(to_install > 0)){
    print("Installing packages that are missing!")
    install.packages(to_install, repos = "https://cloud.r-project.org/")
}else{
    print("All packages are installed on your system!")
}
