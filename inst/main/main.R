# 13.10.2021
# The folllowing script is used to construct food web from various open access sources

library(dplyr)
library(stringr)


##### For Benguela Pelagic ####
##### For Broadstone Stream ##### 
##### For Broom ##### 
#### For Caricaie Lakes ##### 
#### For Grasslands ##### 
#### For Mill Stream ##### 
#### For Sierra Lakes ##### 
#### For Skipwith Pond ##### 
#### For Tuesday Lake ##### 

source("R/standard.food.web.functions.r")
brose.data = read.delim(file = url("https://figshare.com/ndownloader/files/5595854"),
                        as.is=T,
                        #na.strings = "-999",
                        strip.white = TRUE) %>%
  mutate(Link.reference = str_sub(Link.reference, 1, 33))


## make adjustments
#brose.data <- brose.data[,1:31]
#brose.data[brose.data[,10]=="larvae ",10] = "larvae"
#brose.data[brose.data[,21]=="larvae ",21] = "larvae"

## write link.references to file
all.link.references <- unique(brose.data$Link.reference)
##write(all.link.references, file="all.link.references.txt")

mass.webs <- c(1, 2, 4, 8)##. Others have all lengths.

names(brose.data)

con_mass_col_num <- which(names(brose.data)=="Mean.mass..g..consumer")
res_mass_col_num <- which(names(brose.data)=="Mean.mass..g..resource")
con_length_col_num <- which(names(brose.data)=="Mean.length..m..consumer")
res_length_col_num <- which(names(brose.data)=="Mean.length..m..resource")


## give webs that will be analysed
use.these <- data.frame(web.id=c(1, 2, 3, 10, 11, 12, 14, 15, 16, 19),
                        web.name=c("Benguela Pelagic",
                                   "Broadstone Stream",
                                   "Skipwith Pond",
                                   "Tuesday Lake",
                                   "Broom",
                                   "Sierra Lakes",
                                   "Mill Stream",
                                   "Caricaie Lakes",
                                   "Grasslands",
                                   "Weddell Sea"),
                        c.size.column = c(con_mass_col_num,
                                          con_mass_col_num,
                                          con_length_col_num,
                                          con_mass_col_num,
                                          con_length_col_num,
                                          con_length_col_num,
                                          con_length_col_num,
                                          con_mass_col_num,
                                          con_length_col_num,
                                          con_length_col_num),
                        r.size.column = c(res_mass_col_num,
                                          res_mass_col_num,
                                          res_length_col_num,
                                          res_mass_col_num,
                                          res_length_col_num,
                                          res_length_col_num,
                                          res_length_col_num,
                                          res_mass_col_num,
                                          res_length_col_num,
                                          res_length_col_num))


#c.size.column=rep(con_size_col_num,10),
#r.size.column=rep(res_size_col_num,10)

#c.size.column=c(32, 32, 15, 32, 15, 15, 15, 32, 15, 15),
#r.size.column=c(33, 33, 25, 33, 25, 25, 25, 33, 25, 25))

#c.size.column=c(32, 32, 32, 32, 32, 32, 32, 32, 32, 32),
#r.size.column=c(33, 33, 33, 33, 33, 33, 33, 33, 33, 33))

## the webs used are identified by their Link.reference
use.these <- transform(use.these, refs=unique(brose.data$Link.reference)[use.these[,1]])

use.these <- use.these[-10,]
## only keep the data that will be analysed
brose.data <- brose.data[!is.na(match(brose.data$Link.reference, use.these$refs)),]

web.info <- list()
## get web info
for(i in 1:length(use.these[,1])){
  
  web.data <- brose.data[brose.data$Link.reference==unique(brose.data$Link.reference)[i],]
  
  link.ref = unique(web.data$Link.reference)
  lab1 = rep("link.ref", length(link.ref))
  
  size.ref = unique(web.data$Body.size.reference)
  lab2 = rep("size.ref", length(size.ref))
  location = unique(web.data$Geographic.location)
  lab3 = rep("location", length(location))
  g.hab = unique(web.data$General.habitat)
  lab4 = rep("g.hab", length(g.hab))
  s.hab = unique(web.data$Specific.habitat)
  lab5 = rep("s.hab", length(s.hab))
  link.method = unique(web.data$Link.method)
  lab6 = rep("link.method", length(link.method))
  size.method = unique(web.data$Body.size.method)
  lab7 = rep("size.method", length(size.method))
  
  web.info[[i]] = c(link.ref, size.ref, location, g.hab, s.hab, link.method, size.method)
  names(web.info[[i]]) <- c(lab1, lab2, lab3, lab4, lab5, lab6, lab7)
  
}


