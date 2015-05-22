#'
#' @title readHMDweb a basic HMD data grabber.
#' 
#' @description This is a basic HMD data grabber, based on Carl Boe's original \code{HMD2R()}. It will only grab a single HMD statistical product from a single country. Some typical R pitfalls are removed: The Age column is coerced to integer, while an AgeInterval column is created. Also Population counts are placed into two columns, for Jan. 1st and Dec. 31 of the same year, so as to remove headaches from population universe adjustments, such as territorial changes. Fewer options means less to break. To do more sophisticated data extraction, iterate over country codes or statistical items. Reformatting can be done outside this function using, e.g., \code{long2mat()}. Argument \code{fixup} is outsourced to \code{HMDparse()}.
#'
#' @param CNTRY HMD population letter code. If not spelled right, or not specified, the function provides a selection list. Only 1.
#' @param item the statistical product you want, e.g., \code{"fltper_1x1"}. Only 1.
#' @param username usually the email address you registered with the HMD under. If left blank, you'll be prompted. Do that if you don't mind the typing and prefer not to save your username in your code.
#' @param password Your HMD password. If left blank, you'll be prompted. Do that if you don't mind the typing and prefer not to save your password in your code.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' 
#' @return data.frame of the HMD product, read as as \code{readHMD()} would read it.
#'
#' @importFrom RCurl getURL
#' @importFrom RCurl getCurlHandle
#' @importFrom RCurl getBinaryURL
#' @importFrom RCurl getCurlInfo
#' 
#' @export
#' 
readHMDweb <- function(CNTRY = NULL, item = NULL, username = NULL, password = NULL, fixup = TRUE){
  ## based on Carl Boe's RCurl tips
  # modified by Tim Riffe 
  
  # let user input name and password
  if (is.null(username)){
    if (interactive()){
      cat("\ntype in HMD username (usually your email, quotes not necessary):\n")
      username <- userInput(FALSE)
    } else {
      stop("if username and password not given as arguments, the R session must be interactive.")
    }
  }
  if (is.null(password)){
    if (interactive()){
      cat("\ntype in HMD password:\n")
      password <-  userInput(FALSE)
    } else {
      stop("if username and password not given as arguments, the R session must be interactive.")
    }
  }
  
  urlbase         <- "http://www.mortality.org/hmd"
#    tf <- tempfile()
#    on.exit(unlink(tf))
  this.url    <- "http://www.mortality.org/countries.csv"
  cntries     <- getURL(this.url)
  ctrylist    <- read.csv(text = cntries,header=TRUE,as.is=TRUE);
  ctrylookup  <- data.frame(Country=ctrylist$Country, CNTRY=ctrylist$Subpop.Code.1, stringsAsFactors = FALSE)
  
  # get CNTRY
  if(is.null(CNTRY)){    
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
  
  this.pw <- paste(username, password, sep = ":")
  
  ## reuse handle, reduce connection starts
  handle <- getCurlHandle(userpwd = this.pw)

  dirjunk <- getURL(file.path("www.mortality.org", "hmd", CNTRY,
				  paste0("STATS",.Platform$file.sep)), curl = handle)
  
  if (getCurlInfo(handle)$response.code == 401) {
	  stop("Authentication rejected: please check your username and password")
  }
  dirjunk <- getURL(file.path("www.mortality.org","hmd",CNTRY,"STATS/"), curl=handle)
  
  # check if authentication fails
  if (getCurlInfo(handle)$response.code == 401){
	  stop("Authentication rejected: please check your username and password")
  }
  # sometime redirects will break this, so we do it manually if necessary...
  if (getCurlInfo(handle)$response.code == 301){
	  dirjunk <- getURL(getCurlInfo(handle)$redirect.url, curl = handle)
  }
  
  parts <- gsub(pattern = "\\\"",
    replacement = "",
    unlist(lapply(strsplit(unlist(strsplit(dirjunk
              ,split="href=")),
          split = ">"),"[[",1)))
  allitems <- gsub(pattern = ".txt",replacement = "",parts[grepl(parts,pattern=".txt")])
  
  if (is.null(item)){
    if (interactive()){
      cat("\nThe following items are available for", CNTRY,"\n")
      item <- select.list(choices = allitems, 
        multiple = FALSE,
        title = "Select one")
    } else {
      stop("item must be one of the following for",CNTRY,paste(allitems,collapse=",\n"))
    }
  }
  if (!item %in% allitems){
    if (interactive()){
      if (any(grepl(allitems, pattern = item))){
        cat("\nMust specify item fully\n")    
        item <- select.list(choices = allitems[grepl(allitems, pattern = item)], 
          multiple = FALSE,
          title = "Select one")
      } else {
        cat("\nThe following items are available for", CNTRY,"\n")
        item <- select.list(choices = allitems, 
          multiple = FALSE,
          title = "Select one")
      }
    } else {
      stop("item must be one of the following for",CNTRY,paste(allitems,collapse=",\n"))
    }
  }
  
  # grab the data
  dataIN  <- getURL(file.path("www.mortality.org","hmd",CNTRY,"STATS",paste0(item,".txt")), curl=handle)
  
  # rest of this lifted from readHMD()
  DF      <- read.table(text = dataIN, header = TRUE, skip = 2, na.strings = ".", as.is = TRUE)
  if (fixup){
      DF        <- HMDparse(DF, filepath = item)
  }
    
  invisible(DF);
} # end readHMDweb()