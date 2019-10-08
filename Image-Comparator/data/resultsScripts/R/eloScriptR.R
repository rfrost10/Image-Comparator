paulData <- read.csv("results_icl_1_10_paulR.csv")
paulElo<-elo(paulData)
paulElo

mikeData <- read.csv("results_icl_1_10_mikeR.csv")
mikeElo<-elo(mikeData)
mikeElo
hist(mikeElo, xlim = c(1900,2500), density=TRUE)




susanData <- read.csv("results_icl_1_10_susanR.csv")
susanElo<-elo(susanData)
susanElo
hist(susanElo, xlim = c(1900,2500), density=TRUE)



karynData <- read.csv("results_icl_1_10_karynR.csv")
karynElo<-elo(karynData)
karynElo
hist(karynElo, xlim = c(1900,2500), density=TRUE)



allData <- read.csv("results_icl_1_10_allR.csv")
allElo<-elo(allData)
allElo

hist(allElo, xlim = c(1900,2500), density=TRUE)


write.table(allElo, file = "allElo.csv", sep = ",", col.names = NA,
            qmethod = "double")