species.masses <- list()
species.met.cat <- list()
feeding.interaction <- list()
web <- list()
for(i in 1:length(use.these[,1])){
  
  web.data <- brose.data[brose.data$Link.reference==unique(brose.data$Link.reference)[i],]
  
  if(i==8)
    web.data <- web.data[web.data$Specific.habitat=="Grand Caricaie; marsh dominated by Schoenus nigricans, mown; Scmown2;",]    
  
  ## Type.of.feeding.interaction
  ##web.data$Type.of.feeding.interaction
  
  ## use consumer common name as name
  if(sum(web.data[,11]==-999)==0)
    c.column = 11
  ## use consumer taxonomy as name
  if(sum(web.data[,9]==-999)==0)
    c.column = 9
  
  ## use common name as name
  if(sum(web.data[,22]==-999)==0)
    r.column = 22
  ## use taxonomy as name
  if(sum(web.data[,20]==-999)==0)
    r.column = 20
  
  ## don't use lifestage
  if(length(unique(web.data[,10]))==1 &  length(unique(web.data[,21]))==1){
    consumer.name = as.character(web.data[,c.column])
    resource.name = as.character(web.data[,r.column])
  }
  ## use lifestage
  if(length(unique(web.data[,10]))!=1 |  length(unique(web.data[,21]))!=1){
    consumer.name = as.character(paste(web.data[,10], web.data[,c.column]))            
    resource.name = as.character(paste(web.data[,21], web.data[,r.column]))
  }
  
  ## use everything as name
  consumer.name = as.character(paste(web.data[,9], web.data[,10], web.data[,11]))
  resource.name = as.character(paste(web.data[,20], web.data[,21], web.data[,22]))
  
  ## all species names
  species <- unique(c(consumer.name, resource.name))
  
  ## get species' masses
  species.masses[[i]] <- rbind(data.frame(species=consumer.name, mass=web.data[,use.these[i,3]]),
                               data.frame(species=resource.name, mass=web.data[,use.these[i,4]]))   
  
  ## get species' metabolic categories
  species.met.cat[[i]] <- rbind(data.frame(species=consumer.name, Met.cat= web.data$Metabolic.category.consumer),
                                data.frame(species=resource.name, Met.cat=web.data$Metabolic.category.consumer))   
  species.met.cat[[i]] <- aggregate(species.met.cat[[i]][,2], list(species=species.met.cat[[i]][,1]), function(x) x[1])
  species.met.cat[[i]] <- species.met.cat[[i]][order(species.met.cat[[i]][,1]),]
  
  ## some names are have multiple masses: take mean
  species.masses[[i]] <- aggregate(species.masses[[i]][,2], list(species=species.masses[[i]][,1]), function(x) mean(x))
  
  ## make matrix form web
  web[[i]] = List.to.matrix(cbind(consumer.name, resource.name), predator.first=TRUE)
  
  
  ## sort the web matrix by size
  species.masses[[i]] = species.masses[[i]][order(species.masses[[i]][,1]),]
  web[[i]] = web[[i]][order(dimnames(web[[i]])[[1]]), order(dimnames(web[[i]])[[1]])]
  web[[i]] = web[[i]][order(species.masses[[i]][,2]), order(species.masses[[i]][,2])]
  species.masses[[i]]  = species.masses[[i]][order(species.masses[[i]][,2]),]
  
  ## and sort met.cats by size
  species.met.cat[[i]] <- species.met.cat[[i]][order(species.masses[[i]][order(species.masses[[i]][,1]),][,2]),]
  
  ## check for zero masses
  ##write.table(web.data[web.data[,use.these[i,4]]==0 | web.data[,use.these[i,3]]==0,],
  ##      file=paste("zero.mass", use.these[i,2], ".txt", sep="."), sep="\t", quote=F)
  
  
  ## keep type of feeding interaction
  ## Tuesday lake contains multiple records of the same resource consumer pair, get rid of these for the purpose of recording feeding interactions
  feeding.interaction[[i]] <- cbind(consumer.name, resource.name, web.data$Type.of.feeding.interaction)
  feeding.interaction[[i]] <- feeding.interaction[[i]][!duplicated(paste(consumer.name, resource.name)),]
  
  ## For Sierra Lakes, remove the non adult trout species
  if(i==6){
    rm.these1 <- grep("trout", species.masses[[i]][,1])
    
    rm.these2 <- grep("adult", species.masses[[i]][,1])
    rm.these <- rm.these1[is.na(match(rm.these1, rm.these2))]
    species.masses[[i]] <- species.masses[[i]][-rm.these,]
    species.met.cat[[i]] <- species.met.cat[[i]][-rm.these,]
    web[[i]] <- web[[i]][-rm.these,-rm.these]
    
    rm.these1 <- grep("trout", feeding.interaction[[i]][,1])
    rm.these2 <- grep("adult", feeding.interaction[[i]][,1])
    rm.these <- rm.these1[is.na(match(rm.these1, rm.these2))]
    rm.these3 <- grep("trout", feeding.interaction[[i]][,2])
    rm.these4 <- grep("adult", feeding.interaction[[i]][,2])
    rm.these <- rm.these3[is.na(match(rm.these3, rm.these4))]
    feeding.interaction[[i]] <- feeding.interaction[[i]][-rm.these,]
    
  }
  
  
  
}


