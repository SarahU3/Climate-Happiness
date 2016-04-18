install.packages("multilevel")
library(multilevel)
install.packages('nlme')
library(nlme)

setwd('~/GitHub/Climate-Happiness/Data')
source('~/GitHub/Climate-Happiness/Data/SourceFile.R')
data <- read.csv("All_Merged_Data.csv")
attach(data)
Null.Model<-lme(satis~1,random=~1|State,data=data,
                  control=list(opt="optim"))
VarCorr(Null.Model)

GREL.DAT<-GmeanRel(Null.Model)
names(GREL.DAT)
mean(GREL.DAT$MeanRel)

Null.Model.2<-gls(satis~1,data=data,
                    control=list(opt="optim"))
logLik(Null.Model.2)*-2
logLik(Null.Model)*-2
anova(Null.Model,Null.Model.2)
