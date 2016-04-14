### R-script for merging excel files for emissions, renewables and gsoep data ###

install.packages("foreign")
library(foreign)

GSOEP = read.dta("Data/GSOEP/SOEP_short12.dta")
#And then you simply write it to CSV

write.csv(GSOEP, file = "GSOEP.csv", row.names = FALSE)

emissions = read.csv("Data/emissions/Final.csv")
GSOEP = read.csv("GSOEP.csv")
energy = read.csv("Data/emissions/NRG.final.csv")

alldata <- merge(emissions,GSOEP,by=c("Year","State"))
alldata = merge(alldata,energy,by=c("Year","State"))

export(alldata, file="All_Merged_Data.csv")

