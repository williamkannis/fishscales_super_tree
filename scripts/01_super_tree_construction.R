#-------------------------------------------------------------------------------
#
#  Phylogenetic super tree construction  
#                           
#-------------------------------------------------------------------------------

# Author

# Created

# Description:
# This script creates a phylogenetic supertree using the Fish Tree of Life 
# (Rabosky et al. 2018) as a backbone, containing around 89% of species in 
# community data set. Missing species were added based on relationships from 
# other, smaller, genus specific trees from various sources (see appendix 3). 
# The final tree is formatted so tip label match up with species names in 
# community and trait data sets.


# House Keeping  ---------------------------------------------------------------
rm(list=ls())

# Load Packages
library(fishtree)
library(stringr)
library(dplyr)
library(ape)
library(picante)
library(RRphylo)

# Directories
tree_dir <- "raw_tree_files"



# Load in Data -----------------------------------------------------------------

# Species names from community data
species_names <- read.csv("data/species_source.csv")[,"species"]
species_names <- species_names[order(species_names)]  # order by name

# Phylo tree from fish tree of life (Rabosky et al. 2018)
tree_b <- fishtree::fishtree_phylogeny(type = "chronogram")  

# Format tip labels
tree_b$tip.label <- gsub("_"," ", tree_b$tip.label)  
tree_tips_b <- tree_b$tip.label  


# Coarsen subspecies -----------------------------------------------------------

# Many species in the tree are separated into subspecies
# Coarsen these to species level
# pull out subspecies names (3 word names)
subspecies <-  
  tree_b$tip.label[
    str_detect(
      tree_b$tip.label,
      "^[a-zA-Z]*\\s[a-zA-Z]*\\s[a-zA-Z]*$"
      ) == T
    ]  

# make data frame with species name for each subspecies
subspecies_df <- data.frame(
  subspecies,
  revised = word(subspecies,1,2)
  ) 

# only keep one subspecies for each species
subspecies_df <- subspecies_df[!duplicated(subspecies_df$revised),]  

# for loop to replace subspecies name with species name
for (i in 1:nrow(subspecies_df)){  
  tree_b$tip.label[tree_b$tip.label == subspecies_df[i,1]] <- 
    subspecies_df[i,2]
}
# remove duplicate subspecies names so only one remains
tree_b <- drop.tip(tree_b,subspecies)  


# Harmonize spellings  ---------------------------------------------------------

# Many records are due to a spelling differences between the two list. 
# Update misspelled tip labels to match community data set
tree_b$tip.label[tree_b$tip.label == "Cichlasoma urophthalmum"] <- 
  "Cichlasoma urophthalmus"
tree_b$tip.label[tree_b$tip.label ==  "Etheostoma chlorosomum"] <- 
  "Etheostoma chlorosoma"
tree_b$tip.label[tree_b$tip.label == "Etheostoma mediae"] <- 
  "Etheostoma meadiae"
tree_b$tip.label[tree_b$tip.label == "Etheostoma microlepidus"] <- 
  "Etheostoma microlepidum"
tree_b$tip.label[tree_b$tip.label ==  "Moxostoma duquesnii"] <- 
  "Moxostoma duquesnei"
tree_tips_b <- tree_b$tip.label  

# Pull up species that are truly missing
miss_fish <- species_names[!species_names %in% tree_tips_b]

# Prepare tree for merging  ----------------------------------------------------

# Merge specie specific trees to main tree. This is the ideal method for adding 
# truly missing species. IF trees cannot be find, see remaining species section
# at bottom of script

# Trim tree to keep processing time down
# add species not in data set but needed to bind missing species to tree
species_names_construction <- c(
  species_names, 
  "Campostoma pullum",
  "Catostomus bernardini",
  "Cottus paulus",
  "Catostomus cahita" ,
  "Coregonus nigripinnis", 
  "Ctenogobius sagittula",
  "Elassoma boehlkei", 
  "Etheostoma bison",
  "Etheostoma chermocki", 
  "Etheostoma saludae", 
  "Evorthodus minutus", 
  "Hypostomus boulengeri", 
  "Hypostomus brevis", 
  "Microgobius microlepis", 
  "Moxostoma hubbsi",
  "Neogobius fluviatilis", 
  "Neogobius pallasi", 
  "Poecilia wingei",
  "Menidia peninsulae"
  )  
tree_backbone_data <- keep.tip(
  tree_b, 
  species_names_construction[species_names_construction %in% tree_b$tip.label]
  )
tree_backbone_data$node.label <- 1:tree_backbone_data$Nnode
tree_backbone_data_og <-tree_backbone_data

# Bakcbone tree is ready for taxa specific trees to be merged


# Catostomidae -----------------------------------------------------------------

# Catostomus and Moxostoma (Bagley et al. 2018) 
tree_catostomidae <- ape::read.tree(file.path(tree_dir,"Catostomidae_Bagley_et_al_2018.phy"))  

# Format to match data set
tree_catostomidae$tip.label[
  tree_catostomidae$tip.label == "C_fumeventris1"
  ] <- "Catostomus fumeiventris"  
tree_catostomidae$tip.label[
  tree_catostomidae$tip.label == "C_latipinnis_MSB49601"
  ] <- "Catostomus latipinnis"
tree_catostomidae$tip.label[
  tree_catostomidae$tip.label == "M_spcf_poe_UAIC12746_13_1"
  ] <- "Moxostoma sp. Apalachicola Redhorse"
tree_catostomidae$tip.label[
  tree_catostomidae$tip.label == "M_spcf_lachneri_UAIC12462_03"
  ] <- "Moxostoma sp. Brassy Jumprock"
tree_catostomidae$tip.label[
  tree_catostomidae$tip.label == "M_spcf_macro_UAIC11643_01_1"
  ] <- "Moxostoma sp. Sicklefin Redhorse"


