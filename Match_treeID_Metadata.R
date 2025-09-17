# This script matches labels from a tree file to a metadata file 
# with coordinate and other information

#libraries needed
library(readxl)
library(phytools)

#Load source functions
source("matche2metadata.R")
#Generate a file called "config.ymal" if it doesn't exist
source("config.R")

#Read in data
tree <- read.tree(config$tree.file)
MasterSheet <- read_excel(config$metadata.file,na = "NA",trim_ws = T )

#output file name
Output.Name <- "Shiner_Cytb_Coordenates.csv"


#show columns available in the metadata file
colnames(MasterSheet)

# Specify which columns to keep from the metadata file
Keep.columns <- c("Latitude",	"Longitude",	"Site",	"HUC2Name",	"Ecoregion",	
                  "HUC4Name",	"Species",	"mtDNA-ID",	"Source")


# Create a function that searches for a word on a string 
# if the word is on the string then returns the same word that was searching otherwise returns NA
# The function should also return NA if the query is NA
# The word should be searched considering separators like "_" or "-" or " " or "."
# Only one separator should be considered at a time, the one with highest frequency in the string
# Match.ID <- function(query,string) {
#   if (is.na(query)) {
#     return(NA_character_)
#   } else {
#     separators <- c("_", "-", " ", ".","|")
#     separator_counts <- sapply(separators, function(sep) length(gregexpr(sep, string, fixed = TRUE)[[1]]))
#     best_separator <- separators[which.max(separator_counts)]
#     pattern <- paste0(query,best_separator)
#     if (grepl(pattern, string)) {
#       return(query)
#     } else {
#       return(NA_character_)
#     }
#   }
# }
# 
# # Match the IDs from the tree to the metadata file
# # Create a vector to store the matched IDs
# 
# Matched.ID <- vector()
# # Loop through the tree tip labels and the metadata file to find matches
# # If a match is found, store the matched ID in the Matched.ID vector
# # show progress bar "---" for the for loop
# pb <- txtProgressBar(min = 0, max = length(tree$tip.label), style = 3)
# for(i in 1:length(tree$tip.label)){
#   Matched.ID[i] <- NA
#   for(j in 1:dim(MasterSheet)[1]){
#     if (!is.na(Match.ID(MasterSheet$Seq.ID[j],tree$tip.label[i]))){
#       Matched.ID[i] <- Match.ID(MasterSheet$Seq.ID[j], tree$tip.label[i])
#       break
#     } 
#   }
#   setTxtProgressBar(pb, i)
# }
# 
# Matched.ID

# # Create a data frame with the matched IDs and the coordinates based on the matched IDs keeping only the columns specified in Keep.columns
# Map.Data <- MasterSheet[match(Matched.ID,MasterSheet$Seq.ID),Keep.columns]

Map.Data <- Get.Matched.ID(queryID = tree$tip.label,
                   metadata = MasterSheet,
                   ByColname = "Seq.ID",
                   keepCol = Keep.columns)

Map.Data[Map.Data$Seq.ID == "NC_080906.1",]



#Map.Data <- na.omit(Map.Data)

#Remove rows that do not have coordinates
Map.Data <- Map.Data[!is.na(Map.Data$Latitude) & !is.na(Map.Data$Longitude),]
dim(Map.Data)
#write the data frame to a csv file

write.csv(Map.Data,Output.Name , row.names = F)
cat(paste0("Map data written to ", Output.Name, "\n"))
