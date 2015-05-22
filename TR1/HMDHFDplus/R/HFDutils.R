
# FILE CONTENTS:

# 1) HFDparse()
# 2) getHFDcountries()
# 3) getHFDdate()
# 4) getHFDitemavail()

############################################################################
# HFDparse()
############################################################################
#'
#' @title internal function for modifying freshly read HFD data in its standard form
#' 
#' @description called by \code{readHFD()} and \code{readHFDweb()}. We assume there are no factors in the given data.frame and that it has been read in from the raw text files using something like: \code{ read.table(file = filepath, header = TRUE, skip = 2, na.strings = ".", as.is = TRUE)}. This function is visible to users, but is not likely needed directly.
#' 
#' @param DF a data.frame of HFD data, freshly read in.
#' 
#' @return DF same data.frame, modified so that columns are of a useful class. If there were open age categories, such as \code{"-"} or \code{"+"}, this information is stored in a new dummy column called \code{OpenInterval}.
#' 
#' @export
#' 
HFDparse <- function(DF){
	if (any(c("Age","Cohort","ARDY") %in% colnames(DF))){
		# assuming that if there are two such columns that the open age, etc, rows will always agree.    
		DF$OpenInterval <- FALSE
		if ("Age" %in% colnames(DF)){
			Pluses     <- grepl(pattern = "\\+", DF$Age )
			Minuses    <- grepl(pattern = "\\-", DF$Age )
			DF$Age     <- age2int(DF$Age)    
			DF$OpenInterval <- DF$OpenInterval | Pluses | Minuses
		}
		if ("ARDY" %in% colnames(DF)){
			Pluses     <- grepl(pattern = "\\+", DF$ARDY )
			Minuses    <- grepl(pattern = "\\-", DF$ARDY )
			DF$ARDY     <- age2int(DF$ARDY)    
			DF$OpenInterval <- DF$OpenInterval | Pluses | Minuses
		}
		if ("Cohort" %in% colnames(DF)){
			Pluses     <- grepl(pattern = "\\+", DF$Cohort )
			Minuses    <- grepl(pattern = "\\-", DF$Cohort )
			DF$Cohort  <- age2int(DF$Cohort)   
			DF$OpenInterval <- DF$OpenInterval | Pluses | Minuses
		}
	}
	DF
}

############################################################################
# getHFDcountries()
############################################################################

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
	X <- XML::readHTMLTable("http://www.humanfertility.org/cgi-bin/zipfiles.php",header=TRUE,
			colClasses=c("character","character"),which=2,stringsAsFactors = FALSE)
	gsub("\\s*\\([^\\)]+\\)","",X[,2])
}


############################################################################
# getHFDdate()
############################################################################

#' @title internal function for grabbing the date of last update for a given HFD country
#' 
#' @description called by \code{readHFDweb()}. This assumes that \code{CNTRY} is actually available in the HFD. 
#' 
#' @param CNTRY HFD country short code.
#' 
#' @return character string of eight integers representing the date as \code{"yyyymmdd"}.
#' 
#' @importFrom RCurl getURL
#' 
#' @export
#' 
getHFDdate <- function(CNTRY){
	CountryURL      <- paste0("http://www.humanfertility.org/cgi-bin/country.php?country=",CNTRY)
# date of last update will be the most common component, it turns out, since it forms part of the links:
	partssummary    <- table(unlist(strsplit(RCurl::getURL(CountryURL), "\\\\")))
	LastUpdate      <- names(partssummary)[which.max(partssummary)]
	# this isn't a date string, just 8 digits squashed together yyyymmdd
	LastUpdate
}


############################################################################
# getHFDitemavail()
############################################################################

#' @title internal function for grabbing the available data item names for a given country.
#' 
#' @description called by \code{readHFDweb()}. This assumes that \code{CNTRY} is actually available in the HFD. 
#' 
#' @param CNTRY HFD country short code.
#' 
#' @return a vector of item names. These are the file base names, and only need the extension \code{.txt} added in order to get te file name.
#' 
#' @importFrom RCurl getURL
#' 
#' @export
#' 
getHFDitemavail <- function(CNTRY){
	# again, very ugly parsing, there must be a better way
	CountryURL      <- paste0("http://www.humanfertility.org/cgi-bin/country.php?country=",CNTRY)
# date of last update will be the most common component, it turns out, since it forms part of the links:
	partssummary    <- table(unlist(strsplit(RCurl::getURL(CountryURL), "\\\\")))
	partsasfr       <- table(unlist(strsplit(RCurl::getURL(paste0(CountryURL,"&tab=asfr&t1=3&t2=4")), "\\\\")))
	partsft         <- table(unlist(strsplit(RCurl::getURL(paste0(CountryURL,"&tab=ft&t1=5&t2=6")), "\\\\")))
	parts           <- c(names(partssummary), names(partsasfr),names(partsft))
	
	items           <- unlist(lapply(strsplit(parts, split = "&"),"[[",1))
	items           <- gsub(CNTRY,"",gsub("\\.txt","",items[grepl(items, pattern = ".txt")]))
	items
}