# # Check to see if tree contains all species in data set
# # names are no in easy format to  fix. Unsure if all species are in tree
# species_names[word(species_names,1) %in% c("Catostomus","Moxostoma")]
# cat_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% 
#     c(
#       "Catostomus",
#       "Moxostoma",
#       "Carpiodes",
#       "Ictiobus",
#       "Cycleptus",
#       "Misgurnus",
#       "Cyprinus",
#       "Hypophthalmichthys")
#   ]
# tree_backbone_cat <- keep.tip(tree_backbone_data,cat_names)
# 
# # label nodes to easier determine node ages
# tree_catostomidae$node.label <- 1:tree_catostomidae$Nnode
# tree_backbone_cat$node.label <- 1:tree_backbone_cat$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(
#   tree_catostomidae, 
#   show.node.label = T,
#   use.edge.length = T, 
#   cex = .6
#   )
# plot.phylo(
#   tree_backbone_cat, 
#   show.node.label = T,
#   use.edge.length = T
#   )
# 
# # Find tip and node ages
# tree.age(tree_catostomidae)
# tree.age(tree_backbone_cat)

# Merge trees
data <- data.frame(
  bind = c(
    "Catostomus fumeiventris",  # DW - let tree.merge assign age
    "Catostomus latipinnis",  #  W
    "Moxostoma sp. Apalachicola Redhorse",  # DW - let tree.merger define age
    "Moxostoma sp. Brassy Jumprock",  # DW - let tree.merger define age
    "Moxostoma sp. Sicklefin Redhorse"),  # DW - let tree.merger define age
  reference = c(
    "Catostomus tahoensis-Catostomus columbianus",
    "Catostomus bernardini-Catostomus cahita",
    "Moxostoma congestum",
    "Moxostoma hubbsi",
    "Moxostoma pisolabrum-Moxostoma macrolepidotum"
    ),  
  poly = c(
    F,
    F,
    F,
    F,
    F
    )
  )  
nod.age <- c("Catostomus latipinnis-Catostomus bernardini" = 4.765)  
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_catostomidae, 
  node.ages = nod.age
  )  


# Chrosomus  -------------------------------------------------------------------

# Catostomidae tree TimeTree
tree_chrosomus <- ape::read.tree(file.path(tree_dir,"timetree_Chrosomus.nwk"))  

# # Check to see if tree contains all species in data set
# species_names[word(species_names,1) == "Chrosomus"]
# # all species in data set are in new tree, so it might be
# # better to replace whole genus
# chroso_names <-tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Chrosomus")
#   ]
# tree_backbone_chroso <- keep.tip(tree_backbone_data, chroso_names)
# # label nodes to easier determine node ages
# tree_chrosomus$node.label <- 1:tree_chrosomus$Nnode
# tree_backbone_chroso$node.label <- 1:tree_backbone_chroso$Nnode
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(tree_chrosomus, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_chroso, show.node.label = T,use.edge.length = F)
# 
# # Find tip and node ages
# tree.age(tree_chrosomus)
# tree.age(tree_backbone_chroso)

# Merge trees
data <- data.frame(
  bind = c("Chrosomus neogaeus"),  
  reference = c("Chrosomus eos-Chrosomus tennesseensis"),  
  poly = c(F))  
nod.age <- c("Chrosomus neogaeus-Chrosomus eos" = 17.944)  #1-17.944 #1-17.448. works!

tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_chrosomus, 
  node.ages = nod.age
  )  


# Coregoninae ------------------------------------------------------------------

# Coregonus tree from TimeTree
tree_coregonus <- ape::read.tree(file.path(tree_dir,"timetree_Coregoninae.nwk"))  

# # Check to see if tree contains all species in data set
# species_names[word(species_names,1) == "Coregonus"]
# # all species in data set are in new tree, so it might be
# # better to replace whole genus
# core_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Coregonus")
#   ]
# tree_backbone_core <- keep.tip(tree_backbone_data, core_names)
# # label nodes to easier determine node ages
# tree_coregonus$node.label <- 1:tree_coregonus$Nnode
# tree_backbone_core$node.label <- 1:tree_backbone_core$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_coregonus, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_core, show.node.label = T,use.edge.length = F)

# Find tip and node ages
tree.age(tree_coregonus)
tree.age(tree_backbone_core)

# Merge trees
data <- data.frame(
  bind = c("Coregonus artedi"),
  reference = c("Coregonus nigripinnis"),
  poly = c(F))  
# Coregonus nigripinnis is not in data set and will need to be included in the 
# backbone to merge
nod.age <- c("Coregonus artedi-Coregonus nigripinnis" = 0.272)  # #26-0.272 #23-0.093
tree_backbone_data <- tree.merger(
  tree_backbone_data,
  data, 
  tree_coregonus, 
  node.ages = nod.age
  )  

# Elassoma ---------------------------------------------------------------------
# Tree not time calibrated, treemerger chooses node ages

# Elassoma tree from Sandel et al. 2014
tree_elasomma <- ape::read.tree(file.path(tree_dir,"elassoma_sandel_et_al_2014.nwk.txt"))

# change labels to match data set
tree_elasomma$tip.label[tree_elasomma$tip.label == "'Elassoma_okatie_8AF'"] <- 
  "Elassoma okatie"  

# # Check to see if tree contains all species in data set
# species_names[word(species_names,1) == "Elassoma"]
# 
# e_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Elassoma")
#   ]
# tree_backbone_e <- keep.tip(tree_backbone_data, e_names)
# 
# # label nodes to easier determine node ages
# tree_backbone_e$node.label <- 1:tree_backbone_e$Nnode
# tree_elasomma$node.label <- 1:tree_elasomma$Nnode
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(tree_backbone_e,show.node.label = T, use.edge.length = F)
# plot.phylo(tree_elasomma,show.node.label = T, use.edge.length = F)

# Merge trees
data <- data.frame(
  bind = c("Elassoma okatie"),  
  reference = c("Elassoma boehlkei"),  
  poly = c(F))
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_elasomma
  )


# Erimyzon ---------------------------------------------------------------------

# Erimyzon tree from Hunt et al., 2021
tree_erimyzon <- ape::read.nexus(file.path(tree_dir,"erimyzon_hunt_et_al_2021.tre")) 

