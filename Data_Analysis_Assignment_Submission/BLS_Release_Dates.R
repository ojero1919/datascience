library(rvest)
library(dplyr)

# Gather data from 2007 in a .csv file
bls <- read.csv("BLS_Release_Dates.csv")

# Gather all data from 2008 to 2020 using HTML scraper
for (i in 2008:2020) {
  webpage <- read_html(paste0("https://www.bls.gov/schedule/", i, "/home.htm"))
  tbls <- html_nodes(webpage, "table")
  tbls <- html_table(tbls)
  tbls <- bind_rows(tbls)
  
  # Rbind to previous
  bls <- rbind(bls, tbls)
  rm(tbls)
}
rm(i)
rm(webpage)

