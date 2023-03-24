
# FILE CONTENTS:

# 1) HMDparse()
# 2) getHMDcountries()
# 3) getJMDprefectures()
# 4) getCHMDprovinces()

############################################################################
# 1) HMDparse()
############################################################################
# note to self and others: if the HFD made metadata openly available, such as the
# below-used csv file, then everything would be so much easier!
############################################################################
#'
#' @title internal function for modifying freshly read HMD data in its standard form
#' 
#' @description called by \code{readHMD()} and \code{readHMDweb()}. We assume there are no factors in the given data.frame and that it has been read in from the raw text files using something like: \code{ read.table(file = filepath, header = TRUE, skip = 2, na.strings = ".", as.is = TRUE)}. This function is visible to users, but is not likely needed directly. 
#' 
#' @param DF a data.frame of HMD data, freshly read in.
#' @param filepath just to check if these are population counts from the name. 
#' 
#' @return DF same data.frame, modified so that columns are of a useful class. If there were open age categories, such as \code{"-"} or \code{"+"}, this information is stored in a new dummy column called \code{OpenInterval}.
#' 
#' @details This parse routine is based on the subjective opinions of the author...
#' 
#' @export
#'

HMDparse <- function(DF, filepath){
	if (any(grepl("age", tolower(colnames(DF))))){
		Pluses          <- grepl(pattern = "\\+", DF$Age )
		DF$Age          <- age2int(DF$Age)
		DF$OpenInterval <- Pluses
	}
	# Population.txt is a special case:
	if (grepl("pop", tolower(filepath))){
		# what years do we have?
		all.years   <- sort(unique(age2int(DF$Year)))
		# make indicators:
		Pluses      <- grepl(pattern = "\\+", DF$Year )
		Minuses     <- grepl(pattern = "\\-", DF$Year )
		# split out DF into two parts sum(Minuses) 
		Jan1i       <- DF$Year %in% as.character(all.years[-length(all.years)]) | Pluses
		Dec31i      <- DF$Year %in% as.character(all.years[-1]) | Minuses
		Jan1        <- DF[Jan1i, ]
		Dec31       <- DF[Dec31i, ]
		
		Jan1$Year   <- age2int(Jan1$Year)
		Dec31$Year  <- age2int(Dec31$Year)
		
		# now stick back together just the parts we need:
		cols1       <- match(c("female","male","total"),tolower(colnames(Jan1)))
		cols2       <- match(c("female","male","total"),tolower(colnames(Dec31)))
		colnames(Jan1)[cols1]   <- paste0(colnames(Jan1)[cols1],1)
		colnames(Dec31)[cols2]  <- paste0(colnames(Dec31)[cols2],2)
		DF          <- cbind(Jan1, Dec31[,cols2])
		# finally reorganize columns:
		orgi        <- grepl("male",tolower(colnames(DF))) | grepl("total",tolower(colnames(DF)))
		DF          <- cbind(DF[, !orgi], DF[, orgi])
	}
	
	if (any(grepl("year", tolower(colnames(DF))))){
		DF$Year          <- age2int(DF$Year)
	}
	if (any(grepl("cohort", tolower(colnames(DF))))){
		DF$Cohort          <- age2int(DF$Cohort)
	}
	invisible(DF)
}

############################################################################
# 2) getHMDcountries()
############################################################################

#' @title internal function for grabbing the HMD country short codes. 
#'
#' @description This function is called by \code{readHMDweb()} and is separated here for modularity. Assumes you have an internet connection.
#' 
#' @return a vector of HMD country short codes.
#' 
#' @importFrom rvest read_html html_element html_elements html_attr html_text2
#' @importFrom dplyr tibble mutate
#' @importFrom rlang .data
#' 
#' @export

