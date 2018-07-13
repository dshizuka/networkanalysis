##Hypothesis Testing with Permutations
# Illustration

library(igraph)

g=erdos.renyi.game(20, p=0.2)
V(g)$color=c(rep("red",10), rep("gold",10))
plot(g, layout=layout_in_circle(g), vertex.label="", edge.color="black")

setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(g, layout=layout_in_circle(g), vertex.label="", edge.color="black", main=list("original", cex=2))
for (i in 1:3){
s=sample(V(g)$color, length(V(g)$color), replace=F)
plot(g, layout=layout_in_circle(g), vertex.label="", vertex.color=s, edge.color="black", main=paste("Permutation", i, sep=" "))
}

## edge permutation

setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(g, layout=layout_in_circle(g), vertex.label="", edge.color="black", main=list("original", cex=2))
for (i in 1:3){
g2=rewire(g, each_edge(prob=1))
plot(g2, layout=layout_in_circle(g2), vertex.label="", edge.color="black", main=paste("Permutation", i, sep=" "))
}



### maybe use lattice
latg=make_lattice(dimvector=20, nei=2, circular=T)
V(latg)$color=c(rep("red",10), rep("yellow",10))
plot(latg, layout=layout_in_circle(latg), vertex.label="",edge.curved=c(rep(0,20), 1, -1, -1, rep(1, 17)), edge.color="black")

setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(latg, layout=layout_in_circle(latg), edge.color="black", edge.curved=c(rep(0,20), 2, -2, -2, rep(2, 17)), vertex.size=25,main=list("original", cex=2))
for (i in 1:3){
s=sample(V(latg)$color, length(V(latg)$color), replace=F)
plot(latg, layout=layout_in_circle(latg), vertex.color=s, vertex.size=25,edge.color="black", edge.curved=c(rep(0,20), 1, -1, -1, rep(1, 17)), main=paste("Permutation", i, sep=" "))
}

## edge permutation
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(latg, layout=layout_in_circle(latg), vertex.label="", edge.color="black", edge.curved=c(rep(0,20), 1, -1, -1, rep(1, 17)), main=list("original", cex=2))
for (i in 1:3){
g2=rewire(latg, each_edge(prob=1))
plot(g2, layout=layout_in_circle(g2), vertex.label="", edge.color="black", edge.curved=0.5, main=paste("Permutation", i, sep=" "))
}

degree(latg)
degree(g2)

## edge permutation
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(latg, layout=layout_in_circle(latg), vertex.label="", edge.color="black", edge.curved=c(rep(0,20), 1, -1, -1, rep(1, 17)), main=list("original", cex=2))
for (i in 1:3){
  g2=rewire(latg, keeping_degseq(niter=vcount(latg)))
  plot(g2, layout=layout_in_circle(g2), vertex.label="", edge.color="black", edge.curved=0.5, main=paste("Permutation", i, sep=" "))
}

## edge permutation
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
lg2=latg=make_lattice(dimvector=20, nei=2, circular=F)
plot(latg, layout=layout_on_grid(latg), vertex.label="", edge.color="black", main=list("original", cex=2))
for (i in 1:3){
  g2=rewire(latg, keeping_degseq(niter=vcount(latg)))
  plot(g2, layout=layout_in_circle(g2), vertex.label="", edge.color="black", edge.curved=0.5, main=paste("Permutation", i, sep=" "))
}


#use UK faculty
library(igraphdata)
data(UKfaculty)
ukf=simplify(UKfaculty)
ukf=as.undirected(ukf)
ukf

setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
l=layout_with_fr(ukf)
plot(ukf,layout=l, vertex.color=c("tomato", "slateblue", "yellow", "green")[V(ukf)$Group], vertex.label="", vertex.size=10, main=list("original", cex=2))

for (i in 1:3){
  V(ukf)$color=c("tomato", "slateblue", "yellow", "green")[sample(V(ukf)$Group, vcount(ukf),  replace=F)]
  plot(ukf,layout=l, vertex.label="", vertex.size=10, main=paste("Permutation ", i, sep=""))
}

hist(degree(ukf))

#
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
l=layout_with_fr(ukf, weights=E(ukf)$weight)
plot(ukf,layout=l, vertex.color=c("tomato", "slateblue", "yellow", "green")[V(ukf)$Group], vertex.label="", vertex.size=10, main=list("original", cex=2), edge.width=E(ukf)$weight/5)

for (i in 1:3){
  ukf2=rewire(ukf, each_edge(prob=1))
  plot(ukf2,vertex.label="", vertex.size=10, main=paste("Permutation ", i, sep=""))
}

#
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
l=layout_with_fr(ukf, weights=E(ukf)$weight)
plot(ukf,layout=l, vertex.color=c("tomato", "slateblue", "yellow", "green")[V(ukf)$Group], vertex.label="", vertex.size=10, main=list("original", cex=2), edge.width=E(ukf)$weight/5)

for (i in 1:3){
  ukf3=rewire(ukf, keeping_degseq(niter=vcount(ukf)))
  plot(ukf3,vertex.label="", vertex.size=10, main=paste("Permutation ", i, sep=""))
}


##

b=barabasi.game(50, 0.5, m=1,directed=F)
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(b, vertex.label="", edge.color="black",  main=list("original", cex=2))
for (i in 1:3){
  b2=rewire(b, each_edge(prob=1))
  plot(b2, vertex.label="", edge.color="black", main=paste("Permutation", i, sep=" "))
}


b=barabasi.game(50, 0.5, 1,directed=F)
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(b, vertex.label="", edge.color="black",  main=list("original", cex=2))
for (i in 1:3){
  b2=rewire(b, keeping_degseq(niter=vcount(b)))
  plot(b2, vertex.label="", edge.color="black", main=paste("Permutation", i, sep=" "))
}

g=erdos.renyi.game(50, p=0.1, directed=F)
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(g, vertex.label="", edge.color="black",  main=list("original", cex=2))
for (i in 1:3){
  g2=rewire(g, each_edge(prob=1))
  plot(g2, vertex.label="", edge.color="black", main=paste("Permutation", i, sep=" "))
}

g=erdos.renyi.game(50, p=0.15, directed=F)
setup=layout(matrix(c(1,1,1,2,3,4), 2,3, byrow=T))
par(mar=c(1,1,2,1))
plot(g, vertex.label="", edge.color="black",  main=list("original", cex=2))
for (i in 1:3){
  g2=rewire(g, keeping_degseq(niter=vcount(b)))
  plot(g2, vertex.label="", edge.color="black", main=paste("Permutation", i, sep=" "))
}
