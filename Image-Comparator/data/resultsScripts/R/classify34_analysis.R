rm(list=ls())

library(tidyr)
library(ggplot2)
library(irr)
library(plyr)
library(reshape2)
#setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34")
setwd("~/Documents/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34")


#classRes <- read.csv('34classify_forR.csv')
classRes <- read.csv('34classify_forR_kappa.csv')
#classRes$imageName <- factor(classRes$imageName)


#setwd("~/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set100")
#classRes <- read.csv('100classify_forR.csv')

classRes$imageID <- factor(classRes$imageID)
#classRes$imageName <- factor(classRes$imageName)


#experts <- c("imageName", "mike", "mikeS", "mikeR", "jim", "kelly", "kim", "phil", "paul")
experts <- c("imageID", "mike", "mikeS", "mikeR", "jim", "kelly", "kim", "phil", "paul")

expertClass<-classRes[experts]

classRes_long <- gather(expertClass, expert, measurement, mike:paul)
#classRes_long <- gather_(classRes, keycol, valuecol,experts)


res.aov <- aov(lm(measurement ~expert+imageID, data =classRes_long))
#res.aov <- aov(lm(measurement ~expert+imageName, data =classRes_long))

res.aov
summary(res.aov)
TukeyHSD(res.aov, "expert", ordered = TRUE)
plot(TukeyHSD(res.aov, "expert"))

TukeyHSD(res.aov)


#fit <- lm(measurement ~expert+imageName, data =classRes_long)
fit <- lm(measurement ~expert+imageID, data =classRes_long)

summary(fit)

coefficients(fit) # model coefficients
confint(fit, level=0.95) # CIs for model parameters 
fitted(fit) # predicted values
residuals(fit) # residuals
anova(fit) # anova table 
vcov(fit) # covariance matrix for model parameters 
influence(fit) # regression diagnostics

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit)


### kappa measurements
library(irr)

ratings <- classRes[c(2:9)]

expMap<-c("mikeS"="expert1","mikeR"="expert2","kelly"="expert3", "mike"="expert4","paul"="expert5","jim"="expert6","kim"="expert7","phil"="expert8")
newRatings <-rename(ratings,expMap )
a<-agree(newRatings,tolerance=0)

kf<-kappam.fleiss(newRatings)

kl<-kappam.light(newRatings)


k2<- kappa2(newRatings[,c(1,8)], weight = c("squared"))
k2<- kappa2(newRatings[,c(1,8)], weight = c("unweighted"))

toKeep <- c( "mikeS","mikeR", "mike",  "paul","jim")
expMap<-c("mikeS"="expert1","mikeR"="expert2","mike"="expert4","paul"="expert5","jim"="expert6")


ratings <- classRes[toKeep]
newRatings <-rename(ratings,expMap )

numRaters <-ncol(newRatings)
users <-colnames(newRatings)

df <- data.frame(matrix(ncol = 4, nrow = (numRaters*(numRaters+1)/2)))
colMap<-c("X1"="user1","X2"="user2","X3"="kappa_unw","X4"="kappa_eq")
kappaM <-rename(df,colMap)
kappaSq_w<-data.frame(matrix(nrow=numRaters,ncol=numRaters))
count=0
for (i in 1:numRaters) {
  for (j in i:numRaters){
    count=count+1 
    kappaM[count,1]<-users[i]
    kappaM[count,2]<-users[j]
    k_unw<- kappa2(newRatings[,c(i,j)], weight = c("unweighted"))
    kappaM[count,3]<-k_unw$value
   # print(k_unw$value)
    k_lin<- kappa2(newRatings[,c(i,j)], weight = c("equal"))
   # print(k_lin$value)
    kappaM[count,4]<-k_lin$value
    kappaSq_w[i,j]<-k_lin$value
    kappaSq_w[j,i]<-k_lin$value
    print(count)
}
}
melted_cormat <- melt(kappaSq_w)

library(ggpot2)
p <- ggplot(kappaM, aes(y=X1,x=X2))
p + geom_tile(aes(fill=value)) + scale_fill_gradient(low="white", high="darkblue") + xlab("") + ylab("")
p <- ggplot(data = kappaM, aes(x=user1, y=user2, fill=kappa_unw)) + geom_tile()
p