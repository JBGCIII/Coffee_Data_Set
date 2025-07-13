# Load or install required packages
required_packages <- c("readxl", "dplyr", "lubridate", "rbcb", "nasapower", "quantmod", "zoo", "xts")

installed <- required_packages %in% installed.packages()
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
invisible(lapply(required_packages, library, character.only = TRUE))

##########################################################################################################
###                               5. Merge All Datasets
##########################################################################################################

# Load Coffee Futures Data
coffee_data <- read.csv("Raw_Data/Coffee_Data/Arabica_Futures_Close_USD_60kg_Filled.csv") %>%
  mutate(Date = as.Date(Date))

# Load Exchange Rate or Macro Data
currency_data <- read.csv("Raw_Data/Exchange_Data/USD_to_BRL_CNY_MXN_filled.csv") %>%
  mutate(Date = as.Date(date)) %>%
  dplyr::select(Date, brl, cny, mxn)

# Load Weather Data
weather_data <- read.csv("Raw_Data/Weather_Data/weather_dataset_all_locations.csv") %>%
  mutate(Date = as.Date(Date))


# Merge all datasets by Date
merged_data <- weather_data %>%
  left_join(coffee_data, by = "Date") %>%
  left_join(currency_data, by = "Date") %>%
  arrange(Date)

# Save merged dataset
write.csv(merged_data, "Raw_Data/Coffee_Data_Set.csv", row.names = FALSE)


