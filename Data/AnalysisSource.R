
library(repmis)

possibles <- c('~/GitHub/Climate-Happiness', 
               '~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness')
set_valid_wd(possibles)

source('Data/SourceFile.R')

set_valid_wd(possibles)

data2 <- read.csv("All_Merged_Data.csv")
attach(data2)


## Descriptive Statistics


names(data2)
summary(State)

aggregate(formula=satis_labels~Emissions+Year+State, data=data2, FUN=mean)
satislabelmeans <- aggregate(formula=satis~Year+State, data=data2, FUN=mean)

data2[data2$State=="Berlin", ]


#The data has a wide range in terms of the number of observations for each federal state. If we look a little closer, separating them by year, we see that some states are missing observations for a few years. Using Saarland, Nordrhein-Westfalen, and Hamburg in our analysis may require some adjustment with the missing years in mind.


table(State, Year)

#The data has a wide range in terms of the number of observations for each federal state. If we look a little closer, separating them by year, we see that some states are missing observations for a few years. Using Saarland, Nordrhein-Westfalen, and Hamburg in our analysis may require some adjustment with the missing years in mind.


table(State, Year)


#Because we are looking at emissions and happiness over a period of years, the values of emissions for each state also vary, which we can see by state and over time. The colors are coordinated between the box plots and line graphs.


#Boxplot of emissions levels by state
ggplot(data2, aes(x=State, y=Emissions), main = "Emissions by State", xlab = "State", ylab = "Emissions (annual tons of CO2 per capita)") +geom_boxplot(aes(fill=factor(State))) + scale_colour_discrete() + theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + guides(fill=FALSE)



# Line graph of emissions levels by state over time
ggplot(data2, aes(x = Year, y = Emissions, group = State, color = State)) + geom_line() + scale_colour_discrete() +labs(y = "Emissions (annual tons of CO2 per capita)")



#The main explanatory variable of interest is life satisfaction. As with emissions, there is variation within each state and the variation in life satisfaction across years. The following charts use the mean of the individual observations from each state. 


#Boxplot of life satisfaction by state 
ggplot(data2, aes(x=State, y=satis), main = "Average Life Satisfaction by State", xlab = "State", ylab = "Satisfaction") +geom_boxplot(aes(fill=factor(State))) + scale_colour_discrete() + theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + guides(fill=FALSE)



aggremeans <- aggregate(data2[, c(3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22)], list(State, Year), mean)
ggplot(aggremeans, aes(x=Group.2, y=satis, group = Group.1, color = Group.1)) + geom_line() + scale_colour_discrete() +labs(y = "Life Satisfaction")

#Again using the means of each state, we can create some scatterplots showing correlation between variables. Life satisfaction appears to be positively correlated with age, energy use, and concern about the environment, but does not show a strong correlation with emissions. 


# scatterplots of aggregate state satisfaction over years
ggplot(data = aggremeans, aes(x=age, y=satis)) + geom_point() +geom_smooth(method = lm, se = FALSE) + labs(x = "Age", y = "Life Satisfaction") + theme(panel.background = element_rect(fill = "white"),
                                                                                                                                                       axis.line = element_line(colour = "blue", size = 2))
ggplot(data = aggremeans, aes(x=Emissions, y=satis)) + geom_point() +geom_smooth(method = lm, se = FALSE) + labs(x = "Emissions per Capita", y = "Life Satisfaction")

ggplot(data = aggremeans, aes(x=environ, y=satis)) + geom_point() +geom_smooth(method = lm, se = FALSE) + labs(x = "Concern about the Environment", y = "Life Satisfaction")

#Inferential Statistics

#To run inferential statistics, we first create "pdataind" as panel data. For the models below, X1 represents the explanatory  variables of interest: emissions, energy use, concern for the environment, gender, and age. Emissions has a wide range: from 4.5 up to 31.6 annual tons of CO2 per capita. Observations in the upper range may be outliers that need to be removed; half of the observations fall between 6.5 and 13.7 tons, and the median is 7.6 compared to a mean of 10.2 tons. Energy use also varies widely, from 79.3 to 337.0 annual gigajoules (GJ) per capita, with a median of 164.0 and mean of 172.3 GJ. Concern for the environment, measured on a scale from 1 (very) to 3 (not very), has an average of 1.8. Gender is almost evenly split between males and females, and the average age is about 50 years old. 


##Regression using individual level data

#Declare X and Y variables for panel data
Y1<-cbind(satis)
X1<-cbind(Emissions, environ, gender, age)

#set data as panel data
pdataind<-plm.data(data2, index=c("pid","Year"))

summary(X1, digits = 2)


#Y1 represents "satis" (life satisfaction), measured on a scale ranging from 0 (low) to 10 (high). The data is skewed toward the upper range, with the majority of responses being more than 6 and with a mean of 6.9.

 
summary(Y1, digits = 2)




#Below, we tested various types of panel data models on our individual-level data. The data set is unbalanced because we don't have information for all years in all the states.


#pooled OLS estimator

L1<-plm(Y1~X1, data=pdataind, model="pooling")
summary(L1)

#between estimator

L2<-plm(Y1~X1, data=pdataind, model="between")
summary(L2)

#first difference estimator

L3<-plm(Y1~X1, data=pdataind, model="fd")
summary(L3)

#fixed effects or within estimator

L4<-plm(Y1~X1, data=pdataind, model="within")
summary(L4)

#LM test for fixed effects vs OLS

pFtest(L2,L1)

library(stargazer)
stargazer(L1, L2, L3, L4,
    title = 'Regression Estimates of Life Satisfaction',
    digits = 2, type = 'html'
    )



#In terms of explanatory power, the first difference and within estimators might be less useful than the between or pooled OLS estimators, based on their low R-squared and adjusted R-squared Values. Interestingly, gender does not appear to have a significant effect on reported life satisfaction in any of the models. The other variables are statistically significant in all the models. For variables other than gender, the directions of the relationships are also the same across models: emissions and age have negative coefficients, while concern about the environment and energy use have positive coefficients. 

#We can compare the fixed effects/within and pooled OLS models using an F-test for individual and/or time effects:


#LM test for fixed effects vs OLS

pFtest(L4,L1)



#The test is set up so that the null hypothesis is that OLS pooled is better than the within estimator. The small resulting p-value indicates that despite the larger R-squared values with OLS pooling, we should reject the null hypothesis that OLS pooling is better. 


#Multilevel Analysis: Basic Steps

#Multilevel Coefficient Models (MCM, *multilevel* and *nlme* packages) appear as one of the options to proceed with the multilevel analysis. MCM examines individual variation within and across groups, as well as permits non-independence of individual factors from the group level variables. The first step of the MCM investigates whether statistically significant variation between Bundeslaender in terms of mean individual satisfaction exists. Otherwise, simpler OLS and panel-data models are more applicable for the given research. 

#An unconditional model, *Null.Model*, serves the first purpose: the model only controls for the State that specifies that the variation intercept is a function of residence.


Null.Model<-lme(satis~1,random=~1|Stateid,data=data,
                  control=list(opt="optim"))
VarCorr(Null.Model)


#The model examines how much of the average individual life satisfaction is explained by the residence of a respondent through R's general purpose optimization routine (opt="optim"). According to the *Null.Model*, the Bundesland variation (intercept variance) is 0.19, while the within-State residual is 3.17. 


GREL.DAT<-GmeanRel(Null.Model)
names(GREL.DAT)
mean(GREL.DAT$MeanRel)
Null.Model.2<-gls(satis~1,data=data2,
                    control=list(opt="optim"))
logLik(Null.Model.2)*-2
logLik(Null.Model)*-2
sigtest <- round((logLik(Null.Model.2)*-2)-(logLik(Null.Model)*-2), digits=3)


#Furthermore, the *GmeanRel* function (*multilevel* package) yields the mean reliability of 16 Bundeslaender, which, in this case, is substantially high (`r round(mean(GREL.DAT$MeanRel), digits=3)`). As the cut-off point for acceptable reliability is 0.7, Bindeslaeander group reliability meets the threshold. The difference between the -2 log likelihood values of *Null.Model* and *Null.Model.2* tests whether the between-State effect is present compared to the random variation in life satisfaction without any control variables. According to the results, the difference is significantly large based on the Chi-Squared distribution with 2 degrees of freedom (`r sigtest`). These results suggest that there is significant State variation in happiness level, which justifies the usage of the MCM. 

#The second step of the MCM looks into how both Bundesland emissions and subjective concerns about the environment influence reported individual life satisfaction. *Model.1* (*lme* function) for the time being does not control for individual characteristics, such as gender, age, employment and family status. Moreover, percentage of the renewables (which is anticipated to directly relate to the life satisfaction) will be also examined in the later phase of the research. *Model.1* serves as the basic tool to understand relationship between the group- and individual-level factors representing the environment. 

Model.1<-lme(satis~environ+Emissions,random=~1|Stateid,data=finaldata,
             control=list(opt="optim"))

summary(Model.1)


#The output demonstrates that the State emissions are indeed negatively related to the individual happiness. However, after controlling for the individual environmental concerns, the coefficient (-0.005) is not statistically significant. Consequently, the group-level effect does not significantly differ from the individual-level. On the other hand, the coefficient of environmental concerns statistically differs from 0, but the direction is oddly positive counter the expectations. These results point at the omitted variables (absence of the demographic characteristics) that should be included in the further model. Similarly, the surprising direction of the environmental coefficient demands investigation of endogeneity between reported happiness and environmental concerns. 

#A brief overview of *Model.2*, which covers demographic characteristics, reassures the anticipation about the State emissions: the coefficient became significant after controlling for other individual factors. As a result, the difference between State- and individual-level slopes exists and permit multilevel analysis. However, the coefficient of environmental concerns is still positive, which is to be discussed together with other factors in the final paper. 


