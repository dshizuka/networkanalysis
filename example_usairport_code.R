library(igraph) 
library(igraphdata) 
data(USairports) 
USairports

airports=read.csv('https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat', header=F)
head(airports)

V(USairports)$lat=airports[match(V(USairports)$name, airports[,5]), 7] 
V(USairports)$long=airports[match(V(USairports)$name, airports[,5]), 8]

#remove loops and make undirected
usair=as.undirected(simplify(USairports))

#remove airports whose codes didn't match the OpenFlights database (and hence returned "NA" for latitude)
usair=delete.vertices(usair, which(is.na(V(usair)$lat)==TRUE))

#remove nodes in the Eastern and Southern Hemispheres (US territories). This will make the plot easier to see.
usair=delete.vertices(usair, which(V(usair)$lat<0))
usair=delete.vertices(usair, which(V(usair)$long>0))

#keep only the largest connected component of the network ("giant component"). this also makes the network easier to see.
decomp=decompose.graph(usair)
usair=decomp[[1]]

set.seed(3)
l=layout_with_fr(usair)
plot(usair, layout=l, vertex.label="", vertex.size=3)

plot(degree(usair), betweenness(usair), pch=19) #pch=19 uses filled circles

V(usair)$name[order(degree(usair), decreasing=T)][1:10] #order() gives us the element number in order of ranking.

V(usair)$name[order(betweenness(usair), decreasing=T)][1:10] #order() gives us the element number in order of ranking.

longlat=matrix(c(V(usair)$long, V(usair)$lat), ncol=2) #set up layout matrix 
par(mar=c(1,1,1,1))
plot(usair, layout=longlat, vertex.label="", vertex.size=3)

fg=fastgreedy.community(usair) 
length(fg)
modularity(fg)

library(rnetcarto)
usair.mat=as_adjacency_matrix(usair, sparse=F)
rnc=netcarto(usair.mat)
#modularity
rnc[[2]]
#modules
length(unique(rnc[[1]]$module))

plot(rnc[[1]]$participation, rnc[[1]]$connectivity, pch=19)
