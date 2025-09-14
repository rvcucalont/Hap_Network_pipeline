##Function to extract a specific identifiers from labels (e.g. fasta or tree files)
# Load necessary libraries

# Create a function that searches for a word on a string 
# if the word is on the string then returns the same word that was searching otherwise returns NA
# The function should also return NA if the query is NA
# The word should be searched considering separators like "_" or "-" or " " or "."
# Only one separator should be considered at a time, the one with highest frequency in the string
Match.ID <- function(query="Sample1",string="Sample1.A") {
  if (is.na(query)) {
    return(NA_character_)
  } else {
    separators <- c("_", "-", " ", "."," | ")
    # Count the occurrences of each separator in the string
    # If the specific separator does not exit in the string then it should return 0
    separator_counts <- sapply(X = separators,FUN = function(sep) sum(grepl(pattern = sep,string)))
    #Select separator with highest frequency
    best_separator <- separators[which.max(separator_counts)]
    pattern1 <- paste0(query,best_separator)
    pattern2 <- paste0(best_separator,query)
    pattern3 <- paste0(best_separator,query,best_separator)
    pattern4 <- paste0(query)
    # Print the patterns being used for debugging
    if (grepl(pattern1, string) || grepl(pattern2, string) || grepl(pattern3, string) || grepl(pattern4, string)) {
      queryfound <- query
      NoqueryFound <- NA_character_
    } else {
      #NoqueryFound <- query
      queryfound <- NA_character_
      NoqueryFound <- string
    }
    return(list(queryfound,NoqueryFound))
  }
}

# Match the IDs from the tree to the metadata file
# Create a vector to store the matched IDs

Get.Matched.ID <- function(queryID,metadata,ByColname,keepCol=NULL) {
  # Check if ByColname exists in metadata
  if (!(ByColname %in% colnames(metadata))) {
    stop(paste("Column", ByColname, "not found in metadata"))
  }
  # Check if queryID is a character vector
  if (!is.character(queryID)) {
    stop("queryID must be a character vector")
  }
  # Check if metadata is a data frame
  if (!is.data.frame(metadata)) {
    stop("metadata must be a data frame")
  }
  # Initialize an empty vector to store matched IDs
  Matched.ID <- vector()
  unMatched.ID <- vector()
  # Loop through the tree tip labels and the metadata file to find matches
  # If a match is found, store the matched ID in the Matched.ID vector
  # show progress bar "---" for the for loop
  pb <- txtProgressBar(min = 0, max = length(queryID), style = 3)
  for(i in 1:length(queryID)){
    Matched.ID[i] <- NA
    unMatched.ID[i] <- NA
    for(j in 1:dim(metadata)[1]){
      if (!is.na(Match.ID(metadata[[ByColname]][j],queryID[i]))[[1]]){
        Matched.ID[i] <- Match.ID(metadata[[ByColname]][j], queryID[i])[[1]]
        #print(paste("matched:",Matched.ID[i],"with",queryID[i]))
        break
      } else {
        unMatched.ID[i] <- Match.ID(metadata[[ByColname]][j], queryID[i])[[2]]
        #print(paste("unmatched:",metadata[[ByColname]][j], "with", unMatched.ID[i]))
        # conditional if the total number of unmatched IDs is equal to the number of rows 
        #in the metadata then keep the unmatched ID
        if (length(unMatched.ID) == dim(metadata)[1]) {
          unMatched.ID[i] <- queryID[i]
        } else {
          unMatched.ID[i] <- NA
        }##
      }
    }
    setTxtProgressBar(pb, i)
  }
  close(pb)
  Matched.ID <- as.character(na.omit(Matched.ID))
  #print(Matched.ID)
  unMatched.ID <- as.character(na.omit(unMatched.ID))
  #print(unMatched.ID)
  # If keepCol is specified, return a data frame with matched IDs and the specified columns
  if (!is.null(keepCol)) {
    if (!all(keepCol %in% colnames(metadata))) {
      stop("Some columns in keepCol not found in metadata.\n\n")
    }
    Matched.Data <- metadata[match(Matched.ID,metadata[[ByColname]]),c(ByColname,keepCol)]
    cat("Returning metadata subset based on IDs and colnames specified.\n\n")
    Matched.Data
  } else {
    Matched.Data <- metadata[match(Matched.ID,metadata[[ByColname]]),]
    cat("Returning metadata based on IDs specified.\n\n")
    Matched.Data
  }
  # print the unmatched IDs
  cat(paste("Unmatched IDs:", paste(unMatched.ID, collapse = ", ")))
  
  #Return the matched data
  return(Matched.Data)

}

#-- Example usage: --#

IDs <- Get.Matched.ID(queryID = c("Sample1_A", "Sample2_B", "Sample3_C"),
               metadata = data.frame(SampleID = c("Sample1", "Sample2", "Sample4"),
                                     OtherInfo = c(10, 20, 30)),
               ByColname = "SampleID",keepCol = "OtherInfo")
print(IDs)
# Should return data.frame:
# SampleID OtherInfo
# 1  Sample1        10
# 2  Sample2        20