# change tip labels to match data set
tree_erimyzon$tip.label[tree_erimyzon$tip.label == "E.claviformis2AL"] <- 
  "Erimyzon claviformis"  

# # Check to see if tree contains all species in data set
# species_names[word(species_names,1) == "Erimyzon"]
# eri_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Erimyzon")
#   ]
# tree_backbone_eri <- keep.tip(tree_backbone_data, eri_names)
# # label nodes to easier determine node ages
# tree_erimyzon$node.label <- 1:tree_erimyzon$Nnode
# tree_backbone_eri$node.label <- 1:tree_backbone_eri$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_erimyzon, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_eri, show.node.label = T,use.edge.length = T)
# 
# # Find tip and node ages
# tree.age(tree_erimyzon)
# tree.age(tree_backbone_eri)

# Merge trees
data <- data.frame(
  bind = c("Erimyzon claviformis"),  
  reference = c("Erimyzon sucetta"),  
  poly = c(F)
  )  

nod.age <- c("Erimyzon claviformis-Erimyzon sucetta" = 4)  
# age of nodes as derived from tree.age function. These seem off. find out scale 
# of ages. it seems multiplying by 1000 fixes this. 
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_erimyzon, 
  node.ages = nod.age
  )  

# Etheostoma -------------------------------------------------------------------
# Tree not time calibrated, treemerger chooses node ages

# Etheostoma tree from Near et al. 2011
tree_etheostoma <- ape::read.nexus(file.path(tree_dir,"percidea_near_et_al_2011.nex")) 

# change tip labels to match data set
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_atripinne_A"
  ] <- "Etheostoma atripinne"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_gutselli_A"
  ] <- "Etheostoma gutselli"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_cf_stigmaeum_bgdA"
  ] <- "Etheostoma jimmycarter"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_trisella_A"
  ] <- "Etheostoma trisella"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_cf_zonistium_C"
  ] <- "Etheostoma sp. Blueface Darter"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_cf_spectabile_mamA"
  ] <- "Etheostoma sp. Mamequit Darter"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_cf_bellator_A"
  ] <- "Etheostoma sp. Sipsey Darter"  
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_cf_stigmaeum_higlandA"
  ] <- "Etheostoma teddyroosevelt"
tree_etheostoma$tip.label[
  tree_etheostoma$tip.label == "Etheostoma_cf_oophylax_AF"
  ] <- "Etheostoma sp. Clarks Darter"

# # Check to see if tree contains all species in data set
# etho_species <- species_names[word(species_names,1) == "Etheostoma"]  
# 
# # change format of species name to match data set
# etho_tips <- ifelse(
#   lengths(strsplit(tree_etheostoma$tip.label, '_')) ==4, 
#   word(gsub("_"," " ,tree_etheostoma$tip.label),1,3), 
#   word(gsub("_"," " ,tree_etheostoma$tip.label),1,2)) 
# etho_species[!etho_species %in% etho_tips]  
# # does not contain all species in data set and backbone trees. Whole genus 
# # cannot be easily swapped
# etho_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Etheostoma")
#   ]
# tree_backbone_etho <- keep.tip(tree_backbone_data, etho_names)
# 
# # label nodes to easier determine node ages
# tree_etheostoma$node.label <- 1:tree_etheostoma$Nnode
# tree_backbone_etho$node.label <- 1:tree_backbone_etho$Nnode
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(
#   tree_etheostoma,
#   show.node.label = T,
#   use.edge.length = F, 
#   cex = .4)
# plot.phylo(
#   tree_backbone_etho, 
#   show.node.label = T,
#   use.edge.length = F, 
#   cex = .4)

# Merge trees
data <- data.frame(
  bind = c(
    "Etheostoma atripinne", 
    "Etheostoma gutselli", 
    "Etheostoma jimmycarter",  
    "Etheostoma trisella",  #
    "Etheostoma sp. Blueface Darter", 
    "Etheostoma sp. Mamequit Darter", 
    "Etheostoma sp. Sipsey Darter",
    "Etheostoma teddyroosevelt",
    "Etheostoma sp. Clarks Darter"
    ),  
  reference = c(
    "Etheostoma simoterum",
    "Etheostoma blennioides",
    "Etheostoma jessiae",
    "Etheostoma saludae-Etheostoma hopkinsi",
    "Etheostoma zonistium-Etheostoma cervus",
    "Etheostoma bison",
    "Etheostoma bellator-Etheostoma chermocki",
    "Etheostoma jimmycarter",
    "Etheostoma chienense"
    ),
  poly = c(
    F,
    F,
    F,
    F,
    F,
    F,
    F,
    F,
    F
    )
  )  
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_etheostoma
  )


# Gobiiformes:  ----------------------------------------------------------------

# Ctenogobius, Gobioides, Microgobius, and Neogobius (TimeTree)
tree_gobiiformes <- ape::read.tree(file.path(tree_dir,"timetree_Gobiiformes.nwk"))  

# Format to match data set
tree_gobiiformes$tip.label <- gsub("_", " ", tree_gobiiformes$tip.label)
tree_gobiiformes$tip.label[
  tree_gobiiformes$tip.label == "Gobioides broussonnetii"
  ] <- "Gobioides broussonetii"

# # Check to see if tree contains all species in data set
# gobi_species <- species_names[
#   word(species_names,1) %in% 
#     c("Ctenogobius", "Gobioides", "Microgobius", "Neogobius")
#   ]  
# gobi_species[!gobi_species %in% tree_gobiiformes$tip.label]
# # all species in data set are in new tree
# gobi_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in%
#     c("Ctenogobius", "Gobioides", "Microgobius", "Neogobius","Evorthodus")
#   ]
# tree_backbone_gobi <- keep.tip(tree_backbone_data, gobi_names)
# # label nodes to easier determine node ages
# tree_gobiiformes$node.label <- 1:tree_gobiiformes$Nnode
# tree_backbone_gobi$node.label <- 1:tree_backbone_gobi$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_gobiiformes, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_gobi, show.node.label = T,use.edge.length = F)
# 
# # Find tip and node ages
# tree.age(tree_gobiiformes)
# tree.age(tree_backbone_gobi)

