# Source file for assignment 3 and final projects
# Authors: Katie, Meerim, and Sarah

# load packages
library(dplyr)
library(car) #scatterplots with panel data
library(httr)
library(foreign) #to read .dta files
library(rJava)
library(xlsxjars)
library(xlsx)
library(ggplot2)
library(tidyr) #
library(repmis)
library(rio)
library(xml2)
library(rvest)
library(psych) #multilevel analysis
library(plm) #panel data regression
library(gsubfn) #replacing characters
getwd()
setwd('~/GitHub/Climate-Happiness/Data')
# get data on renewable energy in Bundeslaender
URLnrg <- 'http://www.lanuv.nrw.de/liki/index.php?indikator=608&aufzu=1&mode=indi'
# but manually downloaded Excel spreadsheets
messynrgprime <- read.xlsx("export_land_primary.xlsx", 1, startRow = 4, endRow = 21)
messynrgelec <- read.xlsx("export_land_strom.xlsx", 1, startRow = 4, endRow = 21)
messynrguse <- read.xlsx("export_land_energyuse.xlsx", 1, startRow = 4, endRow = 21)

# convert K.D. (keine Daten) to NA
tidynrguse <- as.data.frame(sapply(messynrguse, 
                              gsub, pattern="K.D.", replacement="."))

tidynrgelec <- as.data.frame(sapply(messynrgelec, 
                                   gsub, pattern="K.D.", replacement="."))

tidynrgprime <- as.data.frame(sapply(messynrgprime, 
                                   gsub, pattern="K.D.", replacement="."))

# transform to numeric values, need to correct decimal places and loop but major issue: , instead of .
transform(tidynrgelec, X1990 = as.numeric(X1990))

# convert data to tidy format (one variable per column) currently doesn't work bc they're not numerical
NRGprime <- gather(tidynrgprime, year, percentrenewable, 2:25, na.rm = FALSE, convert = TRUE)
NRGelec <- gather(tidynrgelec, year, percentrenewable, 2:25, na.rm = FALSE, convert = TRUE)
NRGuse <- gather(tidynrguse, year, percentrenewable, 2:26, na.rm = FALSE, convert = TRUE)

# Matching labels
colnames(NRGelec) <- c("State", "Year", "Elec")
colnames(NRGprime) <- c("State", "Year", "Primary")
colnames(NRGuse) <- c("State", "Year", "Use")
NRG <- merge(NRGprime, NRGelec, by=c("Year","State"))
NRG2 <- merge(NRG, NRGuse, by=c("Year","State"))


NRG.final <- as.data.frame(sapply(NRG2, gsub, pattern="X",replacement=""))
export(NRG.final, file="NRG.final.csv") 


### R-script for cleaning and merging excel files for CO2 emissions ###

# 1. Merging files using file name pattern

all_files <- list.files(pattern="statistic_id")
all_subbed <- NULL

# 2. Cleaning in a loop
for (i in all_files) {
  message(i)
  
  if (grepl(pattern = '.xls$', x = i)) {
    message('Skipped')
  }
  
  else if (grepl(pattern = '.xlsx', x = i)) {
    
    # Load individual document in to R as a list
    temp_all <- read.xlsx(i, sheetIndex=2, header=FALSE)
    
    temp_bundesland <- read.xlsx(i, sheetIndex=2, startRow=3, colIndex=2:2, endRow=3, header=FALSE)
    
    temp_data <- read.xlsx(i, sheetIndex=2, startRow=6, header=FALSE)
    
    # Extract specific cell for the name of the state
    
    names(temp_data) <- c('Year', 'Emissions')
    temp_data$State <- paste(temp_bundesland[1,1])
    
    # Bind individual project to main data frame
    all_subbed <- rbind(all_subbed, temp_data)
  }
}

# 3. Save as .csv
# Add file directory as needed
export(all_subbed, file = 'Emissions_cleaned.csv')

# # EXTRA: Cleaning individual file
# data <- read.xlsx2(all_files[3], sheetIndex=2, startRow=6, header=FALSE)
# colnames(data) <- c("Year", "Emissions")
# test <- read.xlsx(all_files[3], sheetIndex=2, startRow=3, colIndex=2:2, endRow=3, header=FALSE)
# data$Bundesland <- paste(test[1,1]) #create a new column with same values for all rows

# 4. Extract missing info on NRW, while also modifying the excel file (see Appendix 1)
library(XML)
all.link <- 'http://www.ugrdl.de/tab34.htm'
Gase.table = readHTMLTable(all.link, header=T, which=1, stringsAsFactors=F)
names(Gase.table) <- c("State", "1990", "1995", "2000", "2005", "2010", "2011", "2011*", "2012")
export(Gase.table, file = 'Gase.csv')

# 5. Merging files
NRW <- read.csv('NRW.csv', header=TRUE) #original file was amended by combining data from "Gase" and "foederal_erneuerbar-Wirtschaft_Datenblatt"
general <- rbind(all_subbed, NRW)

# 6. Cleaning up names
Final <- as.data.frame(sapply(general, 
                              gsub, pattern="Kohlendioxid-Emissionen je Einwohner im |Kohlendioxid-Emissionen je Einwohner in | bis 2012| bis 2010| bis 2011|\\**",replacement=""))
export(Final, file="Emissions_Final.csv") ## has no extra words
## | means "and", //is used for special characteristics such as *

### R-Script for Merging GSOEP, Emissions and Energy files

#1. Tranforming GSOEP dta file to csv for merging

GSOEP = read.dta("SOEP_short12.dta")

#2. And then you simply write it to CSV

write.csv(GSOEP, file = "GSOEP.csv", row.names = FALSE)

#3. Read all files to be merged together
emissions = read.csv("Emissions_Final.csv")
GSOEP = read.csv("GSOEP.csv")
energy = read.csv("NRG.final.csv")

#4. Merge all 3 files together using State and Year as unique IDs
alldata <- merge(emissions,energy,by=c("Year","State"))
finaldata = merge(alldata,GSOEP,by=c("Year","State"))

# convert State variable into numeric
Stateid <- factor(finaldata$State, levels=c(levels(finaldata$State)))
finaldata$Stateid <- c(as.numeric(Stateid))

# add numeric Land code
finaldata$LandCode[finaldata$State == 'Baden-WÃ¼rttemberg'] <- 20228

#5. export merged data to single CSV file
export(finaldata, file="All_Merged_Data.csv")

