
# FILE CONTENTS:

# 1) readHFD()
# 2) readHFDweb()
# 3) readHFCweb()

############################################################################
# readHFD()
############################################################################

#'
#' @title \code{readHFD()} reads a standard HFD .txt table as a \code{data.frame}
#' 
#' @description This calls \code{read.table()} with all the necessary defaults to avoid annoying surprises. The Age column is also stripped of \code{"-"} and \code{"+"} and converted to integer, and a logical indicator column called \code{OpenInterval} is added to show where these were located. Output is invisibly returned, so you must assign it to take a look. This is to avoid lengthy console printouts.
#' 
#' @param filepath path or connection to the HFD text file, including .txt suffix.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param ... other arguments passed to \code{read.table}, not likely needed.
#' 
#' @return data.frame of standard HFD output, except the Age column has been cleaned, and a new open age indicator column has been added. 
#' 
#' @details No details of note.
#' 
#' @importFrom utils read.table
#' 
#' @export
#' 
#' @note original function submitted by Josh Goldstein, modified by Tim Riffe.
#' 

readHFD <- function(filepath, fixup = TRUE, ...){
    DF      <- suppressWarnings(read.table(file = filepath, header = TRUE, skip = 2, na.strings = ".", as.is = TRUE, ...))
    if (fixup){
      DF      <- HFDparse(DF)
    }
    invisible(DF)
}

############################################################################
# readHFDweb()
############################################################################

#'
#' @title read an HFD data file directly from the web as an R data.frame
#' 
#' @description Read HFD data directly from the web. This function is useful for short reproducible examples, or to make code guaranteed to always use the most up to date version of a particular HFD data file. For working with the entire HFD for a comparative study, it may be more efficient to download the full HFD zip files and read in the elements using \code{readHFD()}. This function returns data formatted in the same way as \code{readHFD()}, that is, with Age columns (and others) converted to integer, and with open age group identifiers stored in a new logical column called \code{OpenInterval}. It is faster to specify \code{CNTRY} and \code{item} as arguments than to make the function figure out what's available. For repeated calls to this function, you can pass your username and password in as variables without having to include these in you R script by using \code{userInput()}-- see example. The user also has the option of querying particular updates from the HFD revision history. If you wish to specify a particular update, you must know the date that a particular country was updated, in the format \code{"YYYYMMDD"}. These dates differ between countries, so keep a good record if you wish your work to be reproducible to that extent (as well as lightweight)!
#' 
#' @param CNTRY character string of the HFD short code. Only one!
#' @param item character string of the data product code, which is the base file name, but excluding the country code and file extension \code{.txt}. For instance, \code{"mabRR"} or \code{"tfrVHbo"}. If you're not sure, then leave it blank and a list will be shown. Only one item!
#' @param username your HFD usernames, which is usually the email address you registered with
#' @param password your HFD password. Don't make this a sensitive password, as things aren't encrypted.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param Update character string of 8-digit date code of the format \code{"YYYYMMDD"}. Defaults to most recent update.
#' 
#' @return data.frame of the given HFD data file, modified in some friendly ways.
#'
#' @details You need to register for HFD to use this function: \url{https://www.humanfertility.org}. It is advised to pass in your credentials as named vectors rather than directly as character strings, so that they are not saved directly in your code. See examples. One option is to just save them in your Rprofile file.
#' 
#' @importFrom httr content status_code
#' @importFrom rvest session html_form html_form_set session_submit session_jump_to  
#' @importFrom utils select.list
#' @importFrom dplyr filter pull
#' @importFrom lubridate ymd is.Date

