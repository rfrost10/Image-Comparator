rm(list=ls())
library(tidyr)
library(ggplot2)
library(irr)
library(plyr)
library(dplyr)
#setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set100")
#setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/classify")

## set 34
setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/paperFigures/paper1")
classRes <- read.csv('set34_classification_pete.csv')
classRes$imageId <- factor(classRes$imageId)
experts <- c("imageId",  "mikeS", "mikeR", "kelly", "mike","paul","kim", "phil","jim")
expertClass<-classRes[experts]
expMap<-c("imageId"="imageId", "mikeS"="expert1", "mikeR"="expert2", "kelly"="expert3", "mike"="expert4", "paul"="expert5", "kim"="expert6", "phil"="expert7","jim"="expert8")    

expertClassAnon<-plyr::rename(expertClass,expMap )
ratings <- classRes[c(4:11)]
newRatings <-plyr::rename(expertClass,expMap )
classRes_long <- gather(expertClassAnon, expert, measurement, expert1:expert8)

res.aov <- aov(lm(measurement ~expert+imageId, data =classRes_long))
res.aov
summary(res.aov)
TukeyHSD(res.aov, "expert", ordered = TRUE)
plot(TukeyHSD(res.aov, "expert"))
TukeyHSD(res.aov)


fit <- lm(measurement ~expert+imageId, data =classRes_long)
summary(fit)

fit <- lm(measurement ~expert, data =classRes_long)
summary(fit)

pred <- read.csv('pred_anova_set34.csv')
g<-ggplot(pred, aes(x=avgRating, y=predictedRating)) + geom_point(size=6) + scale_shape_manual(values=seq(0,15)) +theme_bw()

g<- g+labs(x="Average user rating for 34 images",  y = "Predicted user rating", title="Predicted vs. average rating \n by expert on dataset B")
g<-g+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
g<-g+ theme(plot.title = element_text(face="bold", size=30))
g


### set 100############

classRes <- read.csv('set100_classification_pete.csv')
classRes$imageId <- factor(classRes$imageId)
experts <- c("imageId",  "mikeS", "mikeR", "kelly", "mike","paul","kim", "phil","jim")
expertClass<-classRes[experts]
expMap<-c("imageId"="imageId", "mikeS"="expert1", "mikeR"="expert2", "kelly"="expert3", "mike"="expert4", "paul"="expert5", "kim"="expert6", "phil"="expert7","jim"="expert8")    

expertClassAnon<-plyr::rename(expertClass,expMap )
ratings <- classRes[c(3:10)]
newRatings <-plyr::rename(expertClass,expMap )
classRes_long <- gather(expertClassAnon, expert, measurement, expert1:expert8)

res.aov <- aov(lm(measurement ~expert+imageId, data =classRes_long))
res.aov
summary(res.aov)
TukeyHSD(res.aov, "expert", ordered = TRUE)
plot(TukeyHSD(res.aov, "expert"))
TukeyHSD(res.aov)


fit <- lm(measurement ~expert+imageId, data =classRes_long)
summary(fit)

pred <- read.csv('pred_anova_set34.csv')
g<-ggplot(pred, aes(x=avgRating, y=predictedRating)) + geom_point(size=6) + scale_shape_manual(values=seq(0,15)) +theme_bw()

g<- g+labs(x="Average user rating for 34 images",  y = "Predicted user rating", title="Predicted vs. average rating \n by expert on dataset B")
g<-g+ theme(axis.title.x = element_text(size=20), axis.title.y = element_text(size=20))
g<-g+ theme(plot.title = element_text(face="bold", size=30))
g

