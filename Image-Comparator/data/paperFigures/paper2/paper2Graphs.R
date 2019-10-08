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
library(reshape2)
#library(caret)
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
setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34")

classRes <- read.csv('34classify_forR_kappa.csv')
classRes$imageID <- factor(classRes$imageId)
experts8 <- c( "mikeS", "mikeR", "kelly","mike", "paul","kim", "phil","jim")
experts6 <- c( "mikeS", "mikeR",  "kelly", "mike", "paul","jim")
#experts6 <- c( "mikeS",  "kelly", "mikeR", "mike", "paul","jim")

expertClass6<-classRes[experts6]
expMap8<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5","kim"="expert6","phil"="expert7","jim"="expert8")
expMap6<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5", "jim"="expert8")
expMap6<-c("mikeS"="exp1","mikeR"="exp2","kelly"="exp3","mike"="exp4", "paul"="exp5", "jim"="exp8")


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

kappaSq_w2<-kappaSq_w[lower.tri(kappaSq_w)]

minKappaw<-min(kappaSq_w2)
maxKappaw<-max(kappaSq_w2)
aveKappaw<-mean(kappaSq_w2)

melted_cormat <- melt(kappaSq_w)


#http://stackoverflow.com/questions/12834802/non-linear-color-distribution-over-the-range-of-values-in-a-geom-raster
p <- ggplot(data = kappaM, aes(x=user1, y=user2, fill=kappa_eq)) + geom_tile()
p
p<-p+scale_fill_continuous(low="white", high="darkblue", name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
#p<-p+scale_fill_continuous(low="white", high="black", name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))

#p<-p+scale_fill_continuous(low="darkblue", high="white", name="Weighted\nKappa", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
#p<- p+labs(x="Rater 1",  y = "Rater 2", title="Heat map of weighted \n kappas for dataset B")
p<- p+labs(x="Rater 1",  y = "Rater 2")

p

p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p
p<-p+ theme(legend.title= element_text(size=20), legend.text = element_text(size=20))
p
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
p
#p<-p+geom_text(aes(user1, user2, label = round(kappa_eq,2)), color = "black", size = 8)
#p


#########confusion matrix#######
ref = matrix(newRatings6$expert3, ncol=1)
pred = matrix(newRatings6$expert8, ncol=1)
table(ref, pred)


##############heat map for rank correlations

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")
#setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/compare/set34")

compareRes <- read.csv('set34_compare_rev3_forR.csv')

#toKeep8 <- c("taskId","img0Id","img1Id","img0Name","img1Name","mikeS", "mikeR", "kelly", "mike", "paul", "kim", "phil", "jim")
toKeep6 <- c("taskId","img0Id","img1Id","img0Name","img1Name","mikeS", "mikeR", "kelly", "mike", "paul", "jim")

expertCompare6<-compareRes[toKeep6]
#expMap8<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5","kim"="expert6","phil"="expert7","jim"="expert8")
expMap6<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3","mike"="expert4", "paul"="expert5", "jim"="expert8")
expMap6<-c("mikeS"="exp1","mikeR"="exp2","kelly"="exp3","mike"="exp4", "paul"="exp5", "jim"="exp8")

newCompares6 <-plyr::rename(expertCompare6,expMap6 )

#compareRes$taskId <- factor(compareRes$taskId)
#compareRes_long <- gather(newCompares6, user, winner, expert1:expert8)
compareRes_long <- gather(newCompares6, user, winner, exp1:exp8)

#write.csv(compareRes_long,file="34classify_long_final6_anon.csv",sep = ",")
users <-unique(compareRes_long$user)

allData<-compareRes_long[,c(1,2,3,6,7)]
allData[allData== -1] <- 0
allData[allData=="" ] <- NA
allData <- allData[!(allData$winner == "" | is.na(allData$winner)), ]
allData2<-allData[,c(1,2,3,5)]
allElo<-elo(allData2)
allElo

#fname <- paste0("all_6","Elo.csv")
ratingsA <-as.data.frame(allElo$ratings)
#write.csv(ratingsA,file=fname)

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
MS <- cor(allRatings[,3:8], method ="spearman")
MP <- cor(allRatings[,3:8])
MS2<-MS[lower.tri(MS)]
MP2<-MP[lower.tri(MP)]

minCC<-min(MS2)
maxCC<-max(MS2)
aveCC<-mean(MS2)

melted_cormatS <- melt(MS)
melted_cormatP <- melt(MP)



#http://stackoverflow.com/questions/12834802/non-linear-color-distribution-over-the-range-of-values-in-a-geom-raster
p <- ggplot(data = melted_cormatS, aes(x=Var1, y=Var2, fill=value)) + geom_tile()
p
#p<-p+scale_fill_continuous(low="darkblue", high="white", name="Correlation coefficient  \n of estimated ranks", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))
p<-p+scale_fill_continuous(low="white", high="darkblue", name="Correlation coefficient  \n of estimated ranks", limits = c(0,1), breaks=c(0, .2, .4, .6, .8,1))

p
#p<- p+labs(x="Rater 1",  y = "Rater 2", title="Heat map of weighted \n kappas for dataset B")
p<- p+labs(x="Rater 1",  y = "Rater 2")
p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
#p<-p+geom_text(aes(Var1, Var2, label = round(value,2)), color = "black", size = 4)
p

##################expert 1 vs 8 ranks################
lm_eqn = function(m) {
  
  l <- list(a = format(coef(m)[1], digits = 2),
            b = format(abs(coef(m)[2]), digits = 2),
            r2 = format(summary(m)$r.squared, digits = 3));
  
  if (coef(m)[2] >= 0)  {
    eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,l)
  } else {
    eq <- substitute(italic(y) == a - b %.% italic(x)*","~~italic(r)^2~"="~r2,l)    
  }
  
  as.character(as.expression(eq));                 
}

  
p<- ggplot(allRatings, aes(x=rank(expert2), y=rank(expert8))) + geom_point(size=3) +   geom_smooth(method=lm,  se=FALSE)    
p<-p+theme_bw()
p<- p+labs(x="Rank for Expert 3",  y = "Rank for Expert 8")
p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p
#p<-p+ geom_text(aes(x = 5, y = 20, label = lm_eqn(lm(rank(expert8) ~rank(expert3), allRatings))), parse = TRUE)
fit <- lm(rank(expert8) ~ rank(expert2), data = allRatings)
p<-p+labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                   "Intercept =",signif(fit$coef[[1]],5 ),
                   " Slope =",signif(fit$coef[[2]], 5),
                   " P =",signif(summary(fit)$coef[2,4], 5)))
