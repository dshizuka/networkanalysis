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


gbi2=t(m.list[[1]])
assoc2=get_network(gbi2)
net.perm=network_permutation(gbi2, permutations=10000, returns=1, association_matrix = assoc2)
swap.g2=apply(net.perm, 1, function(x) graph_from_adjacency_matrix(x,"undirected", weighted=T))
mod.swap2=sapply(swap.g2, function(x) modularity(cluster_fast_greedy(x))) 
hist(mod.swap2,xlim=c(min(mod.swap2), mods[[1]]), main="Serial Method") 
abline(v=mods[[1]], col="red", lty=2, lwd=2) 
p=(length(which(mod.swap2>=mods[[1]]))+1)/100001
p


com.boot=vector(length=100) #set up empty vector 
for (i in 1:100){
s.col=sample(1:ncol(m.list[[1]]), ncol(m.list[[1]]), replace=T) #sample with replacement the columns
nm1=m.list[[1]][,s.col] #create new matrix using resampled columns
g.boot=graph_from_adjacency_matrix(get_network(t(nm1)), "undirected", weighted=T) #bootstrapped network
com.boot[i]=modularity(cluster_fast_greedy(g.boot)) #calculate modularity using fast_greedy community detection
}
boxplot(com.boot)


boxplot(mod.swap, com.boot, col="gray", las=1, names=c("Null", "Empirical \n(bootstrap)"), ylab="Modularity")


#Mantel Test of across-year consistency of associations
library(ecodist)

#restrict comparison to individuals that were seen in two sequential years 
id12=rownames(adjs[[1]])[rownames(adjs[[1]])%in%rownames(adjs[[2]])] #get IDs of birds that were present in both networks
ids.m1=match(id12,rownames(adjs[[1]])) #get row/columns of those individuals in matrix 1 
ids.m2=match(id12,rownames(adjs[[2]])) #get row/colums of those individuals in matrix 2
m12=adjs[[1]][ids.m1,ids.m1] #matrix 1 of association indices of only returning individuals
m21=adjs[[2]][ids.m2,ids.m2] #matrix 2 of association indices of only returning individuals
m12=m12[order(rownames(m12)),order(rownames(m12))] #reorder the rows/columns by alphanumeric order
m21=m21[order(rownames(m21)),order(rownames(m21))] #reorder the rows/columns by alphanumeric order
mantel12=mantel(as.dist(m12)~as.dist(m21)) 
mantel12


plot(m12[upper.tri(m12)], m21[upper.tri(m21)], pch=19, col=rgb(1,0,0,0.5), cex=2, xlab="Season 2 Association Index", ylab="Season 3 Association Index")

s3=as.matrix(read.csv("GCSPspaceoverlap3.csv", header=T, row.names=1))
ids.s3=match(rownames(s3), rownames(adjs[[2]]))
ids.s3=na.omit(ids.s3)
ids.adj2=match(rownames(adjs[[2]]), rownames(s3) )
ids.adj2=na.omit(ids.adj2)

s3.use=s3[ids.s3, ids.s3]
adj.use=adjs[[2]][ids.adj2, ids.adj2]
s3.use=s3.use[order(rownames(s3.use)),order(rownames(s3.use))]
adj.use=adj.use[order(rownames(adj.use)),order(rownames(adj.use))]
plot(s3.use[upper.tri(s3.use)], adj.use[upper.tri(adj.use)], pch=19, cex=2, col=rgb(0,0,1, 0.5), xlab="Spatial Overlap", ylab="Association Index")


s3.match=s3.use[match(rownames(m21),rownames(s3.use)), match(rownames(m21),rownames(s3.use))] #sort rows and columns to match the adjacency matrix


mrqap.dsp(m21~m12 + s3.match)


mrqap.dsp(scale(m21)~scale(m12) + scale(s3.match))
