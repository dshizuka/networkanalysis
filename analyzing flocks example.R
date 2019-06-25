##Analyzing Sparrow Network example

library(tidyr)
library(asnipe)
library(igraph)

flock2=read.csv('https://datadryad.org/bitstream/handle/10255/dryad.63925/Flock_Season2_Dryad.csv')
flock3=read.csv('https://datadryad.org/bitstream/handle/10255/dryad.63926/Flock_Season3_Dryad.csv')
head(flock2)

flock.list=list(flock2, flock3)

m.list=lapply(flock.list, function(x) {

birdcols=grep("Bird", colnames(x)) #get the columns that have bird IDs
ids=unique(gather(x[,birdcols])$value) #get the unique IDs observed in the dataset
ids=ids[is.na(ids)==F & ids!="" & ids!=" "] #remove NAs and blanks

m1=apply(x[,birdcols], 1, function(y) match(ids, y)) #matrix where we look for ids in each flock observatino

m1[is.na(m1)]=0 #make NAs = 0
m1[m1>0]=1 # if ID is found in the observation, make value = 1
rownames(m1)=ids
colnames(m1)=1:ncol(m1)

m2=m1[which(rowSums(m1)>2),] #filter out individuals that were only seen once or twice
m2
})

m.list #two individual-by-group matrices saved as a list
class(m.list)
str(m.list)

#use lapply to get two adjacency matrices
adjs=lapply(m.list, function(x) get_network(t(x), data_format = "GBI", association_index = "SRI"))

str(adjs)

#use lapply to get two networks
gs=lapply(adjs, function(x) graph_from_adjacency_matrix(x, "undirected", weighted=T))

gs

#plot both networks side by side
par(mfrow=c(1,2), mar=c(1,1,1,1))
for(i in 1:2){
  plot(gs[[i]], edge.width=E(gs[[i]])$weight*10, vertex.color="gold1", vertex.size=8, vertex.label="")
}

##modularity in both seasons

coms=lapply(gs, function(x) cluster_fast_greedy(x))
mods=lapply(coms, function(x) modularity(x))

memberships=lapply(coms, function(x) membership(x))
memberships

#plot both networks side by side
par(mfrow=c(1,2), mar=c(1,1,1,1))
for(i in 1:2){
  plot(gs[[i]], edge.width=E(gs[[i]])$weight*10, vertex.color=memberships[[i]], vertex.size=8, vertex.label="")
}

gbi2=t(m.list[[1]])
adj2=get_network(gbi2)

#create an array of 10,000 adjacency matrices
net.perm=network_permutation(gbi2, permutations=10000, returns=1, association_matrix=adj2)

class(net.perm)

#create 10,000 networks
swap.g2=apply(net.perm, 1, function(x) graph_from_adjacency_matrix(x, "undirected", weighted=T))

#calculate modularity for each of 10,000 networks, each after one swap
mod.swap2=sapply(swap.g2, function(x) modularity(cluster_fast_greedy(x)))

mod.swap2

plot(1:10000, mod.swap2, type="l")

hist(mod.swap2, xlim=c(0, 0.5))
abline(v=mods[[1]], col="red", lty=2)

p=(length(which(mod.swap2>=mods[[1]]))+1)/10001
p

#testing for effect of previous year association

adjs

#restrict comparison to individuals seen in both years

rownames(adjs[[1]]) #ids in first adjacency matrix
rownames(adjs[[2]]) #ids in second adjacency matrix

rownames(adjs[[1]]) %in% rownames(adjs[[2]]) #is id in first matrix also in the second matrix? 

id12=rownames(adjs[[1]])[rownames(adjs[[1]]) %in% rownames(adjs[[2]])] #gives you the ids that are in both

ids.m1=match(id12, rownames(adjs[[1]])) #which rows in first adjacency matrix are ones we want to keep?
ids.m2=match(id12, rownames(adjs[[2]])) #which rows in second adjacency matrix are ones we want to keep?

m12=adjs[[1]][ids.m1, ids.m1] #first adjacency matrix trimmed
m21=adjs[[2]][ids.m2, ids.m2] #second adjacency matrix trimmed

order(rownames(m12)) #find the order of values

#sort row and columns of both matrices so that they match
m12=m12[order(rownames(m12)), order(rownames(m12))]
m21=m21[order(rownames(m21)), order(rownames(m21))]

#test correlation between association indices across two years with Mantel Test
library(ecodist)
mantel(as.dist(m12)~as.dist(m21))


#test same with MRQAP (multiple regression quadratic assignment procedure)
mrqap.dsp(m21~m12)


##
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