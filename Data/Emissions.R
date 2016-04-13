### R-script for cleaning and merging excel files for CO2 emissions ###
# 1. Necessary packages
library(rJava)
library(xlsxjars)
library(xlsx)
library(rio)        # tool for exporting to csv (can also do excel)
library(tidyr)      # tool for reshaping, though not actually done here


# 2. Setting the directory to the folder with files on the local machine
setwd('~\\GitHub\\Climate-Happiness\\Data\\emissions')
all_files <- list.files(pattern=".xlsx")
all_subbed <- NULL

# 3. Cleaning in a loop
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

# 4. Save as .csv
# Add file directory as needed
export(all_subbed, file = 'Emissions_cleaned.csv')

# # EXTRA: Cleaning individual file
# data <- read.xlsx2(all_files[3], sheetIndex=2, startRow=6, header=FALSE)
# colnames(data) <- c("Year", "Emissions")
# test <- read.xlsx(all_files[3], sheetIndex=2, startRow=3, colIndex=2:2, endRow=3, header=FALSE)
# data$Bundesland <- paste(test[1,1]) #create a new column with same values for all rows

# 5. Extract missing info on NRW, while also modifying the excel file (see Appendix 1)
library(XML)
all.link <- 'http://www.ugrdl.de/tab34.htm'
Gase.table = readHTMLTable(all.link, header=T, which=1, stringsAsFactors=F)
names(Gase.table) <- c("State", "1990", "1995", "2000", "2005", "2010", "2011", "2011*", "2012")
export(Gase.table, file = 'Gase.csv')

# 6. Merging files
NRW <- read.csv('NRW.csv', header=TRUE)
general <- rbind(all_subbed, NRW)

# 7. Cleaning up names
install.packages('gsubfn')
library(gsubfn)
Final <- as.data.frame(sapply(general, gsub, pattern="Kohlendioxid-Emissionen je Einwohner im |Kohlendioxid-Emissionen je Einwohner in | bis 2012|\\**",replacement=""))
export(Final, file="Final.csv") ## has no extra words
                                ## | means "and", //is used for special characteristics such as *
