rawData <- read.csv("results_set100_r3b.csv")

allData<-rawData[,1:4]
allElo<-elo(allData)
allElo

paulData <- subset(rawData, rawData$user=="paul")
paulElo<-elo(paulData[,1:4])
paulElo

mikeData <- subset(rawData, rawData$user=="mike")
mikeElo<-elo(mikeData[,1:4])
mikeElo

susanData <- subset(rawData, rawData$user=="susan")
susanElo<-elo(susanData[,1:4])
susanElo


peteData <- subset(rawData, rawData$user=="pete")
peteElo<-elo(peteData[,1:4])
peteElo

karynData <- subset(rawData, rawData$user=="karyn")
karynElo<-elo(karynData[,1:4])
karynElo








a