#'
#' @title read an HFD data file directly from the web as an R data.frame
#' 
#' @description Read HFD data directly from the web. This function is useful for short reproducible examples, or to make code guaranteed to always use the most up to date version of a particular HFD data file. For working with the entire HFD for a comparative study, it may be more efficient to download the full HFD and read in the elements using \code{readHFD()}. This function returns data formatted in the same way as \code{readHFD()}, that is, with Age columns (and others) converted to integer, and with open age group identifiers stored in a new logical column called \code{OpenInterval}. This reduces user burden somewhat, and facilitates direct use of functionality such as \code{log2mat()}. It is faster to specify \code{CNTRY} and \code{item} as arguments than to make the function figure out what's available. For repeated calls to this function, you can pass your username and password in as variables without having to include these in you R script by using \code{userInput()}-- see example.
#' 
#' @param CNTRY character string of the HFD short code. Only one!
#' @param item character string of the data product code, which is the base file name, but excluding the country code and file extension \code{.txt}. For instance, \code{"mabRR"} or \code{"tfrVHbo"}. If you're not sure, then leave it blank and a list will be shown. Only one item!
#' @param username your HFD usernames, which is usually the email address you registered with
#' @param password your HFD password. Don't make this a sensitive password, as things aren't encrypted.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param ... optional arguments passed to \code{read.table}. Probably not needed.
#' 
#' @return data.frame of the given HFD data file, modified in some friendly ways.
#'
#' @importFrom RCurl getURL
#' @importFrom RCurl getCurlHandle
#' @importFrom XML htmlTreeParse
#' @importFrom XML xpathSApply
#' @importFrom XML xmlChildren
#' @importFrom XML xmlAttrs
#'
#' 
#' @export
#' 
#' @examples
#' ### # this will ask you to enter your login details in the R console
#' ### DAT <- readHFDweb("JPN","tfrRR") 
#' ###
#' ### # ----------------------------------------
#' ### # this is a good way to reuse your login credentials without having to reveal them in your R script.
#' ### # if you want to do this in batch then I'm afraid you'll have to find a clever way to pass in your credentials
#' ### # without an interactive sessio, such as reading them in from a system file of your own.
#' ### myusername <- userInput()
#' ### mypassword <- userInput()
#' ### DAT <- readHMDweb("USA","mltper_1x1",mypassword,myusername)
#' ###
#' ### #-----------------------------------------
#' ### # this also works, but you'll need to make two selections, plus enter data in the console twice:
#' ### DAT <- readHFDweb()
#' 
readHFDweb <- function(CNTRY = NULL, item = NULL, username = NULL, password = NULL, fixup = TRUE){
    
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
    
    # concatenate the login string
    loginURL <- paste0("http://www.humanfertility.org/cgi-bin/logon.plx?page=main.php&f=na&tab=na&LogonEMail=",
            username, "&LogonPassword=", password, "&Logon=%20%20Login%20%20%20"
    )

    # a temporary file to hold cookies:
    TMP     <- file.path(getwd(),paste(sample(LETTERS,10,TRUE), collapse = ""))
    Nothing <- file.create(TMP)

    # this is the login handle, to pass to login call. At the moment, this is the only
    # way that RCurl will see that there is a cookiefile. In a prior version, cookiefile
    # was an argument passed straight to getURL, but now we pass the handle, where it
    # knows to look.
    handle <- getCurlHandle(.opts=list(verbose = FALSE,  cookiefile = TMP))
    
    # the actual login. cookiefile (TMP) now has metadata in it, if the login is correct 
    Nothing <- getURL(
                      loginURL,
                      curl = handle)
    Continue <- grepl("welcome", Nothing)
    if(!Continue){
        stop("login didn't work. \nMaybe your username or password are off? \nYour request is contracepted!")
    }

    # let user chose, or filter items as necessary: 
    if(is.null(item)){    
        cat("\nscraping data availability, rather slow, sorry\n")
        items <- getHFDitemavail(CNTRY)
        cat("\nCNTRY missing\n")
        if (interactive()){
            item <- select.list(choices = items, multiple = FALSE, title = "Select item")
        } else {
            stop("item should be one of these:\n",paste(item, collapse = ",\n"))
        }
    }
    
    # everything is in a folder, the name of which is the 8-digit version of the update date,
    # also really easy to find indirectly:
    LastUpdate      <- getHFDdate(CNTRY)
    
    # url used to ask for data file. try to ignore 'tabs'
    grabURL <- paste0(
            "http://www.humanfertility.org/cgi-bin/getfile.plx?f=",
            CNTRY,"\\",LastUpdate,"\\",CNTRY,item,".txt&c=",CNTRY)
    # use the same handle as before, which takes care of the cookiefile
    Text <- getURL(grabURL,
                   verbose = FALSE,  # also in handle
                   curl = handle)
    # parse raw data file to data.frame
    DF <- try(read.table(text = Text, 
                         header = TRUE, 
                         skip = 2, 
                         na.strings = ".", 
                         as.is = TRUE), 
              silent = TRUE)
    # clean up...
    unlink(TMP)
      
    if (class(DF) == "try-error"){
       message("retrieval failed for ", CNTRY,", item = ",item,"\nLogon was successful.. possible that item was not available?")
       stop("if this appears to be a bug, please report to\nhttps://github.com/UCBdemography/DemogBerkeley/issues")
   }
    if (fixup){
      DF      <- HFDparse(DF)
    }
    
    invisible(DF)
}

#DF <- readHFDweb("JPN",NULL,"tim.riffe@gmail.com","asus")

#library(DemogBerkeley)
