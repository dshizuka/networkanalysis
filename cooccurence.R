library(EcoSimR)
library(igraph)

g.a=as.matrix(read.csv("https://dshizuka.github.io/networkanalysis/SampleData/Gotelli_Abele.csv", header=T, row.names=1))
g.a

bird.net=graph_from_incidence_matrix(g.a)
bird.cooc=bipartite.projection(bird.net)$proj1
bird.mat=as_adjacency_matrix(bird.cooc, sparse=F, attr="weight")


t=100
nm.array=array(dim=c(nrow(g.a), ncol(g.a), t))
for(i in 1:t){
nm=cooc_null_model(g.a, algo="sim9")
nm.array[,,i]=nm$Randomized.Data
}

