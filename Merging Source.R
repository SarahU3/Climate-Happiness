### R-script for merging excel files for emissions, renewables and gsoep data ###

setwd("~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository")
install.packages("foreign")
library(foreign)

emissions = read.csv("Data/emissions/Final.csv")
GSOEP = read.dta("Data/GSOEP/SOEP_short12.dta")
energy = read.csv("Data/emissions/NRG.final.csv")

fulldata = merge(emissions, GSOEP)
fulldata = merge(fulldata, energy)

export(fulldata, file="All_Merged_Data.csv")
