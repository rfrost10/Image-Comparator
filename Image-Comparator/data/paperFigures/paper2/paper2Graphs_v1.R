rm(list=ls())
library(tidyr)
library(ggplot2)
library(PlayerRatings)
library(plyr)
library(dplyr)
library(corrplot)
library(irr)
library(ggplot2)
library(scales)

## fig1
setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/combined")

comps<-read.csv("pairwise_vs_classRankSet34_forR.csv")

g<-ggplot(comps, aes(x=eloRanking, y=avgRank_8)) + geom_point(size=4) +theme_bw()
g<- g+labs(x="Pairwise Rank",  y = "Classification Rank", title="Ranks based on classification vs. comparison on dataset B")
g<-g+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
g<-g+ theme(axis.title= element_text(size=20), plot.title = element_text(size = rel(2)))

g


#############figure 2########################
# kappa heat map set 34

## order for 8: mikeS, mikeR, kelly, mike, paul, kim, phil, jim
## mising for comparison: kim, phil

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34")
classRes <- read.csv('34classify_forR_kappa.csv')
classRes$imageID <- factor(classRes$imageID)
experts8 <- c( "mikeS", "mikeR", "kelly","mike", "paul","kim", "phil","jim")
experts6 <- c( "mikeS", "mikeR",  "kelly", "mike", "paul","jim")
#experts6 <- c( "mikeS",  "kelly", "mikeR", "mike", "paul","jim")

expertClass6<-classRes[experts6]
expMap8<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5","kim"="expert6","phil"="expert7","jim"="expert8")
expMap6<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5", "jim"="expert8")
#expMap6<-c("mikeS"="expert1","kelly"="expert2","mikeR"="expert3","mike"="expert4", "paul"="expert5", "jim"="expert8")

newRatings6 <-plyr::rename(expertClass6,expMap6 )


a6<-agree(newRatings6,tolerance=0)
kf6<-kappam.fleiss(newRatings6)
kl6<-kappam.light(newRatings6)

numRaters <-ncol(newRatings6)
users <-colnames(newRatings6)

df <- data.frame(matrix(ncol = 4, nrow = (numRaters*(numRaters+1)/2)))
colMap<-c("X1"="user1","X2"="user2","X3"="kappa_unw","X4"="kappa_eq")
kappaM <-plyr::rename(df,colMap)
kappaSq_w<-data.frame(matrix(nrow=numRaters,ncol=numRaters))
count=0
for (i in 1:numRaters) {
  for (j in 1:numRaters){
    count=count+1 
    kappaM[count,1]<-users[i]
    kappaM[count,2]<-users[j]
    k_unw<- kappa2(newRatings6[,c(i,j)], weight = c("unweighted"))
    kappaM[count,3]<-k_unw$value
    # print(k_unw$value)
    k_lin<- kappa2(newRatings6[,c(i,j)], weight = c("equal"))
    # print(k_lin$value)
    kappaM[count,4]<-k_lin$value
    kappaSq_w[i,j]<-k_lin$value
    kappaSq_w[j,i]<-k_lin$value
  #  print(count)
  }
}
melted_cormat <- melt(kappaSq_w)


#http://stackoverflow.com/questions/12834802/non-linear-color-distribution-over-the-range-of-values-in-a-geom-raster
p <- ggplot(data = kappaM, aes(x=user1, y=user2, fill=kappa_eq)) + geom_tile()
p
p<-p+scale_fill_continuous(low="white", high="darkblue", name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
p
p<-p+scale_fill_continuous(low="darkblue", high="white", name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
p
#p<- p+labs(x="Rater 1",  y = "Rater 2", title="Heat map of weighted \n kappas for dataset B")
p<- p+labs(x="Rater 1",  y = "Rater 2")

p

p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
p
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
p
p<-p+geom_text(aes(user1, user2, label = round(kappa_eq,2)), color = "black", size = 4)
p

##############heat map for rank correlations

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")
#setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")

compareRes <- read.csv('set34_compare_rev3_forR.csv')

#toKeep8 <- c("taskId","img0Id","img1Id","img0Name","img1Name","mikeS", "mikeR", "kelly", "mike", "paul", "kim", "phil", "jim")
toKeep6 <- c("taskId","img0Id","img1Id","img0Name","img1Name","mikeS", "mikeR", "kelly", "mike", "paul", "jim")

expertCompare6<-compareRes[toKeep6]
#expMap8<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5","kim"="expert6","phil"="expert7","jim"="expert8")
expMap6<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5", "jim"="expert8")

newRatings6 <-plyr::rename(expertCompare6,expMap6 )

#compareRes$taskId <- factor(compareRes$taskId)
compareRes_long <- gather(newRatings6, user, winner, expert1:expert8)
#write.csv(compareRes_long,file="34classify_long_final6_anon.csv",sep = ",")
users <-unique(compareRes_long$user)

allData<-compareRes_long[,c(1,2,3,6,7)]
allData[allData== -1] <- 0
allData[allData=="" ] <- NA
allData <- allData[!(allData$winner == "" | is.na(allData$winner)), ]
allData2<-allData[,c(1,2,3,5)]
allElo<-elo(allData2)
allElo

fname <- paste0("all_6","Elo.csv")
ratingsA <-as.data.frame(allElo$ratings)
write.csv(ratingsA,file=fname)

#ratingsA <-as.data.frame(allElo$ratings)
ratingsSortedA<-arrange(ratingsA,Player)
imageId<-ratingsSortedA$Player
allScore<-ratingsSortedA$Rating
allRatings <- data.frame(imageId, allScore)


for (i in users) {
  print(i)
  thisData <-subset(allData, allData$user==i)
  thisData2<-thisData[,c(1,2,3,5)]
  thisElo <-elo(thisData2)
  fname <- paste0(i,"Elo.csv")
  ratings <-as.data.frame(thisElo$ratings)
  #write.csv(ratings,file=fname)
  ratingsSorted<-arrange(ratings,Player)
  allRatings <- cbind(allRatings, ratingsSorted$Rating)
 # names(allRatings)[[ncol(allRatings)]] <- paste0(i,"Elo") 
  names(allRatings)[[ncol(allRatings)]] <- paste0(i) 
  
}
M <- cor(allRatings[,3:8])

melted_cormat <- melt(M)


#http://stackoverflow.com/questions/12834802/non-linear-color-distribution-over-the-range-of-values-in-a-geom-raster
p <- ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + geom_tile()
p
p<-p+scale_fill_continuous(low="darkblue", high="white", name="Correlation coefficient  \n of estimated ranks", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
p
#p<- p+labs(x="Rater 1",  y = "Rater 2", title="Heat map of weighted \n kappas for dataset B")
p<- p+labs(x="Rater 1",  y = "Rater 2")

p

p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
p
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
p
p<-p+geom_text(aes(Var1, Var2, label = round(value,2)), color = "black", size = 4)
p


rm(list=ls())
library(tidyr)
library(ggplot2)
library(PlayerRatings)
library(plyr)
library(corrplot)

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")
compareRes <- read.csv('set34_compare_rev3_forR_rev2.csv')

hist(compareRes$agreementRatio)

