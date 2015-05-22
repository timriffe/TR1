
#'
#' @title HFCparse internal function for modifying freshly read HCD data in its standard form
#' 
#' @description called by \code{readHFC()} and \code{readHFCweb()}. We assume there are no factors in the given data.frame and that it has been read in from the raw text files using something like: \code{ read.csv(file = filepath, stringsAsFactors = FALSE, na.strings = ".", strip.white = TRUE)}. This function is visible to users, but is not likely needed directly.
#' 
#' @param DF a data.frame of HFC data, freshly read in.
#' 
#' @return DF same data.frame, modified so that columns are of a useful class. If there were open age categories, such as \code{"-"} or \code{"+"}, this information is stored in a new dummy column called \code{OpenInterval}. Values of 99 or -99 in the \code{AgeInterval} column are replaced with \code{"+"} and \code{"-"}, respectively. \code{Year} taken from \code{Year1}, and \code{YearInterval} is given, rather than \code{Year2}. Users wishing for a central time point should bear this is mind. The column \code{Country} is renamed \code{CNTRY}. Otherwise, columns in this database are kept in the \code{data.frame}, in case they may be useful. 
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
          