p



#######################rank on set 100#############################################################
rawData <- read.csv("~/Documents/retinalImaging/website/Image-Comparator/data/resultsScripts/R/rank_grade_5_4_2015.csv")
rawData <- read.csv("~/Syncplicity/retinalImaging/website/Image-Comparator/data/resultsScripts/R/rank_grade_5_4_2015.csv")
setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/paperFigures/Paper2/")
rawData <- read.csv("set100allusersElo.csv")


rgPlot <- ggplot(rawData, aes(x=combinedGrade, y=consensusRank)) +
  geom_boxplot()
rgPlot <- rgPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgPlot



sc <-ggplot(rawData) + geom_point(aes(x=mike, y=paul, colour=factor(combinedGrade), size=4))
sc <- sc + theme(legend.position="none")
sc


grplot<-ggplot(rawData) +geom_point(aes(x=consensusRank, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("consensus Rank") + ylab("grade") + theme(legend.position="none")
grplot

rawLong <- melt(rawData, id.vars = c("origin", "combinedGrade","consensusRank"),
                variable.name = "ranker", 
                value.name = "rank")

p <- ggplot(rawLong, aes(consensusRank, rank))
# A basic scatter plot
p<-p + geom_point(aes(colour = factor(combinedGrade), shape=factor(ranker)), size = 4)+theme_bw()
p<- p+labs(x="Consensus rank of all 5 raters",  y = "Rater rank")
p
p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
p


##### classification rank vs. comparison rank set 34
setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/paperFigures/Paper2/")
rank_grade <- read.csv("set34_RankComp_6exp.csv")


p <- ggplot(rank_grade, aes(rankElo, rank))
# A basic scatter plot
p<-p + geom_point(aes( color=factor(RSD)), size = 4)+theme_bw()#theme_classic()#
p
p<-p + geom_point(aes( shape=factor(RSD)), size = 4)+scale_shape_manual(values=c(1,16,16))
p<-p+ scale_colour_grey(start = 0.9, end = .3) 
p
p<- p+labs(x="Comparison rank",  y = "Classification rank")
p
p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
p

p + scale_shape_discrete(name  ="RSD",breaks=c("1", "2","3"), labels=c("1", "2","3"))

cor(rank_grade$rank,rank_grade$rankElo)
cor.test(rank_grade$rank,rank_grade$rankElo)

##
p<-ggplot(data = rank_grade,aes(x= rankElo, y = rank))  
p<-p + geom_point(aes( color=factor(RSD), shape = factor(RSD)), size = 4)+theme_bw()#theme_classic()#
p<-p+  scale_colour_manual(name = "RSD",
                      labels = c("normal", "pre-plus", "plus"),
                      values = c("gray50",  "gray80", "black")) 
p<-p+ scale_shape_manual(name = "RSD",
                         labels = c("normal", "pre-plus", "plus"),
                     values = c(1, 16, 16))
p<- p+labs(x="Comparison rank",  y = "Classification rank")

p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
#p<-p+ theme(plot.title = element_text(face="bold", size=30))
p
#### new consensus rank using all ELO
setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/paperFigures/Paper2/")
rawData <- read.csv("set100allusersElo.csv")
#rawData2<-as.data.frame(cbind(rawData$imageId,rawData$grade, rank(-rawData$allScore),rank(-rawData$mikeElo),rank(-rawData$paulElo),rank(-rawData$peteElo),rank(-rawData$karynElo), rank(-rawData$susanElo)))
rawData2<-as.data.frame(cbind(rawData$imageId,rawData$numGrade, rank(rawData$allScore),rank(rawData$mikeElo),rank(rawData$paulElo),rank(rawData$peteElo),rank(rawData$karynElo), rank(rawData$susanElo)))

#expMap5<-c("V1"="imageID","V2"="consensus","V3"="karyn","V4"="mike", "V5"="paul", "V6"="pete", "V7"="susan")
expMap5<-c("V1"="imageID","V2"="numGrade","V3"="consensus","V4"="exp4", "V5"="exp5", "V6"="phys1", "V7"="crc1","V8"="crc2")

rankData <-plyr::rename(rawData2,expMap5 )
#write.csv(rankData,file="set100Ranks.csv",sep = ",")

MS <- cor(rankData[,2:7], method ="spearman")
MP <- cor(rankData[,2:7])
MS2<-MS[lower.tri(MS)]
MP2<-MP[lower.tri(MP)]

minCC<-min(MS2)
maxCC<-max(MS2)
aveCC<-mean(MS2)



rawLong <- melt(rankData, id.vars = c("imageID", "consensus","numGrade"),
                variable.name = "ranker", 
                value.name = "rank")

p <- ggplot(rawLong, aes(consensus, rank))
# A basic scatter plot
p<-p + geom_point(aes(colour = factor(numGrade), shape=factor(ranker)), size = 2)+theme_bw()
p<- p+labs(x="Consensus ranks",  y = "Individual ranks")
p
#p<-p+  scale_colour_manual(name = "RSD", 
                           labels = c("normal", "pre-plus", "plus"),
                           values = c("gray80", "gray50", "black")) 

p<-p+scale_colour_discrete(limits=c(1, 3))


p<-p+ scale_shape_manual(name = "Rater",
                         labels = c("exp4", "exp5", "phys1", "crc1","crc2"),
                         values = c(1, 2,3,4,5))
p

p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
#p<-p+ theme(plot.title = element_text(face="bold", size=30))



############regression scores###################
setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/paperFigures/Paper2/")
rawData <- read.csv("regScores.csv")

p <- ggplot(rawData, aes(y=regressionScore, x=rank))
p<-p + geom_point(aes(colour = factor(class)), size = 4)+theme_bw()
p<-p+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
p<-p+ theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15))
p<-p+ theme(legend.title= element_text(size=15), legend.text = element_text(size=15))
p<- p+labs(x = NULL, y="Regression score")
p<- p+scale_colour_manual(name = "RSD", labels = c("normal", "pre-plus", "plus"),values= c("gray80", "gray50", "black"))
p<-p+theme(axis.text.x=element_blank(),axis.ticks.x=element_blank())
p
axis.title.x=element_blank(),

p