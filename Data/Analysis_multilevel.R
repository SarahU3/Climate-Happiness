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
Model.2<-lme(satis~environ+CO2perSqKm+age+fam+gender+emp,random=~gender+age+CO2perSqKm+environ|Stateid,data=data,
             control=list(opt="optim"))

summary(Model.2)
Model.2a<-update(Model.2,random=~1|Stateid)
(anova(Model.2,Model.2a))$L.Ratio #L.Ratio is the sig test (significant)
coef(Model.2)

Model.2b<-lme(satis~environ+Emissions+age+fam+gender+emp,random=~gender+age+Emissions+environ|Stateid,data=data,
              control=list(opt="optim"))
coef(Model.2b)

### 2. Income dataset (finaldata) ###
attach(finaldata)
Null.Model_i<-lme(satis~1,random=~1|Stateid, data=finaldata,
                control=list(opt="optim"))
GREL.DAT_i<-GmeanRel(Null.Model)
x_i <- round(mean(GREL.DAT$MeanRel), digits=3)

Null.Model.2_i<-gls(satis~1,data=finaldata,
                  control=list(opt="optim"))
sigtest_i <- (logLik(Null.Model.2_i)*-2)-(logLik(Null.Model_i)*-2) #variation is significant

Model.3<-lme(satis~environ+CO2perSqKm+GrossIncome+gender+age+fam,random=~environ+CO2perSqKm+GrossIncome+gender|Stateid,data=finaldata,
             control=list(opt="optim")) 
summary(Model.3)
plot(ranef(Model.3))
plot(ranef(Model.3), aug=TRUE)


Model.3a<-update(Model.3,random=~1|Stateid)
(anova(Model.3,Model.3a))$L.Ratio #L.Ratio is the sig test (significant)

Model.3b<-lme(satis~environ+Emissions+GrossIncome+gender+age+fam,random=~environ+CO2perSqKm+GrossIncome+gender|Stateid,data=finaldata,
             control=list(opt="optim")) 
coef(Model.3b)

### 3. Interactions ###
Model.Income<-lme(satis~environ+CO2perSqKm*GrossIncome+age+fam+gender,
                   random=~1+environ+CO2perSqKm*GrossIncome|Stateid,data=finaldata,control=list(opt="optim"))
round(summary(Model.Income)$tTable,dig=5)

Model.age<-lme(satis~emp+fam+environ+CO2perSqKm*age,
             random=~1+environ+CO2perSqKm*age|Stateid,data=data,control=list(opt="optim"))
round(summary(Model.age)$tTable,dig=5)

Model.environ<-lme(satis~fam+gender+environ*GrossIncome+CO2perSqKm+age,
               random=~1+environ*GrossIncome|Stateid,data=finaldata,control=list(opt="optim"))
round(summary(Model.environ)$tTable,dig=5)


# stargazer::stargazer(Lpooled, Lfixeff, single.row = TRUE, dep.var.labels = "Life Satisfaction", 
#                      title = '', dep.var.caption = '', 
#                      digits = 2, type = 'html')
# 
# stargazer::stargazer(Model.1, single.row = TRUE,
#                      dep.var.labels = "Life Satisfaction",
#                      title = 'BETWEEN variation',
#                      digits = 2, type = 'html')
model.01 <-lme(satis~CO2perSqKm,random=~CO2perSqKm|Stateid, data=data, control=list(opt="optim"))

pframe_carbon <- with(data,
               expand.grid(Stateid=levels(Stateid),
                           CO2perSqKm=seq(min(CO2perSqKm),max(CO2perSqKm),length=51)))
pframe_carbon$satis <- predict(model.01,newdata=pframe_carbon,level=1)
install.packages("lattice")
library(lattice)
xyplot(satis~CO2perSqKm,group=Stateid,data=pframe,type="l")

library("ggplot2")
ggplot(data,aes(CO2perSqKm,satis,colour=Stateid))+
  geom_point()+
  geom_line(data=pframe_carbon)

data$environ <- as.numeric(as.character(data$environ))

model.02 <-lme(satis~environ,random=~environ|Stateid, data=data, control=list(opt="optim"))

pframe <- with(data,
               expand.grid(Stateid=levels(Stateid),
                           environ=seq(min(environ),max(environ),length=3)))
                           
pframe$satis <- predict(model.02,newdata=pframe,level=1)
xyplot(satis~environ,group=Stateid,data=pframe,type="l")

ggplot(data,aes(environ,satis,colour=Stateid))+
  geom_point()+
  geom_line(data=pframe)

### Interaction effects plot ###
library(effects)
Model.2<-lme(satis~environ+CO2perSqKm+age+fam+gender+emp,random=~gender+age+CO2perSqKm+environ|Stateid,data=data,
             control=list(opt="optim"))
ef <- effect("CO2perSqKm", Model.2)
x <- as.data.frame(ef)
ggplot(x, aes(CO2perSqKm, fit, color=CO2perSqKm)) + geom_point() + geom_errorbar(aes(ymin=fit-se, ymax=fit+se), width=0.4) + theme_bw(base_size=12)

Model.environ<-lme(satis~fam+gender+environ*GrossIncome+CO2perSqKm+age,
                   random=~1+fam+gender+environ*GrossIncome+CO2perSqKm+age|Stateid,data=finaldata,control=list(opt="optim"))
efenv <- effect("environ*GrossIncome", Model.environ)
xenv <- as.data.frame(efenv)
ggplot(xenv, aes(environ, fit, color=GrossIncome)) + geom_point() + geom_errorbar(aes(ymin=fit-se, ymax=fit+se), width=0.4) + theme_bw(base_size=12)


Model.age<-lme(satis~fam+gender+environ*age+CO2perSqKm+emp,
                   random=~1+environ*age|Stateid,data=data,control=list(opt="optim"))
efage <- effect("environ*age", Model.age)
xage <- as.data.frame(efage)
Modelage <- ggplot(xage, aes(environ, fit, color=age)) + geom_point() + geom_errorbar(aes(ymin=fit-se, ymax=fit+se), width=0.4) + theme_bw(base_size = 12)+
  ylab("Predicted satisfaction values") +
  xlab("Environmental concerns [1-3]")
Modelage + ggtitle("Predicted values for Model 4") +
theme(plot.title = element_text(lineheight=.8, face="bold"))