# Merge trees
data <- data.frame(
  bind = c(
    "Ctenogobius shufeldti",
    "Gobioides broussonetii",
    "Neogobius melanostomus",
    "Microgobius gulosus"
    ),  
  reference = c(
    "Ctenogobius sagittula-Ctenogobius boleosoma",
    "Evorthodus minutus",
    "Neogobius fluviatilis-Neogobius pallasi",
    "Microgobius microlepis"
    ),
  poly = c(
    T,
    F,
    F,
    F
    )
  )  
nod.age <- c(
  "Ctenogobius shufeldti-Ctenogobius sagittula" = 18.964, #18.96 #6-18.964  
  # use age of orginal tree to preserve structure of tree
  "Gobioides broussonetii-Evorthodus minutus" = 29.20, #29.20 #4-42.424
  "Neogobius melanostomus-Neogobius fluviatilis" = 12.34,  #12.34 # #2-55.819 #3-8.404
  "Microgobius gulosus-Microgobius microlepis" = 11.98)  #11.98 #2-55.819
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_gobiiformes, 
  node.ages = nod.age
  )  


# Hypostomus -------------------------------------------------------------------

# Hypostomus tree from TimeTree
tree_loric <- ape::read.tree(file.path(tree_dir,"timetree_Loricariidae.nwk")) 

# Format to match data set
tree_loric$tip.label <- gsub("_", " ", tree_loric$tip.label)

# Check to see if tree contains all species in data set
# hypostomus_species <- species_names[word(species_names,1) == "Hypostomus"]  
# hypostomus_species[!hypostomus_species %in% tree_loric$tip.label]
# # only one species in genus, might not make sense to replace whole genus
# hypo_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Hypostomus","Pterygoplichthys")
#   ]
# tree_backbone_hypo <- keep.tip(tree_backbone_data, hypo_names)
# # Trim tree
# tree_loric <- keep.tip(
#   tree_loric, 
#   c(
#     tree_backbone_hypo$tip.label[
#       tree_backbone_hypo$tip.label %in% tree_loric$tip.label
#       ],
#     "Hypostomus plecostomus"
#     )
#   )
# 
# # label nodes to easier determine node ages
# tree_loric$node.label <- 1:tree_loric$Nnode
# tree_backbone_hypo$node.label <- 1:tree_backbone_hypo$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_loric, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_hypo, show.node.label = T,use.edge.length = F)
# 
# # Find tip and node ages
# tree.age(tree_loric)
# tree.age(tree_backbone_hypo)

# Merge trees
data <- data.frame(
  bind = c("Hypostomus plecostomus"),  
  reference = c("Hypostomus boulengeri-Hypostomus brevis"),  
  poly = c(F)
  )  
nod.age <- c("Hypostomus plecostomus-Hypostomus brevis" = 4.269)  # #3-4.269 #1-10.955 #3-3.371
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_loric, 
  node.ages = nod.age
  )  


# Labidesthes ------------------------------------------------------------------

# Labidesthes tree from Bloom et al. 2013
tree_labi <- ape::read.nexus(file.path(tree_dir,"Labidesthes_bloom_et_al_2013.tre"))

# Format to match data set
tree_labi$tip.label[tree_labi$tip.label == "Lsvan3844"] <- 
  "Labidesthes vanhyningi"  

# # Check to see if tree contains all species in data set
# labi_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label, 1) %in% c("Labidesthes","Menidia")
#   ]
# tree_backbone_labi <- keep.tip(tree_backbone_data,labi_names)
# 
# # label nodes to easier determine node ages
# tree_labi$node.label <- 1:tree_labi$Nnode
# tree_backbone_labi$node.label <- 1:tree_backbone_labi$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_labi, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_labi, show.node.label = T,use.edge.length = T)
# 
# # Find tip and node ages
# tree.age(tree_labi)
# tree.age(tree_backbone_labi)

# Use  Tree from Bloom et al. 2009 to add missing tips
data <- data.frame(
  bind = c("Labidesthes vanhyningi"),  
  reference = c("Labidesthes sicculus"),  
  poly = c(F)
  )  
node.age <- c("Labidesthes vanhyningi-Labidesthes sicculus" = 5.667)  # #29-5.667 #1-37.44
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_labi, 
  node.ages = node.age
  )  


# Lepidomeda -------------------------------------------------------------------

# Lepidomeda tree from TimeTree
tree_lepidomeda <- ape::read.tree(file.path(tree_dir,"timetree_Lepidomeda.nwk"))  

# Format to match data set
tree_lepidomeda$tip.label <- gsub("_", " ", tree_lepidomeda$tip.label)

# # Check to see if tree contains all species in data set
# lepidomeda_species <- species_names[word(species_names,1) == "Lepidomeda"]
# lepidomeda_species[!lepidomeda_species %in% tree_lepidomeda$tip.label]
# # only one species in genus, might not make sense to replace whole genus
# lepidomeda_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% c("Lepidomeda")
#   ]
# tree_backbone_lepidomeda <- keep.tip(tree_b, lepidomeda_names)
# 
# # label nodes to easier determine node ages
# tree_lepidomeda$node.label <- 1:tree_lepidomeda$Nnode
# tree_backbone_lepidomeda$node.label <- 1:tree_backbone_lepidomeda$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(
#   tree_lepidomeda, 
#   show.node.label = T,
#   use.edge.length = F
#   )
# plot.phylo(
#   tree_backbone_lepidomeda, 
#   show.node.label = T,
#   use.edge.length = F
#   )
# 
# # Find tip and node ages
# tree.age(tree_lepidomeda)
# tree.age(tree_backbone_lepidomeda)

# Merge trees
data <- data.frame(
  bind = c("Lepidomeda copei"),  
  reference = c("Lepidomeda vittata"),  
  poly = c(F)
  )  
