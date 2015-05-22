#' @title internal function for grabbing the HMD country short codes. 
#'
#' @description This function is called by \code{readHMDweb()} and is separated here for modularity. Assumes you have an internet connection.
#' 
#' @return a vector of HMD country short codes.
#' 
#' @export

getHMDcountries <- function(){
  HMDXXX  <- read.csv("http://www.mortality.org/countries.csv",stringsAsFactors = FALSE)
  HMDXXX  <- HMDXXX[!is.na(HMDXXX[,"ST_Per_LE_FY"]), ]
  HMDXXX$Subpop.Code
}