for(i in 1:length(web)){
  web.info[[i]] <- c(web.info[[i]], round(Get.web.stats(web[[i]], which.stats=0), 2))
  ##write(web.info[[i]], file=paste(use.these[i,2], ".info.txt", sep=""))
}

pdf("data/predation_matrices.pdf", width=12, height=8,
    paper = "a4r")
layout(matrix(1:10, 2, 5, byrow=T), respect=T)
for(i in 1:length(use.these[,1])){
  Plot.matrix(web[[i]], title=as.character(use.these[i,2]))
  S = as.numeric(web.info[[i]]["S"])
  L = as.numeric(web.info[[i]]["L"])
  C = as.numeric(web.info[[i]]["C"])
  mtext(side=1, text=paste("S = ", S,
                           "L = ", L,
                           "C = ", C, sep="; "))
}
dev.off()
web.info1 <- use.these
web.info2 <- web.info
web.matrix <- web

remove.these.objects <- ls()[is.na(match(ls(), c("web.info1", "web.info2", "web.matrix", "species.masses", "species.met.cat", "feeding.interaction")))]
rm(list=remove.these.objects)
for(i in 1:9){
  ## next line is true if we have the length of all species in the web
  if(sum(!is.na(species.masses[[i]][,2]))==length(species.masses[[i]][,2]))
    size.unit <- "length"
  all.web.info <- list(web.name=as.character(web.info1[i,2]),
                       species.names=as.character(species.masses[[i]][,1]),
                       species.sizes=species.masses[[i]][,2],
                       species.met.cat=species.met.cat[[i]][,2],
                       feeding.interaction=feeding.interaction[[i]],
                       species.abundance=NA,
                       predation.matrix=web.matrix[[i]])
  ##setwd(paste(path, "data\\by.webs", web.info1[i,2], sep="//"))    
  #setwd(paste("~/work/research/4.in.review/allometric.web/data/by.webs/all.species", web.info1[i,2], sep="/"))    
  saveRDS(all.web.info, file=paste("data/", as.character(web.info1[i,2]), ".web.RDS", sep=""))    
}


##### For Ythan food web ##### 
library(rdryad)
library(janitor)
library(tidyverse)