getHMDcountries <- function(){
  
  xpath <- "/html/body/div[1]/div/div[3]"
  html <- read_html("https://www.mortality.org")
  
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
  
  # compose table and extract country code from links:
  tab_main <- tibble(Country= cntry_names, 
         link = links) |> 
    mutate(CNTRY =  sub(".*=", "", .data$link))
  
  # subpopulations are more of a pain to scrape; doable, but this is easier
  tab_extra <- tibble(Country = c("England and Wales (Total Population)",
                                  "England and Wales (Civilian Population)",
                                  "Scotland",
                                  "Northern Ireland",
                                  "New Zealand Maori",
                                  "New Zealand Non-Maori",
                                  "East Germany",
                                  "West Germany"),
                      link = c("/Country/Country?cntr=GBRTENW",
                               "/Country/Country?cntr=GBRCENW",
                               "/Country?cntr=GBR_SCO",
                               "/Country?cntr=GBR_NIR",
                               "/Country?cntr=NZL_MA",
                               "/Country?cntr=NZL_NM",
                               "/Country?cntr=DEUTE",
                               "/Country?cntr=DEUTW"),
                      CNTRY = c("GBRTENW",
                                "GBRCENW",
                                "GBR_SCO",
                                "GBR_NIR",
                                "NZL_MA",
                                "NZL_NM",
                                "DEUTE",
                                "DEUTW"))
  
  rbind(tab_main,
        tab_extra) 
}

############################################################################
# 3) getJMDprefectures()
############################################################################

#' @title get a named vector of JMD prefecture codes
#' 
#' @description This is a helper function for those familiar with prefecture names but not with prefecture codes (and vice versa). It is also useful for looped downloading of data.
#' 
#' @return a character vector of 2-digit prefecture codes. Names correspond to the proper names given in the English version of the HMD webpage.
#' 
#' @importFrom rvest html_table read_html html_element
#' @importFrom dplyr tibble arrange
#' 
#' @export
#' 
#' @examples \dontrun{ (prefectures <- getJMDprefectures()) }
#' 
getJMDprefectures <- function(){
  jmd_url <- "https://www.ipss.go.jp/p-toukei/JMD/index-en.html"
  
  tab <-
    read_html(jmd_url) |>
    html_element("table") |>
    html_table() |>
    as.matrix() 
  
  Prefs <- tab[-c(1:4),1:4]

	# form codes. rows read from left to right
  Codes <- c(matrix(
    sprintf("%.2d", 0:47), 
    byrow = TRUE, 
    ncol = 4))

	tibble(Prefecture = c(Prefs), Code = c(Codes)) |>
	  arrange(Code)
}

############################################################################
# 4) getCHMDprovinces()
############################################################################

#' @title get a named vector of CHMD province codes
#' 
#' @description This is a helper function to get a vector of 3-character province codes.
#' 
#' @return a character vector of 3 character province codes.
#' 
#' @export
#' 
#' @examples \dontrun{ (provs <- getCHMDprovinces()) }
#' 
getCHMDprovinces <- function(){
	# it's a small list, so why bother scraping?-- include "can" for posterity.
	sort(c("can","nfl","pei","nsc","nbr","que","ont","man","sas","alb","bco","nwt","yuk"))
}

#' @title internal function for grabbing the available data item names for a given country.
#' 
#' @description called by \code{readHMDweb()} to find file urls. This assumes that \code{CNTRY} is actually available in the HFD. 
#' 
#' @param CNTRY character. HMD country short code.

