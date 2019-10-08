rm(list=ls())
library(tidyr)
library(ggplot2)
library(irr)
library(plyr)
library(dplyr)
#setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set100")
#setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/classify")

setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/paperFigures/paper1")

pred <- read.csv('pred_act.csv')

g<-ggplot(pred, aes(x=avg_34, y=pred_34, shape=expert)) + geom_point(size=4) + scale_shape_manual(values=seq(0,15)) +theme_bw()

g<- g+labs(x="average rating of 34 images",  y = "Predicted average", title="Predicted versual actual average rating by expert on dataset B")
g


g2<-ggplot(pred, aes(x=avg_100, y=pred_100, shape=expert)) + geom_point(size=4) + scale_shape_manual(values=seq(0,15)) +theme_bw()

g2<- g2+labs(x="average rating of 100 images",  y = "Predicted average", title="Predicted versual actual average rating by expert on dataset A")
g2