



df <- read.csv("Coffee_Data/Arabica_Futures_Close_USD_60kg.csv")

# Make sure date is in Date format
df$Date <- as.Date(df$Date)
