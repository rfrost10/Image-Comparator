library(ggplot2)
library(reshape2)
setwd("~/Documents/retinalImaging/website/Image-Comparator/data/resultsScripts/R")

rawData <- read.csv("rank_grade_5_4_2015.csv")

boxplot(consensusRank~combinedGrade, data=rawData)

rG <-aov(consensusRank~combinedGrade, data=rawData)
summary(rG)


plot(rawData$karyn, as.factor(rawData$combinedGrade))

rgPlot <- ggplot(rawData, aes(x=combinedGrade, y=consensusRank)) +
  geom_boxplot()
rgPlot <- rgPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgPlot

rgpPlot <- ggplot(rawData, aes(x=combinedGrade, y=paul)) +
  geom_boxplot()
rgpPlot <- rgpPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgpPlot

rgmPlot <- ggplot(rawData, aes(x=combinedGrade, y=mike)) +
  geom_boxplot()
rgmPlot <- rgmPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgmPlot

rgsPlot <- ggplot(rawData, aes(x=combinedGrade, y=susan)) +
  geom_boxplot()
rgsPlot <- rgsPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgsPlot

rgptPlot <- ggplot(rawData, aes(x=combinedGrade, y=pete)) +
  geom_boxplot()
rgptPlot <- rgptPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgptPlot

rgkPlot <- ggplot(rawData, aes(x=combinedGrade, y=karyn)) +
  geom_boxplot()
rgkPlot <- rgkPlot + scale_x_discrete(limits=c("normal","Pre","Plus"))
rgkPlot


sc <-ggplot(rawData) + geom_point(aes(x=mike, y=paul, colour=factor(combinedGrade), size=4))
sc <- sc + theme(legend.position="none")
sc


grplot<-ggplot(rawData) +geom_point(aes(x=karyn, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("karyn rank") + ylab("grade") + theme(legend.position="none")
grplot

grplot<-ggplot(rawData) +geom_point(aes(x=paul, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("paul rank") + ylab("grade") + theme(legend.position="none")
grplot

grplot<-ggplot(rawData) +geom_point(aes(x=pete, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("pete rank") + ylab("grade") + theme(legend.position="none")
grplot

grplot<-ggplot(rawData) +geom_point(aes(x=susan, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("susan rank") + ylab("grade") + theme(legend.position="none")
grplot

grplot<-ggplot(rawData) +geom_point(aes(x=mike, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("mike rank") + ylab("grade") + theme(legend.position="none")
grplot

grplot<-ggplot(rawData) +geom_point(aes(x=consensusRank, y=as.factor(combinedGrade),colour = "red", size = 3))
grplot <- grplot + scale_y_discrete(limits=c("normal","Pre","Plus"))
grplot<- grplot+ xlab("consensus Rank") + ylab("grade") + theme(legend.position="none")
grplot

rawLong <- melt(rawData, id.vars = c("origin", "combinedGrade","consensusRank"),
            variable.name = "ranker", 
            value.name = "rank")

p <- ggplot(rawLong, aes(consensusRank, rank))
# A basic scatter plot
p + geom_point(aes(colour = factor(combinedGrade), shape=factor(ranker)), size = 4)+theme_bw()


## group separability
rawData$num=as.numeric(rawData[,2])
source("rFunctions.R")
calcSeparations(rawData[3:8],rawData[9])    


                            
