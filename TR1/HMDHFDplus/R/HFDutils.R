
# FILE CONTENTS:

# 1) HFDparse()
# 2) getHFDcountries()
# 3) getHFDdate()
# 4) getHFDitemavail()
# 5) HFCparse()
# 6) getHFCcountries()

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
#' @description This function is called by \code{readHFDweb()} and is separated here for modularity. We include both main and provisional countries in the grab.
#' 
#' @return a `tibble` with three columns `Country`, `link` and `CNTRY` (the country short code)
#' 
#' @importFrom rvest read_html html_element html_elements html_attr html_text2
#' @importFrom dplyr tibble mutate
#' @
#' 
#' @export
#' 
getHFDcountries <- function(){

  # xpath to the main country list
  xpath <- "/html/body/div[1]/div/div[3]/div[3]"
  
  html <- read_html("https://www.humanfertility.org")
  links <-
    html |>
    html_element(xpath=xpath) |>
    html_elements("a") |>
    html_attr("href")
  
  cntry_names <-
    html |> 
    html_element(xpath=xpath) |> 
    html_elements("a") |> 
    html_text2()
  
  # preliminary releases are in a separate list
  xpath_prelim <- "/html/body/div[1]/div/div[4]/div[3]"
  links2 <-
    html |> 
    html_element(xpath=xpath_prelim) |> 
    html_elements("a") |> 
    html_attr("href")
  
  cntry_names2 <-
    html |> 
    html_element(xpath=xpath_prelim) |> 
    html_elements("a") |>
    html_text2()
  
  # compose table and extract country code from links:
  tibble(Country= c(cntry_names,cntry_names2), link = c(links, links2)) |> 
    mutate(CNTRY =  sub(".*=", "", link))
  
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
#' @importFrom rvest read_html html_elements html_text2
#' @importFrom lubridate dmy year month day
#' @importFrom stringr str_pad
#' 
#' @export
#' 
getHFDdate <- function(CNTRY){
  CountryURL <- paste0("https://www.humanfertility.org/Country/Country?cntr=", CNTRY)
  html       <- read_html(CountryURL)
  xpath      <- "/html/body/div[1]/div/div[3]/div[1]/div[1]/div[2]/span"

  LastUpdate <- 
    html |>  
    html_elements(xpath = xpath) |> 
    html_text2() |>
    sub(pattern = ".*: ", replacement = "", ) |>
    dmy()
  
  if(length(LastUpdate)==0){
    stop("I can't find the date of the latest update to the data for this
          country. The Human Fertility Database website may have changed")
  }
  date_out <- paste0(year(LastUpdate),
                     str_pad(month(LastUpdate),
                             width = 2,
                             side="left",
                             pad="0"),
                     str_pad(day(LastUpdate),
                             width = 2,
                             side="left",
                             pad="0"))
  
  
  # this isn't a date string, just 8 digits squashed together yyyymmdd
  date_out
}



############################################################################
# 4) getHFDitemavail()
############################################################################

#' @title List the available data item names for a given HFD country.
#' 
#' @description called by \code{readHFDweb()}. This assumes that \code{CNTRY} is actually available in the HFD. 
#' 
#' @param CNTRY HFD country short code.
#' 
#' @return a tibble of all available data files for the selected country. There are several useful indentifiers that can help determine the appropriate file, including the `measure` and `subtype` as detected from the html table properties, and `lexis` and `parity` as detected either from the file names or the table properties.
#' 
#' @importFrom janitor clean_names
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr rename filter bind_rows bind_cols mutate case_when if_else select
#' @impotFrom rvest read_html html_table html_elements html_text2 html_attr
#' 
#' @export
#' 
getHFDitemavail <- function(CNTRY){
 
  CountryURL <- paste0("https://www.humanfertility.org/Country/Country?cntr=", CNTRY)
  
  tidy_chunk <- function(X){
    X |>
      clean_names() |>
      rename("measure" = x) |> 
      pivot_longer(-measure,names_to = "subtype",values_to = "years") |> 
      filter(measure != "")
  }
  
  html <- read_html(CountryURL)
  
  cntry_tables<-
    html |>
    html_table() |>
    lapply(FUN = tidy_chunk) |>
    bind_rows() |>
    filter(years != "-")
  
  years <-
    html |>
    html_elements("table") |>
    html_elements("tr")|>
    html_elements("a") |>
    html_text2()
  
  links <-
    html |>
    html_elements("table") |>
    html_elements("tr")|>
    html_elements("a") |>
    html_attr("href")
  
  # years2 was a check to ensure join was row-matched properly
  linksyears <- tibble(link = links, years2 = years)
  
  # just need to infer some identifier columns based mostly on file names,
  # and similar inferences
  item_table <- 
  cntry_tables |>
    bind_cols(linksyears) |>
    filter(grepl(link,pattern="*.txt")) |>
    mutate(lexis = case_when(grepl(link,pattern = "TR") ~ "triangle",
                             grepl(link,pattern = "RR") ~ "age-period",
                             grepl(link,pattern = "VH") ~ "age-cohort",
                             grepl(link,pattern = "VV") ~ "period-cohort",
                             grepl(link,pattern = "pa") ~ "period",
                             grepl(link,pattern = "pft") ~ "period",
                             grepl(link,pattern = "patfr") ~ "period",
                             grepl(link,pattern = "pmab") ~ "period",
                             grepl(link,pattern = "pmabc") ~ "period",
                             grepl(link,pattern = "cft") ~ "cohort",
                             grepl(link,pattern = paste0(CNTRY,"mi")) ~ "period",
                             grepl(link,pattern =  paste0(CNTRY,"mic")) ~ "period",
                             grepl(link,pattern =  paste0(CNTRY,"births")) ~ "mixed",
                             grepl(link,pattern =  paste0(CNTRY,"monthly")) ~ "period",
                             grepl(link,pattern =  paste0(CNTRY,"parity")) ~ "mixed"), 
    subtype = gsub('[0-9]+', '', subtype),
           subtype = sub("_$","",subtype),
           subtype = if_else(subtype == "years", "Input data", subtype)) |> 
  select(-years2) |>
  mutate(item = link %>% 
           str_split(pattern = "\\\\") %>% 
           lapply(rev) %>% 
           lapply('[',1) %>% 
           unlist() %>% 
           gsub(pattern = ".txt", replacement = ""))

  item_table 
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
#' @description The function returns a list of population codes used in the Human Fertility Collection (HFC). Optionally, it also can return a data.frame with both the full population name and short code.
#' 
#' @param names logical. Default \code{FALSE} Should a \code{data.frame} matching full country names to short codes be given?
#' 
#' @return either a character vector of short codes (default) or a \code{data.frame} of country names and codes.
#' 
#' @importFrom rvest read_html
#' @importFrom rvest html_element
#' @importFrom rvest html_table
#' @export
#' 
#' @examples 
#' \dontrun{
#' getHFCcountries()
#' getHFCcountries(names = TRUE)
#' }
getHFCcountries <- function(names = FALSE){
	Codes <-
	html_table(
	  html_element(
	    read_html("http://www.fertilitydata.org/cgi-bin/country_codes.php"), 
	    "table"),
	  header = TRUE)

	
	if (names){
		return(Codes)
	} else {
		return(Codes$Code)
	}
}