doi_cirtwill_eklof <- "10.5061/dryad.1mv20r6"
dd <- dryad_download(doi_cirtwill_eklof)
temp = dd$`10.5061/dryad.1mv20r6`[grep(pattern="*.csv", dd$`10.5061/dryad.1mv20r6`)]
all_species_data = read.csv2(temp[1])
this_network1 <- "ythanjacob"
if(this_network1 == "ythanjacob") this_network2 <- "ythan_spnames.csv"

## WARNING: this code assumes the supplied food web matrix has columns and rows
## sorted in the same order

## WARNING: some of the cleaning of species names was only designed for one food web (Ythan)

fw <- read.csv(temp[grep(this_network2, temp)]) %>%
  clean_names() %>%
  select(-1)
rownames(fw) <- colnames(fw)
sp <- all_species_data %>%
  filter(Network == this_network1) %>%
  mutate(sp_names = tolower(Species),
         sp_names = str_replace_all(sp_names, " ", "_"),
         sp_names = str_replace_all(sp_names, "\\.", ""),
         sp_names = str_replace_all(sp_names, "\\(", ""),
         sp_names = str_replace_all(sp_names, "\\)", ""),
         sp_names = str_replace_all(sp_names, "/", "_"),
         BodyWeight = parse_double(BodyWeight))


## Arrange the species by body mass and remove NULLs
sp <- sp %>%
  arrange(BodyWeight) %>%
  filter(BodyWeight != "NULL")

## Species in the food web matrix but not in the species data
#rownames(fw)[!(rownames(fw) %in%  sp$sp_names)]

## Species in the food web matrix but not in the species data
#sp$sp_names[!(sp$sp_names %in%  rownames(fw))]

## Remove species from the food web that are not in the species data
fw <- fw[(rownames(fw) %in%  sp$sp_names),(rownames(fw) %in%  sp$sp_names)]

## Order food web by body weight
fw <- fw[sp$sp_names, sp$sp_names]

## Arrange data for fitting
ythandryad.all.web.info <- list()
ythandryad.all.web.info$predation.matrix <- as.matrix(fw)
ythandryad.all.web.info$species.sizes <- sp$BodyWeight


all.web.info_ythan <- list(web.name="Ythan",
                           species.names=names(ythandryad.all.web.info$predation.matrix),
                           species.sizes=as.numeric(ythandryad.all.web.info$species.sizes),
                           species.met.cat=NA,
                           feeding.interaction=NA,
                           species.abundance=NA,
                           predation.matrix=ythandryad.all.web.info$predation.matrix)

saveRDS(all.web.info_ythan, file=paste("data/", "Ythan", ".web.RDS", sep=""))


##### For Capinteria ##### 

library(R.utils)
library(stringr)

link_all <- read.delim(file = url("https://esapubs.org/archive/ecol/E092/066/CSMweb_Links.txt"))
node_all <- read.delim(file = url("https://esapubs.org/archive/ecol/E092/066/CSMweb_Nodes.txt"))

## Removing parasitism
## "Concurrent predation on symbionts might not represent energetically significant resources for a 
## predator and therefore are not relevant for estimating node trophic level or food web robustness 
## (Lafferty, Hechinger, et al. 2006; Lafferty and Kuris 2009)."

link_all <- link_all %>%
  filter(str_detect(LinkType, "predation")) %>%
  filter(LinkType != "micropredation") %>%
  filter(LinkType != "concurrent predation on symbionts")
 
species_to_keep <- unique(c(link_all$ResourceSpeciesID.StageID, link_all$ConsumerSpeciesID.StageID))

node_all <- node_all %>%
  filter(SpeciesID.StageID %in% species_to_keep) %>%
  filter(Stage == "adult")

## Arrange the species by body mass and remove NULLs
node_all <- node_all %>%
  arrange(BodySize.g.) %>%
  filter(!is.na(BodySize.g.))

species_bs <- node_all %>%
  group_by(SpeciesID.StageID) %>%
  summarise(SpeciesID.StageID = SpeciesID.StageID, BodySize.g. = mean(BodySize.g.)) %>%
  arrange(BodySize.g.)