#' 
#' @export
#' 
#' @examples
#' ### # this will ask you to enter your login details in the R console
#' ### DAT <- readHFDweb("JPN","tfrRR") 
#' ###
#' ### # ----------------------------------------
#' ### # this is a good way to reuse your login credentials without 
#' ### # having to reveal them in your R script.
#' ### # if you want to do this in batch then I'm 
#' ### # afraid you'll have to find a clever way to 
#' ### # pass in your credentials without an interactive 
#' ### # session, such as reading them in from a system file of your own.
#' ### myusername <- userInput()
#' ### mypassword <- userInput()
#' ### DAT <- readHMDweb("USA","mltper_1x1",mypassword,myusername)
#' ###
#' ### #-----------------------------------------
#' ### # this also works, but you'll need to make two selections, 
#' ### # plus enter data in the console twice:
#' ### DAT <- readHFDweb()
#' 
readHFDweb <- function(
    CNTRY = NULL, 
    item = NULL, 
    username = NULL, 
    password = NULL, 
    fixup = TRUE, 
    Update = NULL){
	
	# let user input name and password
	if (is.null(username)){
		if (interactive()){
			cat("\ntype in HFD username (usually your email, quotes not necessary):\n")
			username <- userInput(FALSE)
		} else {
			stop("if username and password not given as arguments, the R session must be interactive.")
		}
	}
	if (is.null(password)){
		if (interactive()){
			cat("\ntype in HFD password:\n")
			password <- userInput(FALSE)
		} else {
			stop("if username and password not given as arguments, the R session must be interactive.")
		}
	}
	
	if(is.null(CNTRY)){    
		# I outsourced this function, since I 1) hate looking at it and 2)think it might be useful outside this function to
		# an enterprising user. 
		CNTRIES <- getHFDcountries()
		cat("\nCNTRY missing\n")
		if (interactive()){
			CNTRY <- select.list(choices = CNTRIES, multiple = FALSE, title = "Select Country Code")
		} else {
			stop("CNTRY should be one of these:\n",paste(CNTRIES, collapse = ",\n"))
		}
	}

  
  # testing starts here
  loginURL <- paste0("https://www.humanfertility.org/Account/Login")
	# concatenate the login string

	html <- session(loginURL)
	
	# olny one form on login page:
	pgform    <- html_form(html)[[1]]  
	
	# # hack because rvest doesn't record where we were??
	pgform$action <- loginURL
	pgform$url    <- loginURL
	
	filled_form   <- html_form_set(pgform, 
	                               Email = username, 
	                               Password = password)

	# TR: yay this now works!
	html2 <- session_submit(html, filled_form)

	Continue <- status_code(html2) == 200
	if (!Continue) {
	  stop(paste0("login didn't work. \nMaybe your username or password are off?
If your username and password are from before 4 November 2022
then you'll need to re-register for HFD, starting here:\n
https://www.humanfertility.org/Account/UserAgreement"))
  }
	# let user choose, or filter items as necessary: 

	itemavail <- getHFDitemavail(CNTRY)
	items     <- itemavail$item
	if(is.null(item) || !(item %in% items) | length(item) > 1){
		if (interactive()){
		  
		  cat(paste0("select an item nr\nIf you're not sure which one you want, select 0 and try running\ngetHFDitemavail('",eval(CNTRY),"') |> View()"))
			.item <- select.list(choices = items, multiple = FALSE, title = "Select item")
		} else {
			stop("item should be one of these:\n",paste(item, collapse = ",\n"))
		}
	} else {
	  .item = item
	}
	
	# data_url <- itemavail |> filter(item == .item) |> pull(link)
	
	if (is.null(Update)){
	  yyyymmdd <- getHFDdate(CNTRY)
	} else {
	  if (is.Date(ymd(yyyymmdd))){
	    cat("Attempting to retrieve data from your requested Update date")
	    yyyymmdd <- Update
	  } else {
	    stop("Update date appears misspecified. It needs to be a string in 'yyyymmdd' format\n The most recent valid update for ",CNTRY, " was '",eval(yyyymmdd),"'")
	  }
	}
	# this could be pulled from getHFDitemavail() output as well,
	# but we self-construct in order to allow custom dates
	grab_url  <- paste0("https://www.humanfertility.org/File/GetDocument/Files/",CNTRY,
	                    "/",yyyymmdd,"/",CNTRY,.item,".txt")
	data_grab <- session_jump_to(html2, url = grab_url)
	tmp <- tempfile()
	
	data_grab$response |> 
	  content(encoding = "UTF-8") |> 
	  cat(file=tmp, encoding = "UTF-8")
	
	DF <- readHFD(tmp, fixup = fixup)
	
	unlink(tmp)
	closeAllConnections()


	return(invisible(DF))
	
}

############################################################################
# readHFCweb()
############################################################################

#' @title readHFCweb get HFC data straight from the web into R!
#' 
#' @description This concatenates the necessary url and calls \code{read.csv()} with all the necessary defaults to avoid annoying surprises. \code{Age} is given as an integer, along with an \code{AgeInterval}. The default behavior is to change the \code{AgeInterval} column to character and produce a logical indicator column, \code{OpenInterval}. \code{Year} is also given as the starting year of a \code{YearInterval}, rather than the original \code{Year1} and \code{Year2} columns. The column \code{Country} is renamed \code{CNTRY}. All other original columns are maintained. Output is invisibly returned, so you must assign it to take a look. 
#' 
#' @param CNTRY character string of the HCD short code. Only one! Run \code{getHFCcountries(FALSE)} to see what the options are.
#' @param item character string of the data product code, which is the base file name, but excluding the country code and file extension \code{.txt}. For instance, \code{"ASFRstand_TOT"}, \code{"ASFRstand_BO"}, \code{"TFRMAB_TOT"}, \code{"TFRMAB_BO"}. Only one item!
#' @param fixup logical. Default \code{TRUE}. Should column classes be coerced to those more similar to HFD, HMD?
#' @param ... optional arguments passed to \code{read.csv()}. Not required.
#' 
#' @export
#' 
#' @importFrom httr HEAD
#' @importFrom utils read.csv
#' 
#' @examples 
#' \dontrun{
#' DF <- readHFCweb("CZE","TFRMAB_TOT")
#' head(DF)
#' DF <- readHFCweb("CZE","ASFRstand_BO")
#' head(DF)
#' 
#' # get ASFRstand_BO for all countries where available:
#' Countries <- getHFCcountries()
#' # takes a minute to run
#' 
#' urls <- paste0("http://www.fertilitydata.org/data/", 
#'                Countries,"/", Countries, "_",  "ASFRstand_BO", ".txt")
#' 
#' HaveBO <- RCurl::url.exists(urls)
#'  # we grab data for these countries:
#'  (Countries <- Countries[HaveBO])
#' 
#' # Also takes 1-15 min depending on internet connection and machine
#' # read in one at a time and stick together into long data.frame
#' allBO <- do.call(rbind,
#'         # this is the iteration of reading in
#'         lapply(Countries, function(CNTRY){
#'             readHFCweb(CNTRY, item = "ASFRstand_BO")
#'              })) # closes off the meta-rbind thingy
#' dim(allBO) # [1] 133237     31
#' unique(allBO$CNTRY)
#' 
#' }
#' 
readHFCweb <- function(CNTRY, item, fixup = TRUE, ...){
	# concatenate url:
	fileurl <- paste0("https://www.fertilitydata.org/data/", CNTRY, "/", CNTRY, "_", item, ".txt")
	
	# read in with needed arguments:
	if (httr::HEAD(fileurl)$all_headers[[1]]$status == 200){
		con         <- url(fileurl)
		DF          <- read.csv(url(fileurl), stringsAsFactors = FALSE, na.strings = ".", strip.white = TRUE, ...)
		close(con)
		# optionally use standard columns:
		if (fixup){
			DF      <- HFCparse(DF)
		}
		return(invisible(DF))
	} else {
		cat("Either the CNTRY code or data item are not available\nCheck names.\nNULL returned\n")
		NULL
	}
	
}


# end