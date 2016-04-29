
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

Model.1<-lme(satis~environ+Emissions,random=~1|Stateid, data=finaldata,
             control=list(opt="optim"))

summary(Model.1)
VarCorr(Model.1)

Model.2<-lme(satis~environ+Emissions+age+fam+gender+emp,random=~age+fam+gender+emp|Stateid,data=finaldata,
             control=list(opt="optim"))

summary(Model.2)

Model.3<-lme(satis~environ+Emissions+Use+Primary,random=~1|Stateid,data=finaldata,
             control=list(opt="optim"))

Model.4<-lme(satis~environ+age+Emissions,random=~age|Stateid, data=finaldata,
             control=list(opt="optim"))

summary(Model.4)
Model.4a<-update(Model.4,random=~1|Stateid)
(anova(Model.4,Model.4a))$L.Ratio #L.Ratio is the sig test (significant)

# Interaction
Model.I<-lme(satis~environ+emp+age+fam+Emissions+fam*age,
                   random=~1+emp+age+fam|Stateid,data=finaldata,control=list(opt="optim"))

round(summary(Model.I)$tTable,dig=3)

m_fam<-lme(satis~fam*age,
             random=~1+age+fam|Stateid,data=finaldata,control=list(opt="optim"))
library(interplot)
interplot(m = m_fam, var1 = "fam", var2 = "age")
