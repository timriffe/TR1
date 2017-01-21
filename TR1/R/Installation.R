# 
remove.packages("HMDHFDplus")
library(devtools)
install_github("timriffe/TR1/TR1/HMDHFDplus")
library(HMDHFDplus)
load_all("/home/tim/git/TR1/TR1/HMDHFDplus")
USA <- readHMDweb(CNTRY = "USA",item = "mltper_1x1", username = us, password = pw)
head(USA)


USA <- readHFDweb(CNTRY = "USA",item = "mabRR", username = us, password = pw)



