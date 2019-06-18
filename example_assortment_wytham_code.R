### codes for example: Experimental assortment of birds in wytham woods


#load(url("http://datadryad.org/bitstream/handle/10255/dryad.71301/figure2data_wholenetworks. RData"))

load("SampleData/figure2data_wholenetworks.RData")

str(whole.networks)


library(igraph)
g.pre=graph_from_adjacency_matrix(whole.networks[[1]], mode="undirected", weighted=T)

set.seed(2)
lay.pre=layout_with_fr(g.pre) # this will say a layout that we can use in subsequent versions of the network plot
plot(g.pre, edge.width=E(g.pre)$weight*10, vertex.label="", vertex.size=5, layout=lay.pre)


#create a data frame in which the first column is the "id number" and the second column is 1-odd or 0-even. **Note that we can name the columns within the `data.frame()` function 
rfid.dat=data.frame(id=as.factor(1:339), oddeven=id.info)
head(rfid.dat)

#look up the appropriate node name in the rfid.dat object and return the odd-or-even data.
V(g.pre)$oddeven=rfid.dat[match(V(g.pre)$name, rfid.dat$id), "oddeven"]


head(V(g.pre)$oddeven)

#create node color attribute based on odd (blue) or even (red) tags.
V(g.pre)$node.color=c("red","lightblue")[V(g.pre)$oddeven+1]

#plot the network using the node colors
plot(g.pre, vertex.color=V(g.pre)$node.color, edge.width=E(g.pre)$weight*20, vertex.label="", vertex.size=5, edge.color="black", layout=lay.pre)


g.during=graph_from_adjacency_matrix(whole.networks[[2]], mode="undirected", weighted=T) 
V(g.during)$oddeven=rfid.dat[match(V(g.during)$name, rfid.dat$id), "oddeven"] 
V(g.during)$node.color=c("red", "lightblue")[V(g.during)$oddeven+1]

plot(g.during, vertex.color=V(g.during)$node.color, edge.width=E(g.during)$weight*20, vertex.label="", vertex.size=5, edge.color="black")

#plot(g.during, vertex.color=V(g.during)$node.color, edge.width=E(g.during)$weight*20, vertex.label="", vertex.size=5, edge.color="black", layout=layout_with_graphopt(g.during))


library(assortnet)
#use the first adjacency matrix in the whole.networks list object: this is the pre-treatment period network

r.pre=assortment.discrete(whole.networks[[1]], V(g.pre)$oddeven)
r.pre

r.pre$r

r.during=assortment.discrete(whole.networks[[2]], V(g.during)$oddeven) 
r.during$r

s=sample(V(g.pre)$oddeven, length(V(g.pre)), replace=F) #we 'resample without replacement' the odd/even values for nodes.
head(V(g.pre)$oddeven) #first 6 values of odd/even types for the empirical data
head(s) #first 6 values of odd/even types for the permuted data


assortment.discrete(whole.networks[[1]], s)$r

t=1000
r.pre.permutation=vector(length=t)
for (i in 1:t){
  s=sample(V(g.pre)$oddeven, length(V(g.pre)),replace=F) 
  r.pre.permutation[i]=assortment.discrete(whole.networks[[1]], s)$r }


hist(r.pre.permutation)
abline(v=r.pre$r, lty=2, col="red", lwd=3) #arguments: lty = line type (2 = dashed line); col = color; lwd = line width

p.pre=(length(which(r.pre.permutation>r.pre$r))+1)/(t+1) 
p.pre


t=1000 
r.during.permutation=vector(length=t) 
for (i in 1:t){
  s=sample(V(g.during)$oddeven, length(V(g.during)$oddeven), replace=F)
  r.during.permutation[i]=assortment.discrete(whole.networks[[2]], s)$r 
}

hist(r.during.permutation, xlim=c(0.05, 0.15)) #NOTE: you will need to use the xlim= argument to adjust the x-axis limits so that the empirical assortativity value will show up! 
abline(v=r.during$r, lty=2, col="red", lwd=3)
p.during=(length(which(r.during.permutation>r.during$r))+1)/(t+1) 
p.during


##post
g.post=graph_from_adjacency_matrix(whole.networks[[3]], mode="undirected", weighted=T) 
V(g.post)$oddeven=rfid.dat[match(V(g.post)$name, rfid.dat$id), "oddeven"] 
r.post=assortment.discrete(whole.networks[[3]], V(g.post)$oddeven) 

t=1000 
r.post.permutation=vector(length=t) 
for (i in 1:t){
  s=sample(V(g.post)$oddeven, length(V(g.post)$oddeven), replace=F)
  r.post.permutation[i]=assortment.discrete(whole.networks[[3]], s)$r 
}

hist(r.post.permutation, xlim=c(-0.10, 0.15)) #NOTE: you will need to use the xlim= argument to adjust the x-axis limits so that the empirical assortativity value will show up! 
abline(v=r.post$r, lty=2, col="red", lwd=3)
p.post=(length(which(r.post.permutation>r.post$r))+1)/(t+1) 
p.post


boxplot(r.pre.permutation, r.during.permutation, r.post.permutation, col=c("gold", "tomato", "slateblue"), ylim=c(-0.1, 0.2), names=c("pre", "during", "post"))
abline(h=0, lty=2)
points(1,r.pre$r, pch="*", cex=5, col="gold")
points(2,r.during$r, pch="*", cex=5, col="tomato")
points(3, r.post$r, pch="*", cex=5, col="slateblue")

##function
run_analysis=function(x) {
  g=graph_from_adjacency_matrix(x, mode="undirected", weighted=T)
  V(g)$oddeven=rfid.dat[match(V(g)$name, rfid.dat$id), "oddeven"]
  r=assortment.discrete(x, V(g)$oddeven)$r
  t=1000
  r.permutation=vector(length=t)
  for (i in 1:t){
    s=sample(V(g)$oddeven, length(V(g)),replace=F) 
    r.permutation[i]=assortment.discrete(x, s)$r 
    r.permutation.quants=quantile(r.permutation, c(0.025, 0.975))
  }
  list(g=g, r=r, r.permutation=r.permutation, r.permutation.quants=r.permutation.quants)
}

all.results=lapply(whole.networks, run_analysis)

str(all.results, max.level=2)

lower.q=sapply(all.results, function(x) x$r.permutation.quants[1])
upper.q=sapply(all.results, function(x) x$r.permutation.quants[2])
r=sapply(all.results, function(x) x$r)

treatment.order=c(1,4,5,2,6,7,3)


df=data.frame(lower=lower.q[treatment.order], upper=upper.q[treatment.order], Assortment=r[treatment.order], treatments=c("pre.site", "pre.patch", "during.patch", "during.site", "during.nest", "post.nest", "post.site"))


library(ggplot2)
p = ggplot(df, aes(x = treatments, y = Assortment)) + geom_linerange(aes(ymax = upper, ymin = lower), colour=c("purple", "darkgreen", "darkgreen", "purple", "blue", "blue", "purple"))
p = p + theme_bw() 
p=p+ geom_point(colour=c("purple", "darkgreen", "darkgreen", "purple", "blue", "blue", "purple"), size=3, shape=c("circle", "triangle", "triangle", "circle", "asterisk", "asterisk", "circle")) 
p=p+ scale_x_discrete(limits=df$treatments) 
p=p+ scale_y_continuous(limits=c(-0.3, 0.3)) 
p=p+ geom_hline(aes(yintercept=0), linetype="dashed")
p