nod.age <- c("Lepidomeda copei-Lepidomeda vittata" = 11.33)  
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_lepidomeda, 
  node.ages = nod.age
  )  


# Fundulidae -----------------------------------------------------------------

# Leptolucania tree from TimeTree
tree_fundulidae <- ape::read.tree(file.path(tree_dir,"timetree_Fundulidae.nwk")) 

# Format to match data set
tree_fundulidae$tip.label <- gsub("_", " ", tree_fundulidae$tip.label)

# # Check to see if tree contains all species in data set
# fun_names <- species_names[
#   word(species_names,1) %in% c("Lucania","Fundulus","Leptolucania")
#   ]
# tree_fundulidae$tip.label[!fun_names %in% tree_fundulidae$tip.label]
# # only one species in genus, might not make sense to replace whole genus
# lepto_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label, 1) %in% 
#     c("Lucania","Fundulus","Jordanella","Cyprinodon")
#   ]
# tree_backbone_lepto <- keep.tip(tree_backbone_data,lepto_names)
# # label nodes to easier determine node ages
# tree_fundulidae$node.label <- 1:tree_fundulidae$Nnode
# tree_backbone_lepto$node.label <- 1:tree_backbone_lepto$Nnode
#
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_fundulidae, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_lepto, show.node.label = T,use.edge.length = F)
#
# # Find tip and node ages
# tree.age(tree_fundulidae)
# tree.age(tree_backbone_lepto)

# Merge trees
data <- data.frame(
  bind = c( "Leptolucania ommata"),  
  reference = c("Lucania parva-Fundulus heteroclitus"),  
  poly = c(F)
  )  

nod.age <- c("Leptolucania ommata-Lucania parva" = 30)  
# Node age tree.merger gave was way to old. Use 30, this is the earliest age 
# you can give it without messing up tree
tree_backbone_data <- tree.merger(
  tree_backbone_data, data, 
  tree_fundulidae, 
  node.ages = nod.age
  )  

# Lepomis ----------------------------------------------------------------------

# Lepomis Tree from Kim et al. 2022
tree_lepomis <- ape::read.nexus(file.path(tree_dir,"Lepomis_kim_et_al_2022.tree"))

# Format to match data set
tree_lepomis$tip.label[tree_lepomis$tip.label == "PEL"] <- "Lepomis peltastes"  

# # Check to see if tree contains all species in data set
# lepomis_species <- species_names[word(species_names,1) == "Lepomis"]
# micropterus_species[!micropterus_species %in% tree_micropterus$tip.label]
# # Contains all species
# 
# lepomis_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label, 1) == "Lepomis"
#   ]
# tree_backbone_lep <- keep.tip(tree_backbone_data,lepomis_names)
# 
# # label nodes to easier determine node ages
# tree_lepomis$node.label <- 1:tree_lepomis$Nnode
# tree_backbone_lep$node.label <- 1:tree_backbone_lep$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_lepomis, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_lep, show.node.label = T,use.edge.length = T)
# 
# # Find tip and node ages
# tree.age(tree_lepomis)
# tree.age(tree_backbone_lep)

data <- data.frame(
  bind = c("Lepomis peltastes"),  
  reference = c("Lepomis megalotis"),  
  poly = c(F)
  )  
nod.age <- c("Lepomis peltastes-Lepomis megalotis" = 2.869)  # #5- 2.869  #8-4.123
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_lepomis, 
  node.ages = nod.age
  )  


# Macrhybopsis -----------------------------------------------------------------

# Macrhybopsis tree from Hoagstrom and echelle 2022
tree_macrhy <- ape::read.nexus(file.path(tree_dir,"Macrhybopsis_hoagstrom_echelle_2022.tre"))

# Format to match data set
tree_macrhy$tip.label[tree_macrhy$tip.label == "G1_Mbosch"] <- 
  "Macrhybopsis boschungi"  
tree_macrhy$tip.label[tree_macrhy$tip.label == "H1_Metnier"] <- 
  "Macrhybopsis etnieri"
tree_macrhy$tip.label[tree_macrhy$tip.label == "F1_Mpall"] <- 
  "Macrhybopsis pallida"
tree_macrhy$tip.label[tree_macrhy$tip.label == "X_MhyoTet"] <- 
  "Macrhybopsis tetranema"

# # Check to see if tree contains all species in data set
# macrhy_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label, 1) == "Macrhybopsis"
#   ]
# tree_backbone_macrhy <- keep.tip(tree_backbone_data,macrhy_names)
# 
# # label nodes to easier determine node ages
# tree_macrhy$node.label <- 1:tree_macrhy$Nnode
# tree_backbone_macrhy$node.label <- 1:tree_backbone_macrhy$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_macrhy, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_macrhy, show.node.label = T,use.edge.length = T)
# 
# # Find tip and node ages
# tree.age(tree_macrhy)
# tree.age(tree_backbone_macrhy)

# Use  Tree from Hoagstrom and Echelle (2022) to add missing tips
data <- data.frame(
  bind = c(
    "Macrhybopsis etnieri-Macrhybopsis pallida",
    "Macrhybopsis tetranema"), 
  reference = c(
    "Macrhybopsis gelida-Macrhybopsis aestivalis",
    "Macrhybopsis gelida"
    ), 
  poly = c(
    F,
    F
    )
  )  
node.age <- c(
  "Macrhybopsis pallida-Macrhybopsis gelida" = 10.148,  #  #9-10.148 #2-3.941 #1-24.505 
   "Macrhybopsis tetranema-Macrhybopsis gelida" = 3.112  #  #13-3.112 #2-3.941
  )
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_macrhy, 
  node.ages = node.age
  )  


# Micropterus ------------------------------------------------------------------

# Micropterus tree from Kim et al., 2022 
tree_micropterus <- ape::read.nexus(file.path(tree_dir,"Micropterus_kim_et_al_2022.tre"))

# Format to match data set
micro_names <- read.csv(
  paste0(
    tree_dir,
    "micropterus_kim_et_al_2022_names.csv"
    )
  )  
