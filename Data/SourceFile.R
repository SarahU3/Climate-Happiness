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
# but manually downloaded Excel spreadsheets
messynrgprime <- read.xlsx('~/GitHub/Climate-Happiness/Data/export_land_primary.xlsx', 1, startRow = 4, endRow = 21)
messynrgelec <- read.xlsx('~/GitHub/Climate-Happiness/Data/export_land_strom.xlsx', 1, startRow = 4, endRow = 21)

# convert K.D. (keine Daten) to NA
NAs <- messynrgelec == "K.D."
is.na(messynrgelec)[NAs] <- TRUE

# transform to numeric values, need to correct decimal places and loop but major issue: , instead of .
transform(messynrgelec, X1990 = as.numeric(X1990))

# convert data to tidy format (one variable per column) currently doesn't work bc they're not numerical
tidyNRGprime <- gather(messynrgelec, year, percentrenewable, 2:25, na.rm = FALSE, convert = TRUE)
