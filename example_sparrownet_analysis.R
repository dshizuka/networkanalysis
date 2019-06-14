## code for worked example: analyzing sparrow flock networks across years

library(tidyr) 
library(asnipe)
library(igraph)



flock2=read.csv('https://datadryad.org/bitstream/handle/10255/dryad.63925/Flock_Season2_Dryad.csv')
flock3=read.csv('https://datadryad.org/bitstream/handle/10255/dryad.63926/Flock_Season3_Dryad.csv')
head(flock2)

flock.list=list(flock2, flock3)

bird.ids=lapply(flock.list, function(x) {
  birdcols=grep("Bird",colnames(x))
  ids=unique(gather(x[,birdcols])$value)
  as.character(ids[is.na(ids)==F&ids!=""&ids!=" "])
})

bird.ids


m.list=lapply(flock.list, function(x) {
  birdcols=grep("Bird",colnames(x))
  ids=unique(gather(x[,birdcols])$value)
  ids=ids[is.na(ids)==F&ids!=""&ids!=" "]
  m1=apply(x[,birdcols],1,function(y) match(ids,y))
  m1[is.na(m1)]=0
  m1[m1>0]=1
  rownames(m1)=ids #rows are bird ids
  colnames(m1)=paste('flock', 1:ncol(m1), sep="_") #columns are flock IDs (just "flock_#")
  m2=m1[which(rowSums(m1)>3),]
  m2
})

adjs=lapply(m.list, function(x) get_network(t(x), data_format="GBI", association_index = "SRI")) # the adjacency matrix
gs=lapply(adjs, function(x) graph_from_adjacency_matrix(x, "undirected", weighted=T))#the igraph object

gs

seasons=c("Season 2", "Season 3") # save for plot title 
default=par() #save default graphical parameters first 
par(mfrow=c(1,2)) #set up to plot networks side-by-side 
for(i in 1:2){
plot(gs[[i]], edge.width=E(gs[[i]])$weight*10, vertex.label="", vertex.color="gold1", vertex.size=10,edge.color="gray10", main=paste(seasons[i]))
}
par(default)

coms=lapply(gs, function(x) cluster_fast_greedy(x)) #apply community detection function to each network
mods=sapply(coms, modularity) #calculate modularity based on community assignments
com.colors=list(c("blue", "yellow", "green", "red"), c("green", "blue", "red", "yellow")) # assign colors to communities. Community colors are in different order for each year because community ID number depends on the order of nodes that belong to them.
set.seed(10) #make plots reproducible 
par(mfrow=c(1,2))
for(i in 1:2){ 
  l=layout_with_fr(gs[[i]])
  V(gs[[i]])$color=com.colors[[i]][membership(coms[[i]])]
  plot(gs[[i]], layout=l, edge.width=E(gs[[i]])$weight*10, vertex.label="", vertex.size=10,edge.color="gray10", main=paste(seasons[i], ": Modularity=", round(mods[[i]], 2)))
}
par(default)

gbi=t(m.list[[1]]) 
swap.m=list() 
times=100
for (k in 1:times){
  swap.m[[k]]=network_swap(gbi, swaps=500)$Association_index }

swap.g=lapply(swap.m, function(x) graph_from_adjacency_matrix(x, "undirected", weighted=T)) 
mod.swap=sapply(swap.g, function(x) modularity(cluster_fast_greedy(x)))
hist(mod.swap, xlim=c(min(mod.swap), mods[[1]]))
abline(v=mods[[1]], col="red", lty=2, lwd=2) 
p=(length(which(mod.swap>=mods[[1]]))+1)/(times+1)
p