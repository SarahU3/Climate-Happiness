### Multilevel Analysis ###
# Note: multilevel analysis is conducted on a full dataset (w/out income) and on a reduced dataset (w/income).
# data denotes the full dataset, while the finaldata stands for the reduced dataset. 

setwd('~/GitHub/Climate-Happiness/Data')
source('~/GitHub/Climate-Happiness/Data/SourceFile.R')
data <- data
finaldata <- finaldata

### 1. Full dataset MCM ###
attach(data)

# Step 1. Indicate differences between the states
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

# Step 2. Run a model to see between-the-state variation
Model.1<-lme(satis~environ+CO2perSqKm,random=~1|Stateid, data=data,
             control=list(opt="optim"))

summary(Model.1)
VarCorr(Model.1)

# Step 3. Run a model to see wihtin-the-state variation
Model.2<-lme(satis~environ+CO2perSqKm+age+fam+gender+emp,random=~age+fam+gender+emp+CO2perSqKm|Stateid,data=data,
             control=list(opt="optim"))

summary(Model.2)

Model.2a<-update(Model.2,random=~1|Stateid)
(anova(Model.2,Model.2a))$L.Ratio #L.Ratio is the sig test (significant)

### 2. Income dataset (finaldata) ###
attach(finaldata)
Null.Model_i<-lme(satis~1,random=~1|Stateid, data=finaldata,
                control=list(opt="optim"))
GREL.DAT<-GmeanRel(Null.Model)
x <- round(mean(GREL.DAT$MeanRel), digits=3)

Null.Model.2_i<-gls(satis~1,data=finaldata,
                  control=list(opt="optim"))
sigtest <- (logLik(Null.Model.2_i)*-2)-(logLik(Null.Model_i)*-2) #variation is significant

Model.3<-lme(satis~environ+CO2perSqKm+GrossIncome+gender+age+fam,random=~GrossIncome+gender+age+fam|Stateid,data=data,
             control=list(opt="optim")) 
summary(Model.3)
Model.3a<-update(Model.3,random=~1|Stateid)
(anova(Model.3,Model.3a))$L.Ratio #L.Ratio is the sig test (significant)


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




