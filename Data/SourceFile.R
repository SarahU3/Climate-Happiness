# DATA GATHERING AND MANIPULATION (see "Section 2. Data" in the Assignment 3)
# Source file for assignment 3 (Final Research Project)
# Authors: Katie, Meerim, and Sarah

### 1. Preparation ###
#  Necessary packages
library(dplyr)
library(car) #scatterplots with panel data
library(httr)
library(foreign) #to read .dta files
library(rJava) # necessary for xlsxjar package
library(xlsxjars) # necessary for xlsx package
library(xlsx) # to read xls files
library(ggplot2)
library(tidyr) # tidy tables
library(repmis)
library(rio) # export files from R
library(XML) # read URL links
library(xml2)
library(rvest) # exporting tables
library(psych) # multilevel analysis
library(plm) # panel data regression
library(gsubfn) # replacing characters
library(multilevel) # multilevel analysis
library(nlme) # GLM models
library(texreg)
library(xtable)
library(stargazer)

# Setting relative path
possibles <- c('~/GitHub/Climate-Happiness/Data', 
               '~/Documents/Hertie 2016/Collaborative Social Science Data/Research Project/GitHub/Climate-Happiness/Data')
set_valid_wd(possibles)


#----------------------------------------------------------#
### 2. Data for Bundeslaender CO2 per capita emissions (Source: Statista, UGRdL, & AfEE) ###

# Merging files using file name pattern (all States are covered except NRW)

all_files <- list.files(path='Emissions', pattern="statistic_id")
all_subbed <- NULL

# Cleaning in a loop
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

# Save as .csv
export(all_subbed, file = 'Emissions_cleaned.csv')

# # EXTRA: Cleaning individual file
# data <- read.xlsx2(all_files[3], sheetIndex=2, startRow=6, header=FALSE)
# colnames(data) <- c("Year", "Emissions")
# test <- read.xlsx(all_files[3], sheetIndex=2, startRow=3, colIndex=2:2, endRow=3, header=FALSE)
# data$Bundesland <- paste(test[1,1]) #create a new column with same values for all rows

# Extract missing info on NRW, while also modifying the excel file (see Appendix 1)
all.link <- 'http://www.ugrdl.de/tab34.htm'
Gase.table = readHTMLTable(all.link, header=T, which=1, stringsAsFactors=F)
names(Gase.table) <- c("State", "1990", "1995", "2000", "2005", "2010", "2011", "2011*", "2012")
export(Gase.table, file = 'Gase.csv')

# Merging CO2 files
NRW <- read.csv(file.path("Emissions", 'NRW.csv'), header=TRUE) #original file was amended by combining data from "Gase" and "foederal_erneuerbar-Wirtschaft_Datenblatt"
general <- rbind(all_subbed, NRW)

# Cleaning up names
Final <- as.data.frame(sapply(general, 
                              gsub, pattern="Kohlendioxid-Emissionen je Einwohner im |Kohlendioxid-Emissionen je Einwohner in | bis 2012| bis 2010| bis 2011|\\**",replacement=""))
export(Final, file="Emissions_Final.csv") ## has no extra words
## | means "and", //is used for special characteristics such as *

#---------------------------------------------------------#
### 3. Total Emissions data (instead of per capita) from Länderarbeitskreis Energiebilanzen
TotalEmissions <-read.xlsx(file.path("Emissions", "allbundeslaender_c100.xlsx"), sheetIndex=1, startRow = 3, endRow = 371)
sapply(TotalEmissions, function(f){is.na(f)<-which(f == '...');f}) 
names(TotalEmissions) <- c("State", "Year", "CO2Tons")
# transform(TotalEmissions, CO2Tons = as.numeric(CO2Tons))
TotalEmissions[, c(2,3)] <- sapply(TotalEmissions[, c(2,3)], as.numeric)


### Forming Emissions per km^2
PopURL <- "http://www.statistik-portal.de/Statistik-Portal/en/en_jb01_jahrtab1.asp"
AreaTableHTML <- PopURL %>% read_html() %>%
  html_nodes("#tblen") %>%
  html_table(,fill=TRUE) %>% 
  as.data.frame
# clean resulting data frame
AreaTable <- AreaTableHTML[c(5:20), 1:2]
names(AreaTable) <- c("State", "sqkm")
# need to convert sqkm to numeric
AreaTable$sqkm <- gsub(",","",AreaTable$sqkm)
AreaTable$sqkm <- as.numeric(as.character(AreaTable$sqkm, dec="."))


# merge emissions and area, calculate emissions/sq km
landemissions <- merge(TotalEmissions,AreaTable,by="State")
landemissions$CO2perSqKm <- landemissions$CO2Tons/landemissions$sqkm*1000


#---------------------------------------------------------#
### 4. Merging GSOEP and Emissions files

# Tranforming GSOEP dta file to csv for merging (Source:DIW)
GSOEP = read.dta(file.path("GSOEP", "SOEP_short12.dta"))
GSOEP_income =  read.dta(file.path("GSOEP", "SOEP_income12.dta"))

# Write it to CSV
write.csv(GSOEP, file = "GSOEP.csv", row.names = FALSE)
write.csv(GSOEP_income, file = "GSOEP_income.csv", row.names = FALSE)


# Read all files to be merged together
emissions = read.csv("Emissions_Final.csv")
GSOEP = read.csv("GSOEP.csv")
GSOEP_income = read.csv("GSOEP_income.csv")


# Merging GSOEP & persq/km emissions & overall emissions
data <- merge(GSOEP, landemissions, by=c("Year","State"))
incomedata <- merge(GSOEP_income, landemissions, by=c('Year', 'State'))
finaldata <- merge(incomedata, emissions, by=c('Year', 'State'))
finaldata <-as.data.frame(sapply(finaldata, gsub, pattern="ü",replacement="ue"))
finaldata[, c(5,22,23,26,32,33)] <- sapply(finaldata[, c(5,22,23,26,32,33)], as.numeric) # specifying columns to convert into numeric

# XConvert State variable into numeric
finaldata$Stateid <- as.numeric(as.factor(finaldata$State))
                             

finaldata$Stateid <- factor( as.numeric(as.factor(finaldata$State)),
                             labels = levels(finaldata$State))

# Drop unnecessary columns
finaldata <- finaldata[,c(1:7,9:11,20, 22:28,30:33)]
names(finaldata) <- c("Year", "State", "pid", "WorkHours","GrossIncome","NetIncome",
                      "JobSecurity","GermanBorn","Edu01", "Edu02","satis_labels", "satis",
                      "environ","Stateid","gender","age","emp","fam","CO2Tons","sqkm",
                      "CO2perSqKm","Emissions")

# Relabel environmental concerns
#finaldata$environ <- factor(finaldata$environ, levels=rev(levels(finaldata$environ)), labels=c("Not at all", "Somewhat", "Very"))
#finaldata$env <- as.numeric(finaldata$environ)
# Does not work - reordering data confuses lme

# Export merged data to single CSV file
export(finaldata, file="All_Merged_Data.csv")

# Check the status of the data
sapply(finaldata, class)
sapply(finaldata, mode)
#---------------------------------------------------------#
# Appendix 1: NRW information was missing from statista. Therefore, info on NRW (1990, 1995)
# was taken from UGRdL Gase table (manually inserted into the excel file), 
# while the data on other years was extracted (with R) from the AfEE website (from 2000 and on).
# The CO2 emissions for all States are measured in annual per capita indicators, so all Bundeslaender match.

