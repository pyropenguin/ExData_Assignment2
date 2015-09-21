## Programming Assignment 2
## Plot 5
# How have emissions from motor vehicle sources changed from 1999–2008 in 
# Baltimore City?

library(data.table)
library(ggplot2)

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

# NOTE: SCC.Level.Two has usage data. Filter by "vehicle".
emissionsSumm <- emissions[grep("[Vv]ehicle", emissions$SCC.Level.Two),
                           list(totalPM25Emissions = sum(Emissions)),
                           by=list(year,SCC.Level.Two,fips)]
emissionsSumm <- emissionsSumm[fips == "24510"] # fips == 24510 is Baltimore City.
setkey(emissionsSumm, year)
png('./plot5.png', width = 720, height = 480)
  g <- ggplot(data=emissionsSumm, aes(x=year, y=totalPM25Emissions, fill=SCC.Level.Two))
  g <- g + geom_bar(stat='identity')
  g <- g + facet_wrap(~ SCC.Level.Two)
  g <- g + labs(title='Total PM2.5 emission from motor vehicles in Baltimore City',
                x='Year', y='Total PM2.5 emission (tons)')
  g <- g + theme(axis.text.x = element_text(angle = 90))
  g <- g + guides(fill=FALSE)
  g
dev.off()
