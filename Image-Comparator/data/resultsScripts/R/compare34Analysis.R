rm(list=ls())
library(tidyr)
library(ggplot2)
library(PlayerRatings)
library(plyr)
library(dplyr)
library(corrplot)

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")
#setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")

compareRes <- read.csv('set34_compare_rev3_forR.csv')


toKeep <- c("taskId","img0Id","img1Id","img0Name","img1Name","mike", "mikeS", "mikeR", "jim", "paul")

expertCompare<-compareRes[toKeep]


#compareRes$taskId <- factor(compareRes$taskId)
compareRes_long <- gather(compareRes, user, winner, jason:testuser4)
#compareRes_long <- gather(expertCompare, user, winner, mike:paul)

#write.csv(compareRes_long,file="34classify_long.csv",sep = ",")
users <-unique(compareRes_long$user)

allData<-compareRes_long[,c(1,2,3,6,7)]
allData[allData== -1] <- 0
allData[allData=="" ] <- NA
allData <- allData[!(allData$winner == "" | is.na(allData$winner)), ]
allData2<-allData[,c(1,2,3,5)]
allElo<-elo(allData2)
allElo

fname <- paste0("all","Elo.csv")
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
  names(allRatings)[[ncol(allRatings)]] <- paste0(i,"Elo") 
  
}
M <- cor(allRatings[,2:15])
corrplot(M, order = "hclust")
corrplot(M, order = "FPC", method = "color")
corrplot(M, order = "FPC", method =  "shade")
write.csv(M, 'cor.txt')

M

corrplot.mixed(M)
, order = "FPC", method = "color")
write.csv(allRatings,file="allRankings34.csv")
#maData <- subset(compareRes_long, compareRes_long$user=="maria")
# mariaData<-maData[,c(1,2,3,7)]
# mariaData[mariaData== -1] <- 0
# mariaData[mariaData=="" ] <- NA
# mariaData <- mariaData[!(mariaData$winner == "" | is.na(mariaData$winner)), ]
# mariaElo<-elo(mariaData)
# mariaElo

# 
# mData <- subset(compareRes_long, compareRes_long$user=="mike")
# mikeData<-mData[,c(1,2,3,7)]
# mikeData[mikeData== -1] <- 0
# mikeData[mikeData=="" ] <- NA
# mikeData <- mikeData[!(mikeData$winner == "" | is.na(mikeData$winner)), ]
# mikeElo <-elo(mikeData)
# mikeElo
# 
# 
# msData <- subset(compareRes_long, compareRes_long$user=="mikeS")
# mikeSData<-msData[,c(1,2,3,7)]
# mikeSData[mikeSData== -1] <- 0
# mikeSData[mikeSData=="" ] <- NA
# mikeSData <- mikeSData[!(mikeSData$winner == "" | is.na(mikeSData$winner)), ]
# mikeSElo <-elo(mikeSData)
# mikeSElo
# 
# 
# pData <- subset(compareRes_long, compareRes_long$user=="paul")
# paulData<-pData[,c(1,2,3,7)]
# paulData[paulData== -1] <- 0
# paulData[paulData=="" ] <- NA
# paulData <- paulData[!(paulData$winner == "" | is.na(paulData$winner)), ]
# paulElo <-elo(paulData)
# paulElo
# 
# kData <- subset(compareRes_long, compareRes_long$user=="kelly")
# kellyData<-kData[,c(1,2,3,7)]
# kellyData[kellyData== -1] <- 0
# kellyData[kellyData=="" ] <- NA
# kellyData <- kellyData[!(kellyData$winner == "" | is.na(kellyData$winner)), ]
# kellyElo <-elo(kellyData)
# kellyElo
# 
# jData <- subset(compareRes_long, compareRes_long$user=="jim")
# jimData<-jData[,c(1,2,3,7)]
# jimData[jimData== -1] <- 0
# jimData[jimData=="" ] <- NA
# jimData <- jimData[!(jimData$winner == "" | is.na(jimData$winner)), ]
# jimData <-elo(jimData)
# jimData
# 

rm(list=ls())
library(tidyr)
library(ggplot2)
library(PlayerRatings)
library(plyr)
library(corrplot)

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")
compareRes <- read.csv('set34_compare_rev3_forR_rev2.csv')

hist(compareRes$agreementRatio)


