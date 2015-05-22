parent.path <- "/home/tim/git/TR1/TR1"
library(devtools)

document(file.path(parent.path,"HMDHFDplus"))

# increment version number
# install_github("timriffe/TimUtils", subdir = "TimUtils")
library(TimUtils)

IncrementVersion(file.path(parent.path ,"HMDHFDplus"),"01","2013-10-15")

