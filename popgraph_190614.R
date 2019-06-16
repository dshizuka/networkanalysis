require(devtools)
install_github("dyerlab/popgraph")

11#require(devtools)
#install_github("dkahle/ggmap", ref = "tidyup")

library(popgraph)
library(igraph)

lopnet=as.matrix(read.csv("https://dshizuka.github.io/NAOC2016/lopho_network.csv", header=T, row.names=1)) #From Dyer et al. 2004
lopnet

g=graph_from_adjacency_matrix(lopnet, mode="undirected") 
plot(g)


locations=read.csv("https://dshizuka.github.io/NAOC2016/lopho_locations.csv") 
head(locations)


#create a two-column matrix of x- and y-coordinates
V(g)$x=locations[match(V(g)$name, locations$Population),"Long"] 
V(g)$y=locations[match(V(g)$name, locations$Population),"Lat"] 
l=matrix(c(V(g)$x, V(g)$y), ncol=2)
# color code nodes by region
regions=locations[match(V(g)$name, locations$Population),"Region"] 
V(g)$color=c("tomato", "turquoise2")[as.numeric(regions)]
plot(g, layout=l)


par(mfrow=c(1,2), mar=c(2,2,2,2))
plot(g, layout=l, main="Spatial Layout")
plot(g, layout=layout_with_fr(g), main="Force-directed layout")

library(ggmap)
#register_google(key=" AIzaSyA3VUtWgt2rYUmoGaRpj3kcd7OEAA6J6D4 ")

location = c( mean(V(g)$x), mean(V(g)$y))

#map = get_map(location,maptype="satellite", zoom=6) #use ggmap to get a satellite image of the study area.
#p = ggmap( map ) #plot will include this image
#p = p + geom_edgeset(aes(x=x, y=y), g, color="white") #plot will also include the network edges, in white
#p = p + geom_nodeset(aes(x=x, y=y, color=color), g, size=6) #plot will also include the network nodes, color-coded by region
#p #plot color

###
map=get_stamenmap(location, bbox=c(left=-118, bottom=20, right=-108, top=35), zoom=6, source="stamen", maptype="watercolor")

p=ggmap(map)
p = p + geom_edgeset(aes(x=x, y=y), g, color="black") #plot will also include the network edges, in white
p = p + geom_nodeset(aes(x=x, y=y, color=color), g, size=6) #plot will also include the network nodes, color-coded by region
p #plot color

?get_stamenmap

###
map=get_stamenmap(location, bbox=c(left=-118, bottom=20, right=-108, top=35), zoom=6, source="stamen", maptype="terrain-background")

p=ggmap(map)
p = p + geom_edgeset(aes(x=x, y=y), g, color="black") #plot will also include the network edges, in white
p = p + geom_nodeset(aes(x=x, y=y, color=color), g, size=6) #plot will also include the network nodes, color-coded by region
p #plot color
###
map=get_stamenmap(location, bbox=c(left=-118, bottom=20, right=-108, top=35), zoom=6, source="stamen", maptype="watercolor")

p=ggmap(map)
p = p + geom_edgeset(aes(x=x, y=y), g, color="black") #plot will also include the network edges, in white
p = p + geom_nodeset(aes(x=x, y=y, color=color), g, size=6) #plot will also include the network nodes, color-coded by region
p #plot color



library(maps)
library(geosphere)
library(mapproj)

edges=as_data_frame(g)
colnames(edges)=c("v1", "v2")
map(database="world", xlim=c(-118,-108), ylim=c(20, 35), col="gray",fill=T)

for(i in 1:nrow(edges))  {
  node1 <- locations[locations$Population == edges[i,"v1"],]
  node2 <- locations[locations$Population == edges[i,"v2"],]
  
  arc <- gcIntermediate( c(node1$Long, node1$Lat), 
                         c(node2$Long, node2$Lat), 
                         n=1000, addStartEnd=TRUE )
  
  lines(arc, lwd=2)
}

points(x=locations$Long, y=locations$Lat, pch=21, 
       cex=3, bg=c("tomato", "turquoise2")[as.numeric(locations$Region)])
