# library(stringr)
# library(dplyr)
# library(viridis)
library(readxl)
library(ape)

#Load source functions
source("functions.R")

#####################################
# -- popmap for Network Analysis ---#
#####################################

#Generate a file called "config.ymal" if it doesn't exist
if(!file.exists("config.yaml")){
  cat("file_name: ''\nmetadata.file: ''", file = "config.yaml")
  stop("A config.yaml file has been created. Please edit it with the correct file paths and run the script again.")
} else {
  # Load user-specific configuration file with file paths
  config <- yaml::read_yaml("config.yaml") 
  cat(paste0("Configuration loaded from config.yaml:\n",
             "Fasta file: ", config$file_name, "\n",
             "Metadata file: ", config$metadata.file, "\n"))
}

# Read Input files 
fasta.file <- read.FASTA(config$file_name)
fasta.labels <- names(fasta.file)
metadata.file <- read_excel(config$metadata.file,trim_ws = T,na = "NA")

# Match labels from fasta file to metadata file
# Select which columns to keep from the metadata file
Keep.columns <- c("Site","HUC2Name", "Region","System","Plain",
                  "Ecoregion","HUC4Name","Species","mtDNA-ID","Source")

# Extract metadata based on matching IDs
selected.data <- Get.Matched.ID(queryID = fasta.labels,
               metadata = metadata.file,
               ByColname = "Seq.ID",
               keepCol = Keep.columns)

selected.data

#Choose columns to keep for the final matrix
colnames(selected.data)

GROUP <- "Ecoregion"

#Get the number of haplotypes per site
network_table <- selected.data %>% group_by(new_name,!!sym(GROUP)) %>% 
  summarise(
    N = length(Sample_Name)
  )
network_table

#change name of the grouping column to "group"
#colnames(network_table)[2] <- "group"

# get the sites ordered from table <------------------Needs Fixing from this point!!!
unique(network_table[,2])
site_ordered <- as.vector(unique(network_table[,2]))[[1]]
# site_ordered <- c( "McFarland", "Marcell", "LaSalleLake" ,  "WhiteEarthLake","Battle" , "Croix"   ,   "Pool1"  ,    "DevilsLake",
                   # "Pool4" ,  "OpenR" ,  "Ashtabula" , "FrenchCr", "Allegheny" , "Monongahela", "Dam2"  , "buchanani" , "volucellus"  )




#remove first column with the order number of the sites
# network_table <- network_table[,-1]
# network_table
tol21rainbow= c("#771155", "#CC99BB", "#114477", "#77AADD", "#117777", 
                "#44AAAA", "#77CCCC", "#117744", "#44AA77", "#88CCAA", 
                "#777711", "#AAAA44", "#DDDD77", "#774411", "#AA7744", 
                "#DDAA77", "#AA4455")

tol21rainbow= c("#771155", "#AA4488", "#CC99BB", "#114477", "#4477AA", "#77AADD", "#117777", "#44AAAA", "#77CCCC", "#117744", "#44AA77", "#88CCAA", "#777711", "#AAAA44", "#DDDD77", "#774411", "#AA7744", "#DDAA77", "#771122", "#AA4455", "#DD7788")

#pal(tol21rainbow)


#convert the table into a pairwise matrix and then data frame for easier access to the values
network_table <- xtabs(N~.,network_table)
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

##############################
#--- Get Haplotype matrix ---#
##############################
#lets add names to the columns so we know what they are
network_popmap

#Get the number of samples per site
in_table_site <- network_popmap %>% group_by(!!sym(GROUP)) %>%
  summarise(
    N = length(GROUP)
  )
in_table_site <- as.data.frame(in_table_site)
in_table_site

#Get the number of haplotypes per site
in_table_site_hap <- network_popmap %>% group_by(!!sym(GROUP),Haplotype) %>% 
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

#Reorder rows
in_table_df <- in_table_df[site_ordered,]


#save csv
NameMatrix <- paste0("Haplotype_matrix_by-",GROUP,".csv")
write.csv(in_table_df, file="Haplotype_matrix_mimic_Site.csv", quote = F,row.names = T)
in_table_df

