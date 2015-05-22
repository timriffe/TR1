#'
#' @title read data from the Japan Mortality Database into R
#' 
#' @description JMD data are formatted exactly as HMD data. This function simply parses the necessary url together given a prefecture code and data item (same nomenclature as HMD). Data is parsed using \code{HMDparse()}, which converts columns into useful and intuitive classes, for ready-use. See \code{?HMDparse} for more information on type conversions. No authentification is required for this database. Only a single item/prefecture is downloaded. Loop for more complex calls (See examples). The prefID is not appended as a column, so be mindful of this if appending several items together into a single \code{data.frame}. Note that at the time of this writing, the finest Lexis resolution for prefectural lifetables is 5x5 (5-year, 5-year age groups). Raw data are, however, provided in 1x1 format, and deaths are also available in triangles.
#' 
#' @param prefID a single prefID 2-digit character string, ranging from \code{"00"} to \code{"47"}.
#' @param item the statistical product you want, e.g., \code{"fltper_5x5"}. Only 1.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param ... extra arguments ultimately passed to \code{read.table()}. Not likely needed.
#' 
#' @return \code{data.frame} of the data item is invisibly returned
#' 
#' @export 
#' 
#' @examples 
#' \dontrun{
#' library(DemogBerkeley)
#' # grab prefecture codes (including All Japan)
#' prefectures <- getJMDprefectures()
#' # grab all mltper_5x5 (Excep aggregate Japan, which has a formatting error at this writing) 
#' # and stick into long data.frame: 
#' mltper <- do.call(rbind, lapply(prefectures[-1], function(prefID){
#'                    Dat        <- readJMDweb(prefID = prefID, item = "mltper_5x5", fixup = TRUE)
#'                    Dat$PrefID <- prefID
#'                    Dat
#' }))
#' }
#' 
readJMDweb <- function(prefID = "01", item = "Deaths_1x1", fixup = TRUE, ...){
    JMDurl      <- paste("http://www.ipss.go.jp/p-toukei/JMD",
                     prefID, "STATS", paste0(item, ".txt"), sep = "/")
    con         <- url(JMDurl)
    Dat         <- readHMD(con, fixup = fixup, ...)

    invisible(Dat)
}

#' @title get a named vector of JMD prefecture codes
#' 
#' @description This is a helper function for those familiar with prefecture names but not with prefecture codes (and vice versa). It is also useful for looped downloading of data.
#' 
#' @return a character vector of 2-digit prefecture codes. Names correspond to the proper names given in the English version of the HMD webpage.
#' 
#' @importFrom XML readHTMLTable
#' 
#' @export
#' 
#' @examples \dontrun{ (prefectures <- getJMDprefectures()) }
#' 
getJMDprefectures <- function(){
   Prefs <- as.matrix(readHTMLTable("http://www.ipss.go.jp/p-toukei/JMD/index-en.html",
            which = 1, stringsAsFactors = FALSE, skip.rows = c(1:4)))
   # get codes. rows read from left to right
   Prefectures <- sprintf("%.2d", row(Prefs) * 4 + col(Prefs) - 5)
   names(Prefectures) <- c(Prefs)
   Prefectures[order(Prefectures)]
}