#' 
#' @return a tibble of all available data items for the selected country. There are several useful identifiers that can help determine the appropriate file, including the `measure`, `lexis`, `sex` and interval information, as detected from the item names.
#' 
#' @importFrom rvest read_html html_elements html_text2 html_attr
#' @importFrom dplyr case_when mutate tibble filter select
#' @export
#' 
getHMDitemavail <- function(CNTRY){
  
  CountryURL <- paste0("https://www.mortality.org/Country/Country?cntr=", CNTRY)
  
  html <- read_html(CountryURL)
  
  # untested!
  years <-
    html |>
    html_elements("table") |>
    html_elements("tr")|>
    html_elements("a") |>
    html_text2()
  
  # untested!
  links <-
    html |>
    html_elements("table") |>
    html_elements("tr")|>
    html_elements("a") |>
    html_attr("href")
  
  item_table <- 
    tibble(link = links, years2 = years) |>
    filter(! years2 %in% c("\r txt\r","\r pdf\r","html")) |>
    mutate(base = basename(link),
           item = gsub(base, pattern = ".txt", replacement = ""),
           measure = case_when(grepl(item, pattern = "E0") ~ "Life Expectancy",
                               grepl(item, pattern = "lt") ~ "Lifetables",
                               grepl(item, pattern = "Births") ~ "Births",
                               grepl(item, pattern = "Deaths") ~ "Deaths",
                               grepl(item, pattern = "Population") ~ "Population",
                               grepl(item, pattern = "Exposures") ~ "Exposures",
                               grepl(item, pattern = "Mx")~ "Rates"),
           lexis = case_when(grepl(item, pattern = "lexis") ~ "triangle",
                             grepl(item, pattern = "E0coh") ~ "cohort",
                             grepl(item, pattern = "c") ~ "age-cohort",
                             grepl(item, pattern = "E0per") ~ "period",
                             grepl(item, pattern = "per") ~ "age-period",
                             measure %in% c("Deaths","Population","Exposures","Rates") ~ "age-period",
                             measure == "Births" ~ "period"),
           age_interval = case_when(lexis == "cohort" ~ NA_integer_,
                                    lexis == "period"  ~ NA_integer_,
                                    years2 %in% c("1x1","1x5","1x10") ~ 1L,
                                    years2 %in% c("5x1","5x5","5x10") ~ 5L,
                                    years2 == "Lexis" ~ 1L,
                                    years2 == "1-year" ~ 1L,
                                    years2 == "5-year" ~ 5L),
           period_interval = case_when(grepl(lexis,pattern = "period") & 
                                         years2 %in% c("1x1","5x1") ~ 1L,
                                       grepl(lexis,pattern = "period") & 
                                         years2 %in% c("1x5","5x5") ~ 5L,
                                       grepl(lexis,pattern = "period") & 
                                         years2 %in% c("1x10","5x10") ~ 10L,
                                       measure == "Births" ~ 1L,
                                       years2 == "Lexis" ~ 1L,
                                       measure == "Population" ~0L,
                                       item == "E0per" ~ 1L,
                                       item == "E0per_1x5" ~ 5L,
                                       item == "E0per_1x10" ~ 10L,
                                       TRUE ~ NA_integer_),
           cohort_interval = case_when(grepl(lexis,pattern = "cohort") & 
                                         years2 %in% c("1x1","5x1") ~ 1L,
                                       grepl(lexis,pattern = "cohort") & 
                                         years2 %in% c("1x5","5x5") ~ 5L,
                                       grepl(lexis,pattern = "cohort") & 
                                         years2 %in% c("1x10","5x10") ~ 10L,
                                       item == "E0coh" ~ 1L,
                                       item == "E0coh_1x5" ~ 5L,
                                       item == "E0coh_1x10" ~ 10L,
                                       lexis == "triangle" ~ 1L,
                                       measure == "Births" ~ 1L),
           sex = case_when(substr(item,1,1) == "m" ~ "male",
                           substr(item,1,1) == "f" ~ "female",
                           substr(item,1,1) == "b" ~ "total",
                           measure %in% c("Births","Deaths","Exposures","Rates","Life Expectancy","Population") ~ "all")) |>
  select(item, measure, sex, lexis, age_interval, period_interval, cohort_interval, link)
    
    
	return(item_table)
}


## load globals to avoid "no visible binding" NOTEs in package checks:
utils::globalVariables(c("years2", "link", "base","item","measure",
                         "sex","lexis","age_interval","Age","ARDY","Cohort",
                         "period_interval","cohort_interval","Code"))