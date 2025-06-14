
# While writing the term paper I encountered a lot of missing values mostly coming from the futures price.
# I assumed most of these were coming from weekends and holidays. In this script I wanted to make sure 
#I had an explanation for majority if not all, missing values, and wheter my assumption were correct.

# Load or install required packages
required_packages <- c("readxl", "dplyr", "quantmod","xts", "timeDate")

installed <- required_packages %in% installed.packages()
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
invisible(lapply(required_packages, library, character.only = TRUE))


df <- read.csv("Raw_Data/Coffee_Data/Arabica_Futures_Close_USD_60kg.csv")

df$Date <- as.Date(df$Date)
df <- df[order(df$Date), ]

all_dates <- data.frame(Date = seq(min(df$Date), max(df$Date), by = "day"))
missing_dates <- anti_join(all_dates, df, by = "Date")

missing_dates <- missing_dates %>% mutate(weekday = weekdays(Date))

table(missing_dates$weekday) # Shows missing values based on day of the week
#  friday  saturday  monday  wensday  sunday  tuesday thursday 
#    54      1273     129      16      1273      15      36

# There are 250 missing obsvervation not explained by weekends
# which in the grand scheme of things do not mean much
# but I want to make sure there is an explanation for them, with holiday be the most likely.

holidays_td <- holidayNYSE(2001:2025)
us_holidays <- as.Date(format(holidays_td, "%Y-%m-%d"))

weekday_holidays <- data.frame(Date = us_holidays) %>%
mutate(weekday = weekdays(Date))

table(weekday_holidays$weekday) # 234
# Friday  Monday  Wensday  Tuesday Thursday
#   43     125      14      14      38

# Financial markets might close on weekends but the weather does not!
# Meaning that when merging the data sets we might have to use the last value
# of the future price as to not miss 2796 missing days worth of weather data!