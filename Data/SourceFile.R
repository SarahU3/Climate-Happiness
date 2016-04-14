# Source file for assignment 3 and final projects
# Authors: Katie, Meerim, and Sarah

# load packages
library(dplyr)
library(httr)
library(xlsx)
library(ggplot2)
library(tidyr)
library(repmis)
library(rio)
library(rvest)

# get data on renewable energy in Bundeslaender
URLnrg <- 'http://www.lanuv.nrw.de/liki/index.php?indikator=608&aufzu=1&mode=indi'
setwd("~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository/Data/emissions")
# but manually downloaded Excel spreadsheets
messynrgprime <- read.xlsx('~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository/Data/export_land_primary.xlsx', 1, startRow = 4, endRow = 21)
messynrgelec <- read.xlsx('~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository/Data/export_land_strom.xlsx', 1, startRow = 4, endRow = 21)
messynrguse <- read.xlsx('~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness-Repository/Data/export_land_energyuse.xlsx', 1, startRow = 4, endRow = 21)

# convert K.D. (keine Daten) to NA
NAs <- messynrgelec == "K.D."
is.na(messynrgelec)[NAs] <- TRUE
NAs2 <- messynrgprime == "K.D."
is.na(messynrgprime)[NAs2] <- TRUE
NAs3 <- messynrguse == "K.D."
is.na(messynrguse)[NAs3] <- TRUE

# transform to numeric values, need to correct decimal places and loop but major issue: , instead of .
transform(messynrgelec, X1990 = as.numeric(X1990))

# convert data to tidy format (one variable per column) currently doesn't work bc they're not numerical
NRGprime <- gather(messynrgprime, year, percentrenewable, 2:25, na.rm = FALSE, convert = TRUE)
NRGelec <- gather(messynrgelec, year, percentrenewable, 2:25, na.rm = FALSE, convert = TRUE)
NRGuse <- gather(messynrguse, year, percentrenewable, 2:26, na.rm = FALSE, convert = TRUE)

# Matching labels
colnames(NRGelec) <- c("State", "Year", "PercentRenewable")
colnames(NRGprime) <- c("State", "Year", "PercentRenewable")
colnames(NRGuse) <- c("State", "Year", "PercentRenewable")
NRG <- rbind(NRGprime, NRGelec, NRGuse)

install.packages('gsubfn')
library(gsubfn)

NRG.final <- as.data.frame(sapply(NRG, gsub, pattern="X",replacement=""))
export(NRG.final, file="NRG.final.csv") 

# Make sure Bundeslander match
nrg <- as.data.frame(levels(NRG.final$State))
export(nrg, file="nrg.csv")
# All states should match except the observations for Deutschland - maybe we should drop them out.

