### R-script for merging excel files for emissions, renewables and gsoep data ###

source('~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository/Data/Emissions.R', encoding = 'UTF-8')

source('~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository/Data/SourceFile.R')

setwd("~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository")
install.packages("foreign")
library(foreign)

emissions = read.csv("Data/emissions/Final.csv")
GSOEP = read.csv("GSOEP.csv")
energy = read.csv("Data/emissions/NRG.final.csv")

fulldata = merge(emissions, GSOEP)
fulldata = merge(fulldata, energy)

export(fulldata, file="All_Merged_Data.csv")
