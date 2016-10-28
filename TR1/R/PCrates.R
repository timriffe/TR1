 
# Author: tim
###############################################################################


# assuming I have pop1, pop2, and TL, TU,
# then we should be able to derive PC 
# exposures that are commensurable with 
# the AC exposures already produced by HMD (v5, assuming uniformity)
#

# actually, these would follow the same formulas as
# the AP rates, except that the upper triangle comes
# from a higher age.
# In the case of age 0, we use births and P2?

# ergo:
#     P(x,t) / 2 - 1 / 3 DU(x,t) +
# P(x+1,t+1) / 2 + 1 / 3 DL(x+1,t+1)
library(reshape2)
library(HMDHFDplus)
P       <- readHMDweb("ESP","Population",username=us, password = pw)
D       <- readHMDweb("ESP","Deaths_lexis",username=us, password = pw)
B       <- readHMDweb("ESP","Births",username=us, password = pw)
D$Lexis <- ifelse(D$Year - D$Age == D$Cohort, "TL","TU")
D       <- D[!is.na(D$Lexis), ]
TLM     <- acast(D[D$Lexis == "TL", ], Age~Year, value.var = "Male")
TUM     <- acast(D[D$Lexis == "TU", ], Age~Year, value.var = "Male")
P1      <- acast(P, Age~Year, value.var = "Male1")
P2      <- acast(P, Age~Year, value.var = "Male2")
BM      <- B$Male
names(BM) <- B$Year
# say we name VV (PC) parallelograms for the horizontal
# birthday bar crossing through the middle

dim(P1)
dim(P2)
dim(TLM)
dim(TUM)

# Years conform, so no worries with column alignment,
# only need to make sure rows are right. BM looks like
# it needs to tack onto P1. No, better calc infant tri
# separately. or? ya, just use a different formula.
hist(P2[1, ] - BM)

