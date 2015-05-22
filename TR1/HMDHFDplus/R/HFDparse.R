#'
#' @title internal function for modifying freshly read HFD data in its standard form
#' 
#' @description called by \code{readHFD()} and \code{readHFDweb()}. We assume there are no factors in the given data.frame and that it has been read in from the raw text files using something like: \code{ read.table(file = filepath, header = TRUE, skip = 2, na.strings = ".", as.is = TRUE)}. This function is visible to users, but is not likely needed directly.
#' 
#' @param DF a data.frame of HFD data, freshly read in.
#' 
#' @return DF same data.frame, modified so that columns are of a useful class. If there were open age categories, such as \code{"-"} or \code{"+"}, this information is stored in a new dummy column called \code{OpenInterval}.
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