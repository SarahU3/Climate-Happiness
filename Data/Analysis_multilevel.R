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
model.01 <-lme(fixed=satis~CO2perSqKm+environ,random=~CO2perSqKm|Stateid, data=data)
visualize.lme <- function (model, coefficient, group, ...)
{
  r <- ranef(model)
  f <- fixef(model)
  
  effects <- data.frame(r[,1]+f[1], r[,2]+f[2])
  
  number.lines <- nrow(effects)
  
  predictor.min <- tapply(model$data[[coefficient]], model$data[[group]], min)
  predictor.max <- tapply(model$data[[coefficient]], model$data[[group]], max)
  
  outcome.min <- min(predict(model))
  outcome.max <- max(predict(model))
  
  plot (c(min(predictor.min),max(predictor.max)),c(outcome.min,outcome.max), type="n", ...)
  
  for (i in 1:number.lines)
  {
    expression <- function(x) {effects[i,1] + (effects[i,2] * x) }
    curve(expression, from=predictor.min[i], to=predictor.max[i], add=TRUE)
  }
}

visualize.lme(model.01, "CO2perSqKm", "Stateid", xlab="Environmental concerns", ylab="Satisfaction", main="Satis for all")

