### Firth & Sheldon example

load(url("http://datadryad.org/bitstream/handle/10255/dryad.71301/figure2data_wholenetworks.RData"))

str(whole.networks) #list of networks

description #text of what is in the dataset
id.info #vector of RFID tags assigned to "odd" or "even"

library(igraph)

g.pre=graph_from_adjacency_matrix(whole.networks[[1]], mode="undirected", weighted=T)

plot(g.pre, vertex.label="", vertex.size=5)

rfid.dat=data.frame(id=as.factor(1:339), oddeven=id.info)

V(g.pre)$name

V(g.pre)$oddeven=rfid.dat[match(V(g.pre)$name, rfid.dat$id), "oddeven"]
V(g.pre)$oddeven

V(g.pre)$node.color=c("red", "lightblue")[V(g.pre)$oddeven+1]

#assign node color based on odd or even
par(mar=c(1,1,1,1))
plot(g.pre, vertex.label="", vertex.size=5, vertex.color=V(g.pre)$node.color)

##measuring assortment
library(assortnet)

library(help=assortnet)

r.pre=assortment.discrete(whole.networks[[1]], V(g.pre)$oddeven)
r.pre
r.pre$r

##implementing node-label permutations

sample(V(g.pre)$oddeven, length(V(g.pre)), replace=F) #node labels randomized

s=sample(V(g.pre)$oddeven, length(V(g.pre)), replace=F)

r.pre.rand=assortment.discrete(whole.networks[[1]], s)
r.pre.rand$r

times=100
r.pre.permutation=vector(length=times)
for(i in 1:100){
  s=sample(V(g.pre)$oddeven, length(V(g.pre)), replace=F)
  r.pre.rand=assortment.discrete(whole.networks[[1]], s)
  r.pre.permutation[i]=r.pre.rand$r
}

r.pre.permutation
hist(r.pre.permutation)
abline(v=r.pre$r, col="red")

p.pre=(length(which(r.pre.permutation>=r.pre$r))+1)/(times+1)
p.pre

### make this whole routine into a custom function

run_analysis=function(x){
  g=graph_from_adjacency_matrix(x, mode="undirected", weighted=T)
  V(g)$oddeven=rfid.dat[match(V(g)$name, rfid.dat$id), "oddeven"]
  r=assortment.discrete(x, V(g)$oddeven)$r
  
  t=1000
  r.permutation=vector(length=t)
  for(i in 1:t){
    s=sample(V(g)$oddeven, length(V(g)), replace=F)
    r.permutation[i]=assortment.discrete(x, s)$r
  }
  
  p=(length(which(r.permutation>=r))+1)/(t+1)
  
  list(g=g, r=r, r.permutation=r.permutation, p=p) #four outputs in a list: (1) the network "g", (2) the observed assortment coefficient "r", (3) vector of assortment coefficients from permutations, (4) p-value
}

run_analysis(whole.networks[[1]])

all.analyses=lapply(whole.networks, run_analysis)

str(all.analyses, max.level=1)

sapply(all.analyses, function(x) x$r)

sapply(all.analyses, function(x) x$p)
