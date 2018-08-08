
# FILE CONTENTS:

# 1) HFDparse()
# 2) getHFDcountries()
# 3) getHFDdate()
# 4) getHFDitemavail()
# 5) HFCparse()
# 6) getHFCcountries()
# 7) extract_HFD_items()

############################################################################
# 1) HFDparse()
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
#' @details This parse routine is based on the subjective opinions of the author...
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
# 2) getHFDcountries()
############################################################################

#' @title internal function for grabbing the HFD country short codes. 
#'
#' @description This function is called by \code{readHFDweb()} and is separated here for modularity. There is likely a simpler way of coding this functionality. The vector of short codes returned only includes the fully incorporated HFD countries, not provisional countries.
#' 
#' @return a vector of HFD country short codes.
#' 
#' @importFrom XML readHTMLTable
#' @importFrom httr GET
#' 
#' @export
#' 
getHFDcountries <- function(){
	# the ugliest code I've ever written. There must be a better way..
  hfd_url <- "https://www.humanfertility.org/cgi-bin/zipfiles.php"
  some_html <- httr::GET(hfd_url)
  X <- XML::readHTMLTable(XML::htmlParse(some_html),
                          header = TRUE, 
                          colClasses = c("character", "character"), 
                          which = 2, 
                          stringsAsFactors = FALSE)
	gsub("\\s*\\([^\\)]+\\)", "", X[,2])
}


############################################################################
# 3) getHFDdate()
############################################################################

#' @title internal function for grabbing the date of last update for a given HFD country
#' 
#' @description called by \code{readHFDweb()}. This assumes that \code{CNTRY} is actually available in the HFD. 
#' 
#' @param CNTRY HFD country short code.
#' 
#' @return character string of eight integers representing the date as \code{"yyyymmdd"}.
#' 
#' @importFrom httr GET content
#' 
#' @export
#' 
getHFDdate <- function(CNTRY){
  CountryURL      <- paste0("http://www.humanfertility.org/cgi-bin/country.php?",
                            "country=", CNTRY)
  #get date string by finding the permalink listed at the bottom of page.
  html_country    <- httr::GET(CountryURL)
  htmlstr <- httr::content(html_country, as="text")
  LastUpdate <- regmatches(htmlstr, regexpr("(?<=update=)20[0-9]{6}", htmlstr,
                                            perl=T))
  if(length(LastUpdate)==0){
    stop("I can't find the date of the latest update to the data for this
          country. The Human Fertility Database website may have changed")
  }
  # this isn't a date string, just 8 digits squashed together yyyymmdd
  LastUpdate
}


############################################################################
# 4) getHFDitemavail()
############################################################################

#' @title internal function for grabbing the available data item names for a given country.
#' 
#' @description called by \code{readHFDweb()}. This assumes that \code{CNTRY} is actually available in the HFD. 
#' 
#' @param CNTRY HFD country short code.
#' 
#' @return a vector of item names. These are the file base names, and only need the extension \code{.txt} added in order to get the file name.
#' 
#' @importFrom httr GET content
#' 
#' @export
#' 
getHFDitemavail <- function(CNTRY){
  # It seems this function will only worked if you are logged in
	CountryURL      <- paste0("https://www.humanfertility.org/cgi-bin/",
	                          "country.php?country=",CNTRY)

	# vector of names of tabs on each HFD page
	tabs <- c("si", "asfr", "ft")

	item_list <- lapply(tabs, function(tab){
	  # iterate through each tab and construct URL
	  url <- paste0(CountryURL, "&tab=", tab)
	  tab_html  <- httr::content(httr::GET(url))
	  return(extract_HFD_items(tab_html, CNTRY))
	})
	
	return(unlist(item_list))
}



############################################################################
# 5) HFCparse()
############################################################################

#'
#' @title HFCparse internal function for modifying freshly read HCD data in its standard form
#' 
#' @description called by \code{readHFC()} and \code{readHFCweb()}. We assume there are no factors in the given data.frame and that it has been read in from the raw text files using something like: \code{ read.csv(file = filepath, stringsAsFactors = FALSE, na.strings = ".", strip.white = TRUE)}. This function is visible to users, but is not likely needed directly.
#' 
#' @param DF a data.frame of HFC data, freshly read in.
#' 
#' @return DF same data.frame, modified so that columns are of a useful class. If there were open age categories, such as \code{"-"} or \code{"+"}, this information is stored in a new dummy column called \code{OpenInterval}. Values of 99 or -99 in the \code{AgeInterval} column are replaced with \code{"+"} and \code{"-"}, respectively. \code{Year} taken from \code{Year1}, and \code{YearInterval} is given, rather than \code{Year2}. Users wishing for a central time point should bear this is mind. The column \code{Country} is renamed \code{CNTRY}. Otherwise, columns in this database are kept in the \code{data.frame}, in case they may be useful. 
#' 
#' @details This parse routine is based on the subjective opinions of the author...
#' 
#' @export
#'
HFCparse <- function(DF){
	# get just one year, and treat it like age groups, where we
	# mark the lower bound and provide a year interval column
	DF$Year         <- DF$Year1 
	DF$YearInterval <- DF$Year2 - DF$Year1 + 1
	DF$Year1        <- DF$Year2        <- NULL
	
	# use standard AgeInterval name, change 99s. TFR doesn't have this.
	if ("AgeInt" %in% colnames(DF)){
		DF$AgeInterval  <- ifelse(DF$AgeInt == -99,"-", ifelse(DF$AgeInt == 99, "+", DF$AgeInt))
		DF$AgeInt       <- NULL
		DF$OpenInterval <- DF$AgeInterval != "1"
	}
	
	colnames(DF)[colnames(DF) == "Country"] <- "CNTRY"
	
	invisible(DF)
}

############################################################################
# 6) getHFCcountries()
############################################################################

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
#' @export
#' 
#' @examples 
#' \dontrun{
#' getHFCcountries()
#' getHFCcountries(names = TRUE)
#' }
getHFCcountries <- function(names = FALSE){
	Codes <- XML::readHTMLTable("http://www.fertilitydata.org/cgi-bin/country_codes.php", 
			stringsAsFactors = FALSE)[[1]]
	if (names){
		return(Codes)
	} else {
		return(Codes$Code)
	}
}



############################################################################
# 7) extract_HFD_items()
############################################################################
#' @title Extract names of HFD items from HTML
#'
#' @description Extract names of Human fertility database datasets from an
#' HTML page. Links are extracted from html, and for each link, any text falling
#' between the provided country code and a .txt extension is returned
#'
#' @param html_content An object of class \code{xml_document} taken from a
#' country page of the HFD website, typically the result of
#' \code{httr::content(httr::GET(url))}
#'
#' @param CNTRY A string given one of the country codes used by HFD. See
#' \code{getHFDcountries} for a function which lists available countries.
#'
#' @return A vector of characters, each of which is an item available for
#' download
#'
#' @importFrom XML getHTMLLinks htmlParse
#'
extract_HFD_items <- function(html_content,CNTRY) {
  parsed_html <- XML::htmlParse(html_content)
  all_links <- XML::getHTMLLinks(parsed_html)
  item_regex <- regexpr(paste0("(?<=",CNTRY,")[A-Za-z0-9]+(?=\\.txt)"), 
          all_links, perl=T)
  item_names <- regmatches(all_links, item_regex)
  return(item_names)
}





