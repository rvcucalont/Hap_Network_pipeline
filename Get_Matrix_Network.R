# This script will generate a population matrix for network analysis based on metadata and fasta files
# The output files will be:
# 1) A csv file with the number of samples per population (PopArt format) called "popmap_network_by-<GROUP>.csv"
# 2) A csv file with the haplotype matrix per population called "Haplotype_matrix_by-<GROUP>.csv"

# Load libraries
library(dplyr)
library(readxl)
library(ape)

#Load source functions
source("functions.R")
#Generate a file called "config.ymal" if it doesn't exist
source("setup.R")

# Read Input files 
fasta.file <- read.FASTA(config$file_name)
fasta.labels <- names(fasta.file)
metadata.file <- read_excel(config$metadata.file,trim_ws = T,na = "NA")

#############################################################################
#--- Population assignment MAtrix for Network Analysis in Software PopArt---#
#############################################################################
# Match labels from fasta file to metadata file
# Select which columns to keep from the metadata file
Keep.columns <- c("Site","HUC2Name", "Region","System","Plain",
                  "Ecoregion","HUC4Name","Species","mtDNA-ID","Source")

# Extract metadata based on matching IDs (function in functions.R)
selected.data <- Get.Matched.ID(queryID = fasta.labels,
               metadata = metadata.file,
               ByColname = "Seq.ID",
               keepCol = Keep.columns)

selected.data

#Choose columns to keep for the final matrix
colnames(selected.data)

GROUP <- "Ecoregion"

#Get the number of haplotypes per GROUP
network_ByGroup <- selected.data %>% group_by(label,!!sym(GROUP)) %>% 
  summarise(
    N = length(label)
  )
network_ByGroup


# get the sites ordered from table for consistency
unique(network_ByGroup[,2])
site_ordered <- unique(network_ByGroup[,2])[[1]]
# site_ordered <- c( "McFarland", "Marcell", "LaSalleLake" ,  "WhiteEarthLake","Battle" , "Croix"   ,   "Pool1"  ,    "DevilsLake",
                   # "Pool4" ,  "OpenR" ,  "Ashtabula" , "FrenchCr", "Allegheny" , "Monongahela", "Dam2"  , "buchanani" , "volucellus"  )


#convert the table into a pairwise matrix and then data frame for easier access to the values
network_table <- xtabs(N~.,network_ByGroup)
network_matrix <- matrix(network_table,nrow = length(row.names(network_table)),ncol = length(colnames(network_table)))
colnames(network_matrix) <- colnames(network_table)
rownames(network_matrix) <- rownames(network_table)
network_df <- as.data.frame(network_matrix)
network_df

#reorder columns
network_df <- network_df[,site_ordered]
network_df

#Save data
DataSetName <- paste0("popmap_network_by-",GROUP,".csv")
write.csv(network_df,file = DataSetName,quote = F)

#####################################################
#--- Haplotype matrix with population assignment ---#
#####################################################

# Create a column with Haplotype IDs only from network_ByGroup$label
network_ByGroup$Haplotype <- regmatches(network_ByGroup$label, regexpr("Hap[0-9]+$", network_ByGroup$label))

#Get the number of haplotypes per site
in_table_site_hap <- network_ByGroup %>% group_by(!!sym(GROUP),Haplotype) %>% 
  summarise(
    N = length(GROUP)
  )
in_table_site_hap

#convert the table into a pairwise matrix and then data frame for easier access to the values
in_table_table <- xtabs(N~.,in_table_site_hap)
in_table_matrix <- matrix(in_table_table,nrow = length(row.names(in_table_table)),ncol = length(colnames(in_table_table)))
colnames(in_table_matrix) <- colnames(in_table_table)
rownames(in_table_matrix) <- rownames(in_table_table)
in_table_df <- as.data.frame(in_table_matrix)
in_table_df

#order columns
unique(colnames(in_table_df))
Hap_order <- paste0(rep(x = "Hap",length(unique(in_table_site_hap$Haplotype))),1:length(unique(in_table_site_hap$Haplotype)))  
in_table_df <- in_table_df[,Hap_order]
in_table_df$Site <- row.names(in_table_df)
#move last column to first
in_table_df <- in_table_df %>% select(Site, everything())
in_table_df

#Reorder rows by specified group order
in_table_df <- in_table_df[site_ordered,]

#save csv
NameMatrix <- paste0("Haplotype_matrix_by-",GROUP,".csv")
write.csv(in_table_df, file="Haplotype_matrix_mimic_Site.csv", quote = F,row.names = T)

