#' @title internal function for grabbing the HFD country short codes. 
#'
#' @description This function is called by \code{readHFDweb()} and is separated here for modularity. There is likely a simpler way of coding this functionality. The vector of short codes returned only includes the fully incorporated HFD countries, not provisional countries.
#' 
#' @return a vector of HFD country short codes.
#' 
#' @importFrom XML readHTMLTable
#' 
#' @export
#' 
getHFDcountries <- function(){
    # the ugliest code I've ever written. There must be a better way..
    X <- readHTMLTable("http://www.humanfertility.org/cgi-bin/zipfiles.php",header=TRUE,
            colClasses=c("character","character"),which=2,stringsAsFactors = FALSE)
    gsub("\\s*\\([^\\)]+\\)","",X[,2])
}








