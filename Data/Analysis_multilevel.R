### Multilevel Analysis ###
# Note: multilevel analysis is conducted on a full dataset (w/out income) and on a reduced dataset (w/income).
# data denotes the full dataset, while the datared stands for the reduced dataset. 

setwd('~/GitHub/Climate-Happiness/Data')
source('~/GitHub/Climate-Happiness/Data/SourceFile.R')

data <- merge(GSOEP, landemissions, by=c("Year","State"))
data <- merge(data, emissions, by=c("Year","State"))
data <-as.data.frame(sapply(data, gsub, pattern="ü",replacement="ue"))
data$satis <- as.numeric(as.character(data$satis))
data[, c(14,15,18,21,22,23,24)] <- sapply(data[, c(14,15,18,21,22,23,24)], as.numeric) # specifying columns to convert into numeric
data$Stateid <- as.numeric(as.factor(data$State))
data$Stateid <- factor( as.numeric(as.factor(data$State)),
                             labels = levels(data$State))
data <- data[,c(1:3,12,14:24)]
names(finaldata) <- c("Year", "State", "pid", "satis_labels", "satis",
                      "environ","Stateid","gender","age","emp","fam","CO2Tons","sqkm",
                      "CO2perSqKm","Emissions")
attach(data)

Null.Model<-lme(satis~1,random=~1|Stateid, data=data,
                  control=list(opt="optim"))
VarCorr(Null.Model)

GREL.DAT<-GmeanRel(Null.Model)
names(GREL.DAT)
x <- round(mean(GREL.DAT$MeanRel), digits=3)

Null.Model.2<-gls(satis~1,data=data,
                    control=list(opt="optim"))
logLik(Null.Model.2)*-2
logLik(Null.Model)*-2
sigtest <- (logLik(Null.Model.2)*-2)-(logLik(Null.Model)*-2) #variation is significant
anova(Null.Model,Null.Model.2)

Model.1<-lme(satis~environ+CO2perSqKm,random=~1|Stateid, data=data,
             control=list(opt="optim"))

summary(Model.1)
VarCorr(Model.1)

Model.2<-lme(satis~environ+CO2perSqKm+age+fam+gender+emp,random=~age+fam+gender+emp|Stateid,data=data,
             control=list(opt="optim"))

summary(Model.2)

Model.3<-lme(satis~environ+Emissions+Use+Primary,random=~1|Stateid,data=data,
             control=list(opt="optim"))

Model.4<-lme(satis~environ+age+Emissions,random=~age|Stateid, data=data,
             control=list(opt="optim"))

summary(Model.4)
Model.4a<-update(Model.4,random=~1|Stateid)
(anova(Model.4,Model.4a))$L.Ratio #L.Ratio is the sig test (significant)

### Income
Model.Income<-lme(satis~environ+CO2perSqKm+plc0013+gender+age+fam,random=~plc0013+gender+age+fam|Stateid,data=data,
             control=list(opt="optim")) 
# employment should be excluded from the income model
summary(Model.Income)

# Interaction
Model.I<-lme(satis~environ+emp+Emissions+fam*age,
                   random=~1+emp+age+fam|Stateid,data=data,control=list(opt="optim"))

Model.I2<-lme(satis~emp+fam+Emissions+environ*age,
             random=~1+emp+fam+environ*age|Stateid,data=data,control=list(opt="optim"))
interplot(m = Model.I2, var1 = "environ", var2 = "age")


round(summary(Model.I2)$tTable,dig=3)

m_fam<-lme(satis~fam*age,
             random=~1+age*fam|Stateid,data=data,control=list(opt="optim"))
library(interplot)
interplot(m = m_fam, var1 = "fam", var2 = "age")


#### Trial for income (conclusion: variaiton is reliable and significant) ###
Null.Model<-lme(satis~1,random=~1|Stateid, data=data2,
                control=list(opt="optim"))
GREL.DAT<-GmeanRel(Null.Model)
x <- round(mean(GREL.DAT$MeanRel), digits=3)

Null.Model.2<-gls(satis~1,data=data2,
                  control=list(opt="optim"))
sigtest <- (logLik(Null.Model.2)*-2)-(logLik(Null.Model)*-2) #variation is significant


