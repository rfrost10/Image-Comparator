#toKeep <- c("imageID", "mike", "mikeS", "mikeR", "jim", "paul")
#expertCompare<-classRes[toKeep]
#classRes_long <- gather(expertClass, expert, measurement, mike:paul)

ratings <- classRes[c(2:9)]
ratings <- expertCompare[c(2:6)]

toKeep <- c( "mikeS","mikeR", "mike",  "paul","jim")
ratings <-expertC

#expMap<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3", "mike"="expert4","paul"="expert5","jim"="expert6","kim"="expert7","phil"="expert8")
#expMap<-c("mikeR"="expert1","mikeS"="expert2","kelly"="expert3", "mike"="expert4","paul"="expert5","jim"="expert6","phil"="expert7","kim"="expert8")

newRatings6 <-plyr::rename(ratings,expMap )
#p + geom_tile(aes(fill=value)) + scale_fill_gradient(low="white", high="darkblue") + xlab("") + ylab("")

#p<-p+scale_fill_gradient2(low = "blue", high = "red", mid = "white",  
#                          midpoint = 0, limit = c(-1,1), space = "Lab",  name="Unweighted\nKappa")

p<-p+scale_fill_gradient2(low="white", high="darkblue", name="Unweighted\nKappa")
p<-p+scale_colour_gradient(limits=c(0, 1))
p<-p+scale_fill_continuous(low="red", high="white", space="Lab", name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
p<-p+scale_fill_continuous(name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))


ratings <- classRes[toKeep]
newRatings <-plyr::rename(ratings,expMap )


p<-p+scale_fill_gradientn(colours=topo.colors(5),na.value = "transparent",limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
p<- p+labs(x="Rater 1",  y = "Rater 2", title="Heat map of weighted kappas for dataset B")
p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.title= element_text(size=20), plot.title = element_text(size = rel(2)))
p



corrplot(M, order = "hclust")
corrplot(M, order = "FPC", method = "color")
corrplot(M, order = "FPC", method =  "shade")
write.csv(M, 'cor.txt')

M

corrplot.mixed(M)
, order = "FPC", method = "color")
write.csv(allRatings,file="allRankings34.csv")