n_species <- length(species_bs$SpeciesID.StageID)
pred_mat <- matrix(data = 0, nrow = n_species, ncol = n_species)

rownames(pred_mat) <- species_bs$SpeciesID.StageID
colnames(pred_mat) <- species_bs$SpeciesID.StageID

bs_data <- link_all %>%
  filter(ResourceSpeciesID.StageID %in% species_bs$SpeciesID.StageID & ConsumerSpeciesID.StageID %in% species_bs$SpeciesID.StageID)

nrow_data <- dim(bs_data)[1]

for(i in 1:nrow_data){
  
  row_data <- bs_data[i,]
  
  predator_name <- as.character(row_data$ConsumerSpeciesID.StageID)
  prey_name <- as.character(row_data$ResourceSpeciesID.StageID)
  
  pred_mat[prey_name, predator_name] <- 1
}


# lt_pred_mat <- pred_mat
# lt_pred_mat[upper.tri(lt_pred_mat)] <- 0
# 
# Plot.matrix(lt_pred_mat)
# colSums(lt_pred_mat)

all.web.info_capinteria <- list(web.name="Capinteria",
                                species.names=NA,
                                species.sizes=species_bs$BodySize.g.,
                                species.met.cat=NA,
                                feeding.interaction=NA,
                                species.abundance=NA,
                                predation.matrix=pred_mat)

# saveRDS(all.web.info_capinteria, file=paste("data/", "Capinteria", ".web.RDS", sep=""))


##### For Small Reef ##### 

library(readxl)

doi_small_reef <- "10.5061/dryad.1mv20r6"
dd <- dryad_download(doi_small_reef)

full_data <- read.csv(paste0(dd$`10.5061/dryad.1mv20r6`[1]), sep=";")
reef_spnames <- read_excel(paste0(dd$`10.5061/dryad.1mv20r6`[7]))


sr <- full_data %>%
  filter(Network == "reef")

N <- dim(reef_spnames)[1]
raw_pred_mat <- as.matrix(reef_spnames[,2:(N+1)])
rownames(raw_pred_mat) <- colnames(raw_pred_mat)

sr$BodyWeight <- as.numeric(sr$BodyWeight)

sr <- sr %>%
  arrange(BodyWeight) %>%
  filter(!is.na(BodyWeight))

pred_mat <- raw_pred_mat[sr$Species, sr$Species]


all.web.info_small_reef <- list(web.name="Small Reef",
                                species.names=rownames(pred_mat),
                                species.sizes=sr$BodyWeight,
                                species.met.cat=NA,
                                feeding.interaction=NA,
                                species.abundance=NA,
                                predation.matrix=pred_mat)

# saveRDS(all.web.info_small_reef, file=paste("data/", "Small Reef", ".web.RDS", sep=""))



##### For Broadstone Stream (size aggregation) version ##### 


library(zen4R)

df <- download_zenodo(doi = "10.5281/zenodo.5575039", path = "data")

data_files <- c("1Woodward Feb.csv", "2Woodward Apr.csv", "3Woodward June.csv",
                "4Woodward Aug.csv", "5Woodward Dec.csv", "6Woodward Oct.csv")

n_node <- 29

pred_ind <- c()
max_size <- numeric(1)
min_size <- numeric(1)
n_sample_m <- length(data_files)
new_links <- numeric(n_sample_m)
for(f in data_files){
  month_data <- read.csv(paste("data/",f, sep = ""))
  
  # Where necessary rename Ceratopogonidae to Bezzia (same for Ceratopogonidae.1 to Bezzia.1)
  colnames(month_data)[which(colnames(month_data) == "Ceratopogonidae")] = "Bezzia"
  colnames(month_data)[which(colnames(month_data) == "Ceratopogonidae.1")] = "Bezzia.1"
  month_data <- select(month_data, -which(colnames(month_data) == "Bezzia"))
  month_data <- select(month_data, -which(colnames(month_data) == "Platambus"))
  
  pred_ind <- c(pred_ind, month_data$Individual.code)
  min_size <- min(min_size, min(month_data$Log.predator.mass, month_data$Log.prey.mass))
  max_size <- max(max_size, max(month_data$Log.predator.mass, month_data$Log.prey.mass))
}


