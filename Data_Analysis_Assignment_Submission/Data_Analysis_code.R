library(readxl)
library(dplyr)
library(quantmod) 
library(readxl)
library(lubridate)
library(ggplot2)

source("BLS_Release_Dates.R")
bls$Date<-as.Date(bls$Date, "%A, %B %d, %Y")

getSymbols("^GSPC", src = "yahoo") 
SP_500 <- Cl(GSPC)
rm(GSPC)
SP_500 <- as.data.frame(SP_500)
SP_500 <- tibble::rownames_to_column(SP_500, var = "Date") 
SP_500$Date <- as.Date(SP_500$Date)
#Problem 1
sru<-read_xlsx("SeriesReport-20201006201227_5de657.xlsx")
sru<-as.data.frame(sru)
sru <- sru[-c(1:11),]

df<- data.frame(Year = numeric(), Month = character(), Unemployment = numeric())
for(j in 1:12){
  for(i in 2:12){
    row<- c(sru[i,1], sru[1,j+1], sru[i,j+1])
    df <- rbind(df, row)
  }
}
rm(i,j)

df <- df %>% 
  rename(
    Year = X.2010.,
    Month = X.Jan.,
    Unemployment=X.9.800000000000001.
  )
df<-df %>% arrange(Year)


df$Month <- gsub("Jan", "01 Jan", df$Month)
df$Month <- gsub("Feb", "01 Feb", df$Month)
df$Month <- gsub("Mar", "01 Mar", df$Month)
df$Month <- gsub("Apr", "01 Apr", df$Month)
df$Month <- gsub("May", "01 May", df$Month)
df$Month <- gsub("Jun", "01 Jun", df$Month)
df$Month <- gsub("Jul", "01 Jul", df$Month)
df$Month <- gsub("Aug", "01 Aug", df$Month)
df$Month <- gsub("Sep", "01 Sep", df$Month)
df$Month <- gsub("Oct", "01 Oct", df$Month)
df$Month <- gsub("Nov", "01 Nov", df$Month)
df$Month <- gsub("Dec", "01 Dec", df$Month)
df$Month = paste(df$Month,df$Year)
df$Year<-NULL
df$Month<- as.character(df$Month)

df$Month<- as.Date(df$Month, "%d %b %Y" )
df$Unemployment<-as.numeric(df$Unemployment)
df$Month <- df$Month %m+% months(1)
#Problem 2
bls<-bls %>% filter(grepl("Employment Situation for", bls$Release) & grepl("200",bls$Release)==FALSE)

SP_500<-SP_500[match(bls$Date, SP_500$Date),]
#The match function just goes through the date column of the SP_500 dataset and remove the dates that don't match the dates in the date column of the BLS dataset
#SOURCE:Its a tutorial on the match function. https://www.youtube.com/watch?v=NcqsK9JeEJI

df<-df[-c(132),]

my_data<-bls
my_data["Unemployment"]<-df$Unemployment
my_data<-merge(my_data, SP_500)
my_data$Unemployment<-as.numeric(my_data$Unemployment)
my_data$Time<-NULL
my_data$Release<-NULL

#problem 3
ggplot(my_data, aes(x = Date, y = Unemployment))+geom_line()+theme_bw()+ylab("Unemployment Rate")
ggplot(my_data, aes(x = Date, y = GSPC.Close))+geom_line()+theme_bw()+ylab("S&P 500 Closing Stock Prices")

cor(my_data$Unemployment, my_data$GSPC.Close, method = "kendall", use = "complete.obs")

#There seems to be a negative corellation between Unemployment and SP_500 closing prices
