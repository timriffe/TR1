


#' @title getHFCcountries a function to grab all present country codes used in the Human Fertility Collection
#' 
#' @description The function returns a list of population codes used in the Human Fertiltiy Collection (HFC). Optionally, it also can return a data.frame with both the full population name and short code.
#' 
#' @param names logical. Default \code{FALSE} Should a \code{data.frame} matching full country names to short codes be given?
#' 
#' @return either a character vector of short codes (default) or a \code{data.frame} of country names and codes.
#' 
#' @importFrom XML readHTMLTable
#' 
#' @examples 
#' \dontrun{
#' getHFCcountries()
#' getHFCcountries(names = TRUE)
#' }
getHFCcountries <- function(names = FALSE){
    Codes <- readHTMLTable("http://www.fertilitydata.org/cgi-bin/country_codes.php", 
            stringsAsFactors = FALSE)[[1]]
    if (names){
        return(Codes)
    } else {
        return(Codes$Code)
    }
}






