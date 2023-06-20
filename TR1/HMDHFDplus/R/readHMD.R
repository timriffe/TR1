
# FILE CONTENTS:

# 1) readHMD()
# 2) readHMDweb()
# 3) readJMDweb()

############################################################################
# readHMD()
############################################################################

#'
#' @title \code{readHMD()} reads a standard HMD .txt table as a \code{data.frame}
#' 
#' @description This calls \code{read.table()} with all the necessary defaults to avoid annoying surprises. The Age column is also stripped of \code{"+"} and converted to integer, and a logical indicator column called \code{OpenInterval} is added to show where these were located. If the file contains population counts, values are split into two columns for Jan 1 and Dec 31 of the year. Output is invisibly returned, so you must assign it to take a look. This is to avoid lengthy console printouts. 
#' 
#' @param filepath path or connection to the HMD text file, including .txt suffix.
#' @param ... other arguments passed to \code{read.table}, not likely needed.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' 
#' @return data.frame of standard HMD output, except the Age column has been cleaned, and a new open age indicator column has been added. If the file is Population.txt or Population5.txt, there will be two columns each for males and females.
#' 
#' @details Population counts in the HMD typically refer to Jan 1st. One exception are years in which a territorial adjustment has been accounted for in estimates. For such years, `YYYY-` refers to Dec 31 of the year before the adjustment, and `YYYY+` refers to Jan 1 directly after the adjustment (adjustments are always made Jan 1st). In the data, it will just look like two different estimates for the same year, but in fact it is a definition change or similar. In order to remove headaches from potential territorial adjustments in the data, we simply create two columns, one for January 1st (e.g.,\code{"Female1"}) and another for Dec 31st (e.g.,\code{"Female2"}) . One can recover the adjustment coefficient for each year by taking the ratio $$Vx = P1(t+1) / P2(t)$$. In most years this will be 1, but in adjustment years there is a difference. This must always be accounted for when calculating rates and exposures. Argument \code{fixup} is outsourced to \code{HMDparse()}.
#' 
#' @importFrom utils read.table
#' 
#' @export
#' 
#' @note function written by Tim Riffe.
#' 
readHMD <- function(filepath, fixup = TRUE, ...){
  DF              <- read.table(file = filepath, header = TRUE, skip = 2, na.strings = ".", as.is = TRUE, ...)
  if (fixup){
    DF        <- HMDparse(DF, filepath)
  }
  invisible(DF)
}

############################################################################
# readHMDweb()
############################################################################

