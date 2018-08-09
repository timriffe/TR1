parent.path <- "/home/tim/git/TR1/TR1"
setwd("/home/tim/git/TR1/TR1/HMDHFDplus")
dir()
library(devtools)

document(file.path(parent.path,"HMDHFDplus"))

# increment version number
# install_github("timriffe/TimUtils", subdir = "TimUtils")
library(TimUtils)

#IncrementVersion(file.path(parent.path ,"HMDHFDplus"),"1","2013-10-15")

load_all(file.path(parent.path,"HMDHFDplus"))

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
# 0 errors ✔ | 0 warnings ✔ | 0 notes ✔
sessionInfo()


# windows checks on different versions:
# August 9, 2018
check_win_release()    # sent OK
check_win_devel()      # sent OK
check_win_oldrelease() # sent OK


#devtools::install_github("r-hub/rhub")
library(rhub)
validate_email()
check_on_linux()
check_on_windows()

use_cran_badge()
use_revdep()
revdepcheck::revdep_check()

devtools::install_github("GuangchuangYu/badger")
library(badger)
badge_github_version("timriffe/TR1/TR1/HMDHFDplus")
?badge_github_version
badger:::check_github("timriffe/TR1/TR1/HMDHFDplus")
rvcheck:::check_github_gitlab("timriffe/TR1/TR1/HMDHFDplus")
badger:::badge_github_version("timriffe/DemoTools","yellow")