tree_micropterus$tip.label <- micro_names$Specimen[
  match(tree_micropterus$tip.label,micro_names$SVDQuartets.taxon)
  ] 

# # Check to see if tree contains all species in data set
# micropterus_species <- species_names[word(species_names,1) == "Micropterus"]
# micropterus_species[!micropterus_species %in% tree_micropterus$tip.label]
# # Contains all species in data set
# 
# micropt_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label, 1) %in% c("Micropterus","Lepomis")
#   ]
# tree_backbone_micro <- keep.tip(tree_backbone_data,micropt_names)
# 
# # label nodes to easier determine node ages
# tree_micropterus$node.label <- 1:tree_micropterus$Nnode
# tree_backbone_micro$node.label <- 1:tree_backbone_micro$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_micropterus, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_micro, show.node.label = T,use.edge.length = T)
# 
# # Find tip and node ages
# tree.age(tree_micropterus)
# tree.age(tree_backbone_micro)

# Replacing entire genus seems to be the best way to preserve the overall 
# tree timing
data <- data.frame(
  bind = c("Micropterus sp. Altamaha Bass-Micropterus nigricans"),  
  reference = c("Micropterus notius"),  
  poly = c(F)
  )  
nod.age <- c("Micropterus sp. Altamaha Bass-Micropterus notius" = 7.386)  # #1-7.386 #1-31.781
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data,
  tree_micropterus,
  node.ages = nod.age
  )


# Poeciliinae ------------------------------------------------------------------

# Poeciliinae tree from TimeTree
tree_poecil <- ape::read.tree(file.path(tree_dir,"timetree_Poeciliinae.nwk")) 

# Format to match data set
tree_poecil$tip.label <- gsub("_", " ", tree_poecil$tip.label)

# # Check to see if tree contains all species in data set
# poecil_species <- species_names[
#   word(species_names,1) %in% 
#     c("Heterandria","Poeciliopsis","Gambusia", "Poecilia")
#   ]
# poecil_species[!poecil_species %in% tree_poecil$tip.label]
# # all species are present
# 
# poecil_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label, 1) == "Poecilia"
#   ]
# tree_backbone_poecil <- keep.tip(tree_backbone_data,poecil_names)
# # label nodes to easier determine node ages
# tree_poecil$node.label <- 1:tree_poecil$Nnode
# tree_backbone_poecil$node.label <- 1:tree_backbone_poecil$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_poecil, show.node.label = T,use.edge.length = F,cex = .6)
# plot.phylo(tree_backbone_poecil,show.node.label = T,use.edge.length = F)
# 
# # Find tip and node ages
# tree.age(tree_poecil)
# tree.age(tree_backbone_poecil)

# Merge trees
data <- data.frame(
  bind = c("Poecilia formosa"),  
  reference = c("Poecilia reticulata-Poecilia wingei"),  
  poly = c(F)
  )  
nod.age <- c("Poecilia formosa-Poecilia reticulata" = 9.34)  # #2-3.838 #1-26.084
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_poecil, 
  node.ages = nod.age
  )  


# Pogonichthyinae --------------------------------------------------------------

#Erimonax, Notropis, and Pteronotropis (TimeTree)
tree_pogo <- ape::read.tree(file.path(tree_dir,"timetree_Pogonichthyinae.nwk"))
tree_pogo$tip.label <- gsub("_", " ", tree_pogo$tip.label)

# # Check to see if tree contains all species in data set
# pogo_species <-species_names[
#   word(species_names,1) == "Erimonax" | 
#     word(species_names,1) == "Notropis" |
#     word(species_names,1) == "Pteronotropis"
#   ]
# pogo_species[!pogo_species %in% tree_pogo$tip.label]
# # All Erimonax species are contained in the tree. Pteronotropis species in 
# # data and backbone tree are in the tree. But one species is missing from both 
# # trees.Notropis is missing some species from the new tree that are in 
# # backbone and data set
# pogo_genus <- unique(
#   word(tree_pogo$tip.label,1)[
#     word(tree_pogo$tip.label,1) %in% word(species_names,1)
#     ]
#   )
# pogo_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% pogo_genus
#   ]
# tree_backbone_pogo <- keep.tip(tree_backbone_data,pogo_names)
# 
# # label nodes to easier determine node ages
# tree_pogo$node.label <- 1:tree_pogo$Nnode
# tree_backbone_pogo$node.label <- 1:tree_backbone_pogo$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_pogo, show.node.label = T,use.edge.length = F, cex=.6)
# plot.phylo(tree_backbone_pogo, show.node.label = T,use.edge.length = F)
# 
# # Find tip and node ages
# tree.age(tree_pogo)
# tree.age(tree_backbone_pogo)

# Merge trees
data <- data.frame(
  bind = c(
    "Erimonax monachus",  # W
    "Notropis alborus",  # W
    "Notropis atrocaudalis", # DW. Pushes nodes below down. may be ok
    "Notropis bairdi",  # W
    "Notropis braytoni",  # W
    "Notropis cummingsae",  # W
    "Notropis greenei",  # DW  Pushes nodes below down. may be ok
    "Notropis melanostomus",  # DW  Pushes nodes below down. may be ok
    "Notropis scabriceps",  # W
    "Pteronotropis merlini" # W For some reason this changes every node in the 
    # tree, no mater what age you give it when poly=T. But can set as false and 
    # use nod ages to create polytomy
    ),
  reference = c(
    "Pimephales promelas-Pimephales vigilax",  
    "Notropis procne",
    "Hybopsis hypsinotus-Luxilus zonistius",  
    "Notropis blennius-Notropis potteri",
    "Notropis bairdi-Notropis blennius",
    "Notropis altipinnis",
    "Lythrurus fasciolaris-Luxilus zonistius",  # 
    "Notropis nubilus-Notropis mekistocholas",
    "Notropis greenei",
    "Pteronotropis metallicus-Pteronotropis euryzonus"
    ),
  poly = c(
    F,
    F,
    F,
    F,
    T,
    F,
    F,
    F,
    F,
    F
    )
  )  
