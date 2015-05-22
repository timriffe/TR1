#'
#' @title \code{readHFC()} reads a standard HFC .txt table as a \code{data.frame}
#' 
#' @description This calls \code{read.csv()} with all the necessary defaults to avoid annoying surprises. \code{Age} is given as an integer, along with an \code{AgeInterval}. The default behavior is to change the \code{AgeInterval} column  to character and produce a logical indicator column, \code{OpenInterval}. \code{Year} is also given as the starting year of a \code{YearInterval}, rather than the original \code{Year1} and \code{Year2} columns. The column \code{Country} is renamed \code{CNTRY}. All other original columns are maintained. Output is invisibly returned, so you must assign it to take a look. 
#' 
#' @param filepath path or connection to the HFC text file, including .txt suffix.
#' @param fixup logical. Should columns be made more user-friendly, e.g., forcing Age to be integer?
#' @param ... other arguments passed to \code{read.csv}, not likely needed.
#' 
#' @return data.frame of standard HFC output, except the Age column has been cleaned, and a new open age indicator column has been added. 
#' 
#' @export
#' 

readHFC <- function(filepath, fixup = TRUE, ...){
    DF      <- read.csv(file = filepath, stringsAsFactors = FALSE, na.strings = ".", strip.white = TRUE, ...)
    if (fixup){
        DF      <- HFCparse(DF)
    }
    invisible(DF)
}