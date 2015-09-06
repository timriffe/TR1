parent.path <- "/home/tim/git/TR1/TR1"
setwd("/home/tim/git/TR1/TR1/HMDHFDplus")
dir()
library(devtools)

document(file.path(parent.path,"HMDHFDplus"))

# increment version number
# install_github("timriffe/TimUtils", subdir = "TimUtils")
library(TimUtils)

IncrementVersion(file.path(parent.path ,"HMDHFDplus"),"01","2013-10-15")

load_all(file.path(parent.path,"HMDHFDplus"))
args(build)
build(file.path(parent.path,"HMDHFDplus"),path=file.path(parent.path,"Builds"))
#install.packages("/home/tim/git/TR1/TR1/HMDHFDplus_01.1.6009.tar.gz",repos=NULL,type="source")
#library(HMDHFDplus)
#
#A <- readHMDweb("USA","mltper_1x1",username=us,password=pw)
#head(A)
#A <- readJMDweb("02","mltper_5x5")
#head(A)
#A <- readCHMDweb("alb","mltper_5x5")
#head(A)
#A <- readHFDweb("USA","birthsRR",username=us,password=pw)
#head(A)
#A <- readHFCweb("USA","ASFRstand_BO")
#head(A)
#USpop <- readHMDweb("USA","Population",username = us, password = pw)
#head(USpop)

library(devtools)

check("/home/tim/git/TR1/TR1/HMDHFDplus")
sessionInfo()

# just to make sure it builds for Windows.
build_win("/home/tim/git/TR1/TR1/HMDHFDplus")

devtools::revdep_check("/home/tim/git/TR1/TR1/HMDHFDplus")
