
setwd('~/GitHub/Climate-Happiness/Data')
source('~/GitHub/Climate-Happiness/Data/SourceFile.R')
attach(finaldata)
Null.Model<-lme(satis~1,random=~1|Stateid,data=data,
                  control=list(opt="optim"))
VarCorr(Null.Model)

GREL.DAT<-GmeanRel(Null.Model)
names(GREL.DAT)
mean(GREL.DAT$MeanRel)

Null.Model.2<-gls(satis~1,data=data,
                    control=list(opt="optim"))
logLik(Null.Model.2)*-2
logLik(Null.Model)*-2
sigtest <- (logLik(Null.Model.2)*-2)-(logLik(Null.Model)*-2) #variation is significant
anova(Null.Model,Null.Model.2)

Model.1<-lme(satis~environ+Emissions+Use+Elec+Primary,random=~1|Stateid,data=data,
             control=list(opt="optim"))

summary(Model.1)


