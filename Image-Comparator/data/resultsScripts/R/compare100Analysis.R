rm(list=ls())
library(tidyr)
library(ggplot2)
library(PlayerRatings)
library(plyr)
library(corrplot)

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/compare/set100")
#compareRes <- read.csv('set34_compare_rev3_forR.csv')

compareRes_long <- read.csv('results_ICL_third_set_hundred_r2_compare.csv')


#compareRes$taskId <- factor(compareRes$taskId)
#compareRes_long <- gather(compareRes, user, winner, jason:testuser4)
#write.csv(compareRes_long,file="34classify_long.csv",sep = ",")
users <-unique(compareRes_long$user)

#allData<-compareRes_long[,c(1,2,3,6,7)]
allData<-compareRes_long[,c(1,2,3,4,5)]

allData[allData== -1] <- 0
allData[allData=="" ] <- NA
allData <- allData[!(allData$winner == "" | is.na(allData$winner)), ]
allData2<-allData[,c(1,2,3,4)]
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
  thisData2<-thisData[,c(1,2,3,4)]
  thisElo <-elo(thisData2)
  fname <- paste0(i,"Elo.csv")
  ratings <-as.data.frame(thisElo$ratings)
  #write.csv(ratings,file=fname)
  ratingsSorted<-arrange(ratings,Player)
  allRatings <- cbind(allRatings, ratingsSorted$Rating)
  names(allRatings)[[ncol(allRatings)]] <- paste0(i,"Elo") 
  
}

fname <- paste0("allusers","Elo.csv")
ratingsA <-as.data.frame(allRatings)
write.csv(ratingsA,file=fname)

cor(allRatings$allScore,allRatings$karynElo, method="spearman")
# 0.9685689
cor(allRatings$allScore,allRatings$paulElo, method="spearman")
# 0.9822142
cor(allRatings$allScore,allRatings$mikeElo, method="spearman")
#0.9744254
cor(allRatings$allScore,allRatings$susanElo, method="spearman")
# 0.9542154
cor(allRatings$allScore,allRatings$peteElo, method="spearman")
# 0.9681608

cor(allRatings$allScore,allRatings$karynElo)
#0.9700418
cor(allRatings$allScore,allRatings$paulElo)
#0.9837213
cor(allRatings$allScore,allRatings$mikeElo)
#0.9778853
cor(allRatings$allScore,allRatings$susanElo)
#0.9596353
cor(allRatings$allScore,allRatings$peteElo)
#0.9746733

### rank ###
allRatings2<-as.data.frame(cbind(allRatings$imageId, rank(allRatings$allScore),rank(allRatings$karynElo),rank(rawData$mikeElo),rank(rawData$paulElo),rank(rawData$peteElo),rank(rawData$susanElo)))
expMap5<-c("V1"="imageID","V2"="consensus","V3"="karyn","V4"="mike", "V5"="paul", "V6"="pete", "V7"="susan")
allRatingsRank <-plyr::rename(rawData2,expMap5 )

cor(allRatingsRank$consensus,allRatingsRank$karyn, method="spearman")
# 0.9685689
cor(allRatingsRank$consensus,allRatingsRank$paul, method="spearman")
# 0.9822142
cor(allRatingsRank$consensus,allRatingsRank$mike, method="spearman")
#0.9744254
cor(allRatingsRank$consensus,allRatingsRank$susan, method="spearman")
# 0.9542154
cor(allRatingsRank$consensus,allRatingsRank$pete, method="spearman")
# 0.9681608

cor(allRatingsRank$consensus,allRatingsRank$karyn)
#0.9685689
cor(allRatingsRank$consensus,allRatingsRank$paul)
#0.9822142
cor(allRatingsRank$consensus,allRatingsRank$mike)
#0.9744254
cor(allRatingsRank$consensus,allRatingsRank$susan)
#0.9542154
cor(allRatingsRank$consensus,allRatingsRank$pete)
#0.9746733


allRatingsRev<-as.data.frame(cbind(allRatings$imageId, rank(allRatings$allScore, decreasing=TRUE),order(allRatings$karynElo,decreasing=TRUE),order(rawData$mikeElo, decreasing=TRUE),order(rawData$paulElo, decreasing=TRUE),order(rawData$peteElo, decreasing=TRUE),order(rawData$susanElo, decreasing=TRUE)))
expMap5<-c("V1"="imageID","V2"="consensus","V3"="karyn","V4"="mike", "V5"="paul", "V6"="pete", "V7"="susan")
allRatingsRank <-plyr::rename(rawData2,expMap5 )




M <- cor(allRatings[,2:7])
corrplot(M, order = "hclust")
corrplot(M, order = "FPC", method = "color")
corrplot(M, order = "FPC", method =  "shade")


M

corrplot.mixed(M)
, order = "FPC", method = "color")
write.csv(allRatings,file="allRankings34.csv")