h <- (max_size-min_size)/n_node

mass_to_ind <- function(mass){
  index <- ceiling((mass-min_size)/h)
  if(index == 0) {index = 1}
  return(index)
}

uniq_ind <- unique(pred_ind)

n_pred_ind <- length(uniq_ind)

#The first row of the diet_mat corresponds to the predator identity denoted by a unique number and second row consists of bin number
diet_mat <- matrix(data = 0, nrow = n_node+2, ncol = n_pred_ind,)
diet_mat[1,] <- c(1:n_pred_ind)
i <- 1 
for(f in data_files){
  dirnam <- "data"
  fname <- paste(c(dirnam, "/", f), collapse = "")
  month_data <- read.csv(fname)
  
  # Where necessary rename Ceratopogonidae to Bezzia (same for Ceratopogonidae.1 to Bezzia.1)
  colnames(month_data)[which(colnames(month_data) == "Ceratopogonidae")] = "Bezzia"
  colnames(month_data)[which(colnames(month_data) == "Ceratopogonidae.1")] = "Bezzia.1"
  month_data <- select(month_data, -which(colnames(month_data) == "Bezzia"))
  month_data <- select(month_data, -which(colnames(month_data) == "Platambus"))
  
  month_data_f <- select(month_data, c(5,7, 13:40, 79, 80))
  
  for(row_no in 1:nrow(month_data_f)){
    mt <- select(month_data_f[row_no,], c(3:30))
    if(is.na(month_data_f$Individual.code[row_no]) == FALSE){
      pseudo_pred_ind <- which(uniq_ind == month_data_f$Individual.code[row_no])
    }
    
    if(as.numeric(rowSums(mt)) == 1 & is.na(month_data_f$Individual.code[row_no]) == FALSE){
      prey_mass <- month_data_f$Log.prey.mass[row_no]
      prey_name <- mass_to_ind(prey_mass)
      
      pred_mass <- month_data_f$Log.predator.mass[row_no]
      pred_name <- mass_to_ind(pred_mass)
      
      pred_ind <- month_data_f$Individual.code[row_no]
      pseudo_pred_ind <- which(uniq_ind == pred_ind) 
      
      if(length(diet_mat[prey_name+1,pseudo_pred_ind]) != 1)
      {
        print("yu")
        print(prey_mass)
        print(prey_name)
      }
      
      if(diet_mat[prey_name+2, pseudo_pred_ind] == 0){
        new_links[i] <- new_links[i] + 1
        # print(new_links[i])
        diet_mat[prey_name+2, pseudo_pred_ind] <- 1
        diet_mat[1, pseudo_pred_ind] <- month_data_f$Log.predator.mass[row_no]
        diet_mat[2, pseudo_pred_ind] <- pred_name
      }
      
    }
    
  }
  i <- i + 1
}

#Removing columns with empty diet (no predators)
zero_pred <- which(diet_mat[2,] == 0)
diet_mat <- diet_mat[,-zero_pred]

pred_mat <- matrix(data = 0, nrow = n_node, ncol = n_node)
sp_ind <- unique(diet_mat[2,])
sp_ind <- sort(sp_ind)
for(ind in sp_ind){
  local_ind <- which(diet_mat[2,] == ind)
  if(length(local_ind) > 1){
    sum_ind <- rowSums(diet_mat[,local_ind])[3:(n_node+2)]
    sum_ind[which(sum_ind > 0)] = 1
    pred_mat[,ind] <- sum_ind
  }
  else
  {
    sum_ind <- diet_mat[,local_ind][3:(n_node+2)]
    pred_mat[,ind] <- sum_ind
  }
  
}


#Saving the predation matrix
species.sizes <- 10^(min_size + h*c(1:29) - 0.5*h)
predation.matrix <- pred_mat
web.name <- "Broadstone Stream size_agg"
fw_data <- list(predation.matrix = predation.matrix,
                species.sizes = species.sizes,
                web.name = web.name)
saveRDS(fw_data, file = "data/Broadstone Stream size_agg.web.RDS")


