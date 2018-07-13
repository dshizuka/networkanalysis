library(asnipe)
library(igraph)
library(assortnet)

#simulation
###
set.seed(3)
n=20
p=0.3
g1=erdos.renyi.game(n, p=0.5)
V(g1)$trait=sample(c(1,2), n, prob=c(p, 1-p), replace=T)
g2=erdos.renyi.game(n, p=0.5)
V(g2)$trait=sample(c(1,2), n, prob=c(1-p, p), replace=T)
g3=g1+g2

for(i in 1:20){
g3=add_edges(g3,c(sample(1:n, 1), sample((n+1):(n*2),1)))
}

plot(g3, vertex.color=c("tomato", "gold")[V(g3)$trait])

m=as_adjacency_matrix(g3, sparse=F)
assort0=assortment.discrete(m, V(g3)$trait)$r


#node label permutation
times=1000
assort.r=vector(length=times)
for (i in 1:times){
V(g3)$trait.random=sample(V(g3)$trait, length(V(g3)$trait), replace=F)
assort.r[i]=assortment.discrete(m, V(g3)$trait.random)$r
}
hist(assort.r, xlim=c(-0.5,0.5))
abline(v=assort0, lty=2, col="red")
length(which(assort.r>=assort0))/times

###

library(igraphdata)
data(karate)
plot(karate)