nod.age <- c(
  "Erimonax monachus-Pimephales promelas" = 20.85,  #  #-20.85  #37 - 22.176 #38-17.931  works
  "Notropis alborus-Notropis procne" = 8.77,  # #-8.77 #84-11.519 works!
  "Notropis bairdi-Notropis potteri" = 10.63,  # #-10.63 #51-3.394  #50-12.084 works!
  "Notropis braytoni-Notropis bairdi" = 10.63,  # #51-3.394  #50-12.084 works!
  "Notropis cummingsae-Notropis altipinnis" = 9.94,  # #-9.94 #138-23.683 works!
  "Notropis scabriceps-Notropis greenei" = 19.07,  # #-19.07
  "Pteronotropis merlini-Pteronotropis metallicus" = 6.233)  #  #-6.23  #132-6.233 #131-22.727 

tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_pogo, 
  node.ages = nod.age
  )  


# Cyprinids  -------------------------------------------------------------------

# Campostoma and Notropis (Hollingsworth et al 2013)
tree_cyprinids <- ape::read.tree(file.path(tree_dir,"cyprinids_hollingsworth_et_al_2013.phy")) 

# Format to match data set
tree_cyprinids$tip.label <- gsub("_", " ", tree_cyprinids$tip.label)
tree_cyprinids$tip.label[word(tree_cyprinids$tip.label,1) == "Campostoma"]
species_names[word(species_names,1) == "Campostoma"]
tree_cyprinids$tip.label[
  tree_cyprinids$tip.label == "Campostoma sapadiceum"
  ] <- "Campostoma spadiceum"

# # Check to see if tree contains all species in data set
# # only one species in genus,
# cyp_genus <- unique(
#   word(tree_cyprinids$tip.label,1)[
#     word(tree_cyprinids$tip.label,1) %in% word(species_names,1)
#     ]
#   )
# cyp_names <- tree_backbone_data$tip.label[
#   word(tree_backbone_data$tip.label,1) %in% cyp_genus
#   ]
# tree_backbone_cyp <- keep.tip(tree_backbone_data,cyp_names)
# # label nodes to easier determine node ages
# tree_cyprinids$node.label <- 1:tree_cyprinids$Nnode
# tree_backbone_cyp$node.label <- 1:tree_backbone_cyp$Nnode
# 
# # Tree is large so trim to find node ages
# tree_cyprinids_camp <- keep.tip(
#   tree_cyprinids,
#   tree_cyprinids$tip.label[word(tree_cyprinids$tip.label,1)=="Campostoma"]
#   )
# tree_cyprinids_notr <- keep.tip(
#   tree_cyprinids,
#   tree_cyprinids$tip.label[word(tree_cyprinids$tip.label,1)=="Notropis"]
#   )
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_cyprinids, show.node.label = T,use.edge.length = F,cex = .6)
# plot.phylo(tree_backbone_cyp, show.node.label = T,use.edge.length = F)
# 
# # Find tip and node ages
# tree.age(tree_cyprinids)
# tree.age(tree_backbone_cyp)

# Merge trees
data <- data.frame(
  bind = c(
    "Campostoma spadiceum-Campostoma pauciradii", # Add entire genus to tree
    "Notropis amplamala"
    ),
  reference = c(
    "Nocomis asper-Nocomis raneyi",
    "Notropis buccatus"
    ),
  poly = c(
    F,
    F
    )
  )  
nod.age <- c(
  "Campostoma spadiceum-Nocomis raneyi" = 32.608, # 195-30.542 156-32.608. 
             "Notropis amplamala-Notropis buccatus" =11.616)  # #52-11.616 #106-20.465 works
tree_backbone_data <- tree.merger(
  tree_backbone_data, 
  data, 
  tree_cyprinids, 
  node.ages = nod.age
  )  


# Unavailable trees ------------------------------------------------------------

# Species from trees that are not acquired can be added using tree.merger but
# will not have control of node ages. This can only be used to add ind tips not
# full genus.
# For these trees in manuscripts show relationships and these species will 
# be added


### Cottus ###

# Use graphical Tree from Kiniger et al. 2005 to add missing tips
data <- data.frame(
  bind = c(
    "Cottus kanawhae",
    "Cottus sp. Bluestone Sculpin",
    "Cottus sp. Checkered Sculpin",
    "Cottus sp. Clinch Sculpin",
    "Cottus sp. Holston Sculpin"
    ),  
  reference = c(
    "Cottus baileyi-Cottus carolinae",
    "Cottus kanawhae",
    "Cottus girardi",
    "Cottus baileyi-Cottus paulus",
    "Cottus carolinae"
    ),  
  poly = c(
    F,
    F,
    F,
    T,
    F))  
tree_backbone_data <- tree.merger(tree_backbone_data, data)  


### Etheostoma ###

# Use graphical Tree from Laymen and Mayden 2012 to add missing tips
data <- data.frame(
  bind = c("Etheostoma gore"),  
  reference = c("Etheostoma jimmycarter-Etheostoma teddyroosevelt"),  
  poly = c(F)
  )  
tree_backbone_data <- tree.merger(tree_backbone_data, data)  


### Notropis ###

# Use graphical Tree from Hollingsworth et al. (2013) to add missing tips.
data <- data.frame(
  bind = c("Notropis sp. Sawfin Shiner"),  
  reference = c("Notropis spectrunculus"),  
  poly = c(F)
  )  
tree_backbone_data <- tree.merger(tree_backbone_data, data)  


### Pteronotropis ###

# Use graphical Tree from Mayden and Allen (2015) to add missing tips
data <- data.frame(
  bind = c("Pteronotropis stonei"),  
  reference = c("Pteronotropis metallicus"),  
  poly = c(F)
  )  
tree_backbone_data <- tree.merger(tree_backbone_data, data)  


### Cyprinella ###

# Use graphical Tree from Schonhuth and Mayden (2010) to add missing tips
data <- data.frame(
  bind = c("Cyprinella sp. Thinlip Chub"),  
  reference = c("Cyprinella zanema"),  
  poly = c(F)
  )  
