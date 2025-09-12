#libraries
library(phytools)

#load data
fulltree <- read.tree(file = "Cytb_06-18-2025.treefile") 
fulltree

#Get descendants
ProjectName <- "mimic_clade_labels"

#Root

RootTree <- root(phy = fulltree,outgroup = "GQ275161.1_Luxilus_chrysocephalus")

MRCA <- getMRCA(phy = RootTree,tip = c("SH211_OP_OpenR","SH222_OP_OpenR"))
clade <- getDescendants(tree = RootTree,node = MRCA)

#Remove NAs
tiplab <- fulltree$tip.label[clade]
tiplabClean <- tiplab[!is.na(tiplab)]
tiplabClean

#write into a file
write.table(x = tiplabClean,file = paste0(ProjectName,".txt"),quote = F,row.names = F,col.names = F )
