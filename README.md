---
output: pdf_document
---
# README: Climate and Happiness: German Citizens and Bundeslaender
---

#### Collaborative Data Analysis 
#### Spring 2016
#### By Katie Levesque, Meerim Ruslanova, and Sarah Unbehaun


## 1. Background

This project focuses on the relationship between objective and subjective aspects of climate on the reported well-being. The research centers on the German Bundeslaender and their residents from 1990 to 2012. The aim of the project is to analyse the relationship between the objective measures of GHG emissions (CO2 specifically) of each State and subjective individual concerns about the environment on one hand, and individual life satisfaction levels on the other. The demographic characteristics, as well as the time-component, also present an interest for this research. A multilevel analysis is applied in order to analyse the relationships between the climate-factors and well-being on both State and individual levels.


## 2. Information on the content

The final data set is composed of 1) State-level data of German Bundeslaender (percent of renewables in primary & final energy consumption and electricity; CO2 emissions) and 2) individual-level data (life satisfaction, gender, age, employment status, family status, environmental concerns). The former is composed via web-scraping. All raw files are distributed among the Data subfolders (Energy, Emissions). The code for data gathering and transformation is located in the SourceFile.R (Data). The latter is supplied by the GSOEP data set and cleaned with a Stata Do-File (all located in the GSOEP subfolder). SourceFile.R combines both State- and individual-level data into a final data frame (All_Merged_Data.csv). This data frame is used for descriptive statistics and analysis, whose R code is located in the Analysis.rmd. The same .rmd file creates the *Assignment 3*. 


## 3. File structure (current & anticipated)

Climate-Happiness

  |- Data (raw & clean files, SouceFile for transforming data, final dataset) 
  
        ||- Energy (data on State renewables)
  
        ||- Emissions (data on State CO2 per capita)
  
        ||- GSOEP (.dta file with life satisfaction & demographic factors; codebook for variables)
  
        |||- Analysis files (rmd, pdf, html) > Assignment 3
  
  |- Proposal
  
  |- Assignments (to be created)
  
  |- Presentation (tbc)
  
  |- Website (tbc)
  
* note: Folder "Data" also contains all raw files for the time being, until we resolve our issue of local paths on a Mac.