tree_backbone_data <- tree.merger(tree_backbone_data, data)  


# No trees Found ---------------------------------------------------------------

# Some species were not included in any phylogenetic analyses that I was able  
# to retrieve. These species were often provisional, newly described, or 
# rare species. These species were added as sisters to closest related species 
# based on research.These will be divided into Provisional Species and
#  Described Species


### Provisional Species ###
# If a provisional species does not have phylogenetic information, it will 
# be assigned as a sister species to the species it is described after. For 
# example: Clinostomus sp. cf. funduloides would be added as a sister to 
# Clinostomus funduloides.
data <- data.frame(
  bind = c(
    "Clinostomus sp. Smoky Dace",  # Clinostomus sp. cf. funduloides
    "Cottus sp. Colorado River Sculpin",  # Young et al. 2022 called this 
    # similar to Cottus beldingii
    "Cottus sp. Columbia Slimy Sculpin",  # Cottus sp. cf. cognatus
    "Cottus sp. Rocky Mountain Sculpin",  # Cottus sp. cf. bairdii
    "Moxostoma sp. Carolina Redhorse",  # Moxostoma sp. cf. erythrurum
    "Notropis sp. Kanawha Rosyface Shiner",  # Notropis sp. Cf. rubellus
    "Notropis sp. Piedmont Shiner",  # Notropis sp. Cf. chlorocephalus
    "Noturus sp. Highlands Stonecat"  # Noturus sp. cf. flavus
    ),
  reference = c(
    "Clinostomus funduloides",
    "Cottus beldingii",
    "Cottus cognatus",
    "Cottus bairdii",
    "Moxostoma erythrurum",
    "Notropis rubellus",
    "Notropis chlorocephalus",
    "Noturus flavus"
    ),  
  poly = c(
    F,
    F,
    F,
    F,
    F,
    F,
    F,
    F
    )
  )  
tree_backbone_data <- tree.merger(tree_backbone_data, data)


# Described Species ------------------------------------------------------------

# described species that do not have phylogenetic data fit into the following 
# groups: former subspecies, new species, and rare species. In the case of 
# former subspecies, these are assigned as sisters to their former subspecies. 
# Rare and new species are added as sisters to closest related species based on 
# literature

data <- data.frame(
  bind = c(
    "Catostomus utawana",  # was formerly considered part of Catostomus 
    # commersonii. (Morse and Daniels 2009)
    "Cottus immaculatus",  # was once part of Cottus hypselurus (Kinziger and 
    # Wood 2010)
    "Macrhybopsis australis",  # sister species to Macrhybopsis tetranema 
    # (Underwood et al. 2003; Eisenhour 2004).
    "Margariscus nachtriebi",  # genus has only two species, add sister to 
    # other conger Margariscus margarita  
    "Menidia audens",  # There is a debate if this is part of Menidia beryllina 
    # or its own speceis (Fluker et al. 2011; Suttkus et al 2005)
    "Notropis albizonatus",  # A member of the Notropis procne species group 
    # (Warren et al. 1994) has likely relatedness. Not much else on this species
    "Notropis buccula",  # Originally a subspecies of (Lee et al. 1980; Robins 
    # et al. 1991; Page and Burr 1991, 2011).
    "Oncorhynchus aguabonita"  # debated as subspecies of Oncorhynchus mykiss
    ),  
  reference = c(
    "Catostomus commersonii",
    "Cottus hypselurus",
    "Macrhybopsis tetranema",  # added from Machybopsis tree
    "Margariscus margarita",
    "Menidia beryllina",
    "Notropis procne",
    "Notropis bairdi",  # added from Pogonichthyinae tree
    "Oncorhynchus mykiss"
    ), 
  poly = c(
    F,
    F,
    F,
    F,
    F,
    F,
    F,
    F
    )
  )
tree_backbone_data <- tree.merger(tree_backbone_data,data)


# Lampreys ---------------------------------------------------------------------

# Lamorey species are contained in a time tree from time tree. Fish tree of life
# back bone only contains boney fish, so this tree will need to be added to the
# lamprey tree

# lamprey tree from TimeTree
tree_lamp <- ape::read.tree(file.path(tree_dir,"timetree_Petromyzontiformes.nwk"))  

# Format name to match data set
tree_lamp$tip.label <- gsub("_", " ", tree_lamp$tip.label)
tree_lamp$tip.label[tree_lamp$tip.label == "Lampetra appendix"] <- 
  "Lethenteron appendix"  # same fish just named different between data sets
tree_lamp$tip.label[tree_lamp$tip.label == "Entosphenus hubbsi"] <- 
  "Lampetra hubbsi"  # same fish just named different between data sets

# # Check to see if tree contains all species in data set
# lamp_names <- species_names[
#   word(species_names,1) %in%
#     c("Ichthyomyzon", "Lampetra","Lethenteron", "Petromyzon")
#   ]
# lamp_names[!lamp_names %in% tree_lamp$tip.label]
# # all species in data set are in new tree
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(
#   tree_lamp, 
#   show.node.label = T,
#   use.edge.length = F)
# plot.phylo(
#   tree_backbone_data, 
#   show.node.label = F,
#   use.edge.length = F, 
#   cex = .4
#   )

# Merge trees
data <- data.frame(
  bind = c("Polyodon spathula-Gambusia affinis"),  
  reference = c("Mesomyzon mengae-Mordacia mordax"),  
  poly = c(F))  
nod.age <- c("Mesomyzon mengae-Polyodon spathula" = 563.4)  # age of nodes as 
# derived from timetree
tree_final <- tree.merger(
  tree_lamp, 
  data,tree_backbone_data, 
  node.ages = nod.age
  )


# Export tree  -----------------------------------------------------------------

# retain only species from data set
tree_trim <- keep.tip(tree_final, species_names) 
ape::write.nexus(tree_trim,"phylo_tree.nex")  # export as nex file
saveRDS(tree_trim,"phylo_tree.rds")  # export as rds file

