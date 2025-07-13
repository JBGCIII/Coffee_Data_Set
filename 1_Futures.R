# Load or install required packages
required_packages <- c("readxl", "dplyr", "lubridate", "rbcb", "nasapower", "quantmod", "zoo", "xts")

installed <- required_packages %in% installed.packages()
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
invisible(lapply(required_packages, library, character.only = TRUE))

# Create necessary directories
dir.create("Raw_Data/Coffee_Data", recursive = TRUE, showWarnings = FALSE)
dir.create("Raw_Data/Exchange_Rate", recursive = TRUE, showWarnings = FALSE)
dir.create("Raw_Data/Weather_Data", recursive = TRUE, showWarnings = FALSE)

##########################################################################################################
###                               1. Arabica Futures from Yahoo                                        ###
##########################################################################################################

# Define date range
start_date <- as.Date("2000-01-03") # I had to start from the third since the first obsvervation were weekends
end_date <- as.Date("2025-07-09")

# Download Arabica coffee futures (KC=F)
suppressWarnings(getSymbols("KC=F", src = "yahoo", from = start_date, to = end_date, auto.assign = TRUE))

# Convert to data.frame
arabica_df <- data.frame(
  Date = index(`KC=F`),
  Close = as.numeric(Cl(`KC=F`))
)

# Convert to USD per 60kg
arabica_df$Close_USD_60kg <- arabica_df$Close * 0.01 * 132.277

# Clean and keep necessary columns
arabica_clean <- arabica_df[, c("Date", "Close_USD_60kg")]
arabica_clean <- na.omit(arabica_clean)

# Create a complete sequence of daily dates
all_days <- data.frame(Date = seq.Date(start_date, end_date, by = "day"))

# Merge futures data with full daily calendar
arabica_full <- merge(all_days, arabica_clean, by = "Date", all.x = TRUE)

# Flag weekend and missing data
arabica_full$Is_Weekend <- lubridate::wday(arabica_full$Date) %in% c(1, 7)
arabica_full$Is_Interpolated <- is.na(match(arabica_full$Date, arabica_clean$Date))

##########################################################################################################
###                             2. Forward-Fill (Last Observed Price)                                  ###
##########################################################################################################

# Copy the base full dataset
arabica_forward_fill <- arabica_full

# Forward-fill using last observed (previous) value, preserving date order
arabica_forward_fill$Close_USD_60kg <- zoo::na.locf(
  zoo(arabica_forward_fill$Close_USD_60kg, order.by = arabica_forward_fill$Date),
  na.rm = FALSE
)

# Copy the base full dataset
arabica_forward_fill <- arabica_full

# Forward-fill using last observed (previous) value, preserving date order
arabica_forward_fill$Close_USD_60kg <- zoo::na.locf(
  zoo(arabica_forward_fill$Close_USD_60kg, order.by = arabica_forward_fill$Date),
  na.rm = FALSE
)

# Save the forward-filled data to CSV
write.csv(
  arabica_forward_fill,
  "Raw_Data/Coffee_Data/Arabica_Futures_Close_USD_60kg.csv",
  row.names = FALSE
)
