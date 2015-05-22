parent.path <- "/home/tim/git/TR1/TR1"
library(devtools)

document(file.path(parent.path,"HMDHFDplus"))

# increment version number
# install_github("timriffe/TimUtils", subdir = "TimUtils")
library(TimUtils)

IncrementVersion(file.path(parent.path ,"HMDHFDplus"),"01","2013-10-15")

load_all(file.path(parent.path,"HMDHFDplus"))
args(build)
build(file.path(parent.path,"HMDHFDplus"),path=file.path(parent.path,"Builds"))
install.packages("/home/tim/git/TR1/TR1/HMDHFDplus_01.1.6009.tar.gz",repos=NULL,type="source")
library(HMDHFDplus)

A <- readHMDweb("USA","mltper_1x1",username=us,password=pw)
A <- readJMDweb("02","mltper_5x5")
A <- readCHMDweb("alb","mltper_5x5")
A <- readHFDweb("USA","birthsRR",username=us,password=pw)
A <- readHFCweb("USA","birthsRR")
getHFCcountries()
head(A)


install_github()