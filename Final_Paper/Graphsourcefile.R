# "Graphs"

setwd('~/GitHub/Climate-Happiness/Final_Paper')
source('~/GitHub/Climate-Happiness/Data/SourceFile.R')
data <- read.csv("All_Merged_Data.csv")
attach(data)

#Boxplot of emissions levels by state
ggplot(data, aes(x=State, y=Emissions), main = "Emissions by State", xlab = "State", ylab = "Emissions (annual tons of CO2 per capita)") +geom_boxplot(aes(fill=factor(State))) + scale_colour_discrete() + theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) + guides(fill=FALSE)



# Line graph of emissions levels by state over time
ggplot(data, aes(x = Year, y = Emissions, group = State, color = State)) + geom_line() + scale_colour_discrete() +labs(y = "Emissions (annual tons of CO2 per capita)")

# Create multiplot function to combine multiple ggplots
multiplot <- function(..., plotlist = NULL, file, cols = 1, layout = NULL) {
  require(grid)
  
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  if (is.null(layout)) {
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots == 1) {
    print(plots[[1]])
    
  } else {
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    for (i in 1:numPlots) {
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


# Find aggregate means of variables by state and year
aggremeans <- aggregate(data[, c("WorkHours","GrossIncome","satis","environ","age",
                                 "emp","fam","CO2perSqKm","Emissions")], list(State, Year), mean)
ggplot(aggremeans, aes(x = Group.2, y = satis, group = Group.1, colour = Group.1)) + geom_line() + scale_colour_discrete() +labs(x = "Year", y = "Life Satisfaction")



# scatterplots of aggregate state satisfaction over years
plot1 <- ggplot(data = aggremeans, aes(x=age, y=satis)) + geom_point() +geom_smooth() + labs(x = "Age", y = "")
plot2 <- ggplot(data = aggremeans, aes(x=WorkHours, y=satis)) + geom_point() +geom_smooth() + labs(x = "Work Hours per Week", y = "")
plot3 <- ggplot(data = aggremeans, aes(x=GrossIncome, y=satis)) + geom_point() +geom_smooth() + labs(x = "Monthly Gross Income", y = "")
plot4 <- ggplot(data = aggremeans, aes(x=environ, y=satis)) + geom_point() +geom_smooth() + labs(x = "Concern about the Environment", y = "")
plot5 <- ggplot(data = aggremeans, aes(x=Emissions, y=satis)) + geom_point() +geom_smooth() + labs(x = "Emissions per Capita", y = "")
plot6 <- ggplot(data = aggremeans, aes(x=CO2perSqKm, y=satis)) + geom_point() +geom_smooth() + labs(x = "Emissions per Sq KM", y = "")
multiplot(plot1, plot2, plot3, plot4, plot5, plot6, cols=2)
