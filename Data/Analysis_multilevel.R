
setwd('~/GitHub/Climate-Happiness/Data')
source('~/GitHub/Climate-Happiness/Data/SourceFile.R')
attach(finaldata)
Null.Model<-lme(satis~1,random=~1|Stateid, data=finaldata,
                  control=list(opt="optim"))
VarCorr(Null.Model)

GREL.DAT<-GmeanRel(Null.Model)
names(GREL.DAT)
x <- round(mean(GREL.DAT$MeanRel), digits=3)

Null.Model.2<-gls(satis~1,data=finaldata,
                    control=list(opt="optim"))
logLik(Null.Model.2)*-2
logLik(Null.Model)*-2
sigtest <- (logLik(Null.Model.2)*-2)-(logLik(Null.Model)*-2) #variation is significant
anova(Null.Model,Null.Model.2)

Model.1<-lme(satis~environ+Emissions,random=~1|Stateid,data=finaldata,
             control=list(opt="optim"))

summary(Model.1)
VarCorr(Model.1)

Model.2<-lme(satis~environ+Emissions+age+fam+gender+emp,random=~1|Stateid,data=finaldata,
             control=list(opt="optim"))

summary(Model.2)

Model.3<-lme(satis~environ+Emissions+Use+Primary,random=~1|Stateid,data=finaldata,
             control=list(opt="optim"))