#'
#' @title readHMDweb a basic HMD data grabber.
#' 
#' @description This is a basic HMD data grabber, based on Carl Boe's original \code{HMD2R()}. It will only grab a single HMD statistical product from a single country. Some typical R pitfalls are removed: The Age column is coerced to integer, while an AgeInterval column is created. Also Population counts are placed into two columns, for Jan. 1st and Dec. 31 of the same year, so as to remove headaches from population universe adjustments, such as territorial changes. Fewer options means less to break. To do more sophisticated data extraction, iterate over country codes or statistical items. Reformatting can be done outside this function using, e.g., \code{long2mat()}. Argument \code{fixup} is outsourced to \code{HMDparse()}.
#'
#' @param CNTRY character. HMD population letter code. If not spelled right, or not specified, the function provides a selection list. Only 1.
#' @param item character. The statistical product you want, e.g., \code{"fltper_1x1"}. Only 1.
#' @param username character. Your HMD user id, usually the email address you registered with the HMD under. If left blank, you'll be prompted. Do that if you don't mind the typing and prefer not to save your username in your code.
#' @param password character. Your HMD password. If left blank, you'll be prompted. Do that if you don't mind the typing and prefer not to save your password in your code.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' 
#' @return data.frame of the HMD product, read as as \code{readHMD()} would read it.
#'
#' @details This function points to the new HMD website (from June 2022) rather than the mirror of the old site that it temporarily pointed to; If your credentials fail then a likely reason is that you need to re-register at the new HMD website \href{https://www.mortality.org/Account/UserAgreement}{https://www.mortality.org/Account/UserAgreement}. As soon as you register, your new credentials should work.
#' 
#' @importFrom rvest html_form_set session html_form session_submit session_jump_to
#' @importFrom httr content status_code
#' @importFrom dplyr pull
#' @export
#' 
readHMDweb <- function(CNTRY, item, username, password, fixup = TRUE){
	## based on Carl Boe's RCurl tips
	# modified by Tim Riffe 
	
	# let user input name and password
	if (missing(username)){
		if (interactive()){
			cat("\ntype in HMD username (usually your email, quotes not necessary):\n")
			username <- userInput(FALSE)
		} else {
			stop("if username and password not given as arguments, the R session must be interactive.")
		}
	}
	if (missing(password)){
		if (interactive()){
			cat("\ntype in HMD password:\n")
			password <-  userInput(FALSE)
		} else {
			stop("if username and password not given as arguments, the R session must be interactive.")
		}
	}
	
  # Get logged in, starting here
  loginURL <- "https://www.mortality.org/Account/Login"
  # concatenate the login string
  
  html <- session(loginURL)
  
  # olny one form on login page:
  pgform    <- html_form(html)[[1]]  
  
  # # hack because rvest doesn't record where we were??
  pgform$action <- loginURL
  pgform$url    <- loginURL
  the_token     <- pgform$fields["__RequestVerificationToken"]
  filled_form   <- suppressWarnings(html_form_set(pgform,
                                 Email = username,
                                 Password = password,
                                 '__RequestVerificationToken' =
                                   unlist(the_token)["__RequestVerificationToken.value" ]))
  # test once credentials validated
  html2 <- session_submit(html, filled_form)

  Continue <- status_code(html2) == 200
  if (!Continue) {
    stop(paste0("login didn't work. \nMaybe your username or password are off?
If your username and password are from before July 2022
then you'll need to re-register for HMD, starting here:

https://www.mortality.org/Account/UserAgreement\n
We no longer refer to the mirror website https://www.former.mortality.org
Those shenanigans were just a temporary patch to buy time to recode for the new site!\n"))
  }
  
	ctrylist    <- getHMDcountries()
			
	ctrylookup  <- ctrylist |>
	  select(-"link")
	
	# get CNTRY
	if (missing(CNTRY)){    
		cat("\nCNTRY missing\n")
		if (interactive()){
			CNTRY <- select.list(choices = ctrylookup$CNTRY, multiple = FALSE, title = "Select Country Code")
		} else {
			stop("CNTRY should be one of these:\n",paste(ctrylookup$CNTRY, collapse = ",\n"))
		}
	}
	if (!(CNTRY %in% ctrylookup$CNTRY)){
		cat("\nCNTRY not found\n")
		if (interactive()){
			CNTRY <- select.list(choices = ctrylookup$CNTRY, multiple = FALSE, title = "Select Country Code")
		} else {
			stop("CNTRY should be one of these:\n",paste(ctrylookup$CNTRY, collapse = ",\n"))
		}
	}
	stopifnot(length(CNTRY) == 1)
	
	# repeat for item
	item_table <- getHMDitemavail(CNTRY) 
	
	itemlookup <-
	  item_table |>
	  pull("item")
	
	if (missing(item)){    
		cat("\nitem missing\n")
		if (interactive()){
			item <- select.list(choices = itemlookup, multiple = FALSE, title = "Select item Code")
		} else {
		  cat("\nTry running getHMDitemavail() if you're not sure which item you want.\n")
			stop(paste0("item should be one of these:\n",paste(itemlookup, collapse = ", "),"\n"))
		}
	}
	if (!(item %in% itemlookup)){
		cat("\nitem not found\n")
		if (interactive()){
			item <- select.list(choices = itemlookup, multiple = FALSE, title = "Select item Code")
		} else {
		  cat("\nTry running getHMDitemavail() if you're not sure which item you want.\n")
			stop("item should be one of these:\n",paste(itemlookup, collapse = ",\n"))
		}
	}
	stopifnot(length(item) == 1)
  .item = item
	stub_url <- item_table |>
	  filter(item == .item) |>
	  pull("link")
	
	grab_url <- paste0("https://www.mortality.org", stub_url)
	
	# TR: This session jump doesn't seem to be working
	# as expected; grab url brings me to text file
	# if I paste it in a tab (logged in), but when I
	# do a session_jump_to() it then I seem to stay at
	# the login page, so I'm not seeing the 
	data_grab <- session_jump_to(html2, 
	                             url = grab_url)


	# TR: this is all test code, not expected to run yet
	the_table <- 
	  content(data_grab$response, 
	          as = "text", 
	          encoding = "UTF-8") 
	con <- 
	  textConnection(the_table)

	DF <-
	  read.table(con,
	             header = TRUE, 
	             skip = 2, 
	             na.strings = ".", 
	             as.is = TRUE) |>
	  HMDparse(filepath = grab_url)
	close(con)

  invisible(DF)
} # end readHMDweb()
############################################################################
# readJMDweb()
############################################################################

#'
#' @title read data from the Japan Mortality Database into R
#' 
#' @description JMD data are formatted exactly as HMD data. This function simply parses the necessary url together given a prefecture code and data item (same nomenclature as HMD). Data is parsed using \code{HMDparse()}, which converts columns into useful and intuitive classes, for ready-use. See \code{?HMDparse} for more information on type conversions. No authentication is required for this database. Only a single item/prefecture is downloaded. Loop for more complex calls (See examples). The prefID is not appended as a column, so be mindful of this if appending several items together into a single \code{data.frame}. Note that at the time of this writing, the finest Lexis resolution for prefectural lifetables is 5x5 (5-year, 5-year age groups). Raw data are, however, provided in 1x1 format, and deaths are also available in triangles.
#' 
#' @param prefID a single prefID 2-digit character string, ranging from \code{"00"} to \code{"47"}.
#' @param item the statistical product you want, e.g., \code{"fltper_5x5"}. Only 1.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param ... extra arguments ultimately passed to \code{read.table()}. Not likely needed.
#' 
#' @return \code{data.frame} of the data item is invisibly returned
#' 
#' @details No details of note. This database in independently maintained, so file types/locations are subject to change. If this happens, please notify the package maintainer.
#' 
#' @importFrom httr HEAD
#' 
#' @export 
#' 
#' @examples 
#' \dontrun{
#' library(HMDHFDplus)
#' # grab prefecture codes (including All Japan)
#' prefectures <- getJMDprefectures()
#' # grab all mltper_5x5
#' # and stick into long data.frame: 
#' mltper <- do.call(rbind, lapply(prefectures, function(prefID){
#'                    Dat        <- readJMDweb(prefID = prefID, item = "mltper_5x5", fixup = TRUE)
#'                    Dat$PrefID <- prefID
#'                    Dat
#' }))
#' }
#' 
readJMDweb <- function(prefID = "01", item = "Deaths_5x5", fixup = TRUE, ...){
	JMDurl      <- paste("https://www.ipss.go.jp/p-toukei/JMD",
			         prefID, "STATS", paste0(item, ".txt"), sep = "/")

	if (httr::HEAD(JMDurl)$all_headers[[1]]$status == 200){
		con         <- url(JMDurl)
		Dat         <- readHMD(con, fixup = fixup, ...)
		# close(con)
		return(invisible(Dat))
	} else {
		cat("Either the prefecture code or data item are not available\nCheck names.\nNULL returned\n")
		NULL
	}
}
# item <- "mltper_5x5";Dat <- readHMD(con, fixup = TRUE)
############################################################################
# readCHMDweb()
############################################################################

#'
#' @title read data from the Canadian Human Mortality Database into R
#' 
#' @description CHMD data are formatted exactly as HMD data. This function simply parses the necessary url together given a province code and data item (same nomenclature as HMD). Data is parsed using \code{HMDparse()}, which converts columns into useful and intuitive classes, for ready-use. See \code{?HMDparse} for more information on type conversions. No authentication is required for this database. Only a single item/prefecture is downloaded. Loop for more complex calls (See examples). The provID is not appended as a column, so be mindful of this if appending several items together into a single \code{data.frame}. Note that at the time of this writing, the finest Lexis resolution for prefectural lifetables is 5x5 (5-year, 5-year age groups). Raw data are, however, provided in 1x1 format, and deaths are also available in triangles. Note that cohort data are not produced for Canada at this time (but you could produce such data by starting with the \code{Deaths\_Lexis} file...).
#' 
#' @param provID a single provID 3 character string, as returned by \code{getCHMDprovinces()}.
#' @param item the statistical product you want, e.g., \code{"fltper_5x5"}. Only 1.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param ... extra arguments ultimately passed to \code{read.table()}. Not likely needed.
#' 
#' @return \code{data.frame} of the data item is invisibly returned
#' 
#' @details This database is curated independently from the HMD/HFD family, and so file types and locations may be subject to change. If this happens, please notify the package maintainer.
#' 
#' @export 
#' 
#' @importFrom httr HEAD
#' 
#' @examples 
#' \dontrun{
#' library(HMDHFDplus)
#' # grab province codes (including All Canada)
#' provs <- getCHMDprovinces()
#' # grab all mltper_5x5  
#' # and stick into long data.frame: 
#' mltper <- do.call(rbind, lapply(provs, function(provID){
#'                    Dat        <- readCHMDweb(provID = provID, item = "mltper_5x5", fixup = TRUE)
#'                    Dat$provID <- provID
#'                    Dat
#' }))
#' }
#' 

readCHMDweb <- function(provID = "can", item = "Deaths_1x1", fixup = TRUE, ...){
	CHMDurl         <- paste("https://www.prdh.umontreal.ca/BDLC/data/",
			             provID, paste0(item, ".txt"), sep = "/")

	if (httr::HEAD(CHMDurl)$all_headers[[1]]$status == 200){
		con         <- url(CHMDurl)
		Dat         <- readHMD(con, fixup = fixup, ...)
		# close(con)
		return(invisible(Dat))
	} else {
		cat("Either the prefecture code or data item are not available\nCheck names.\nNULL returned\n")
		NULL
	}
	
	
	invisible(Dat)
}

