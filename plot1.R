## Programming Assignment 2
## Plot 1
# Have total emissions from PM2.5 decreased in the United States from 1999 to 2008?

library(data.table)

setwd('./data')
if (!file.exists('emissions.RData'))
{
  # Unzip and load data from zip file
  if (!file.exists('summarySCC_PM25.rds'))
    unzip(zipfile='NEI_data.zip', 
          files=c('summarySCC_PM25.rds','Source_Classification_Code.rds'))
  
  # This first line will likely take a few seconds. Be patient!
  NEI <- as.data.table(readRDS("summarySCC_PM25.rds"))
  SCC <- as.data.table(readRDS("Source_Classification_Code.rds"))
  
  # Merge the two tables together on SCC column
  setkey(NEI, SCC)
  setkey(SCC, SCC)
  emissions <- merge(NEI, SCC, all.x=TRUE)
  
  # Clear out extra data from memory
  rm(NEI)
  rm(SCC)
  
  # Format columns
  # fips: A five-digit number (represented as a string) indicating the U.S. county
  emissions$fips <- as.factor(emissions$fips)
  # SCC: The name of the source as indicated by a digit string (see source code classification table)
  emissions$SCC <- as.factor(emissions$SCC)
  # Pollutant: A string indicating the pollutant
  emissions$Pollutant <- as.factor(emissions$Pollutant)
  # Emissions: Amount of PM2.5 emitted, in tons
  emissions$Emissions <- as.numeric(emissions$Emissions)
  # type: The type of source (point, non-point, on-road, or non-road)
  emissions$type <- as.factor(emissions$type)
  # year: The year of emissions recorded
  emissions$year <- as.factor(emissions$year)
  emissions$Data.Category <- as.factor(emissions$Data.Category)
  emissions$Short.Name <- as.factor(emissions$Short.Name)
  
  # Save emissions data so you don't have to do all that formatting again.
  save(emissions, file='emissions.RData')
} else # Saved emissions data already exists, load from RData
  load('emissions.RData')
setwd('..')

# Using the base plotting system, make a plot showing the total PM2.5 emission from
# all sources for each of the years 1999, 2002, 2005, and 2008.
emissionsSumm <- emissions[,list(totalPM25Emissions = sum(Emissions)),by=year]
png('./plot1.png', width = 480, height = 480)
  barplot(emissionsSumm$totalPM25Emissions, names.arg=emissionsSumm$year, col='red',
          xlab='Year', ylab='Total PM2.5 emission (tons)')
  title('Total PM2.5 emission from all sources')
dev.off()
