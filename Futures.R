

# Load or install required packages
required_packages <- c("readxl", "dplyr", "lubridate", "rbcb", "nasapower", "quantmod", "zoo","xts" )

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
###                               3. Arabica Futures from Yahoo                                        ### 
##########################################################################################################

# Define dates
start_date <- as.Date("2000-01-01")
end_date <- as.Date("2025-07-11")

# Download KC=F futures, suppress warnings about missing data
suppressWarnings(getSymbols("KC=F", src = "yahoo", from = start_date, to = end_date, auto.assign = TRUE))

# Convert to data.frame
arabica_df <- data.frame(
  Date = index(`KC=F`),
  Close = as.numeric(Cl(`KC=F`))
)

# Add Close_USD_60kg column *without* using select() separately
arabica_df$Close_USD_60kg <- arabica_df$Close * 0.01 * 132.277

# Keep only Date and Close_USD_60kg in a new data frame (base R subsetting)
arabica_clean <- arabica_df[, c("Date", "Close_USD_60kg")]

arabica_clean <- na.omit(arabica_clean)

# Create directory if it doesn't exist
dir.create("Raw_Data/Coffee_Data", recursive = TRUE, showWarnings = FALSE)

# Write CSV
write.csv(arabica_clean, "Raw_Data/Coffee_Data/Arabica_Futures_Close_USD_60kg.csv", row.names = FALSE)


##########################################################################################################
###                             3. Linear Interpolation                                                ###
##########################################################################################################

arabica_interpolated <- arabica_full
arabica_interpolated$Close_USD_60kg <- zoo::na.approx(arabica_interpolated$Close_USD_60kg, rule = 2)

# Save interpolated CSV
write.csv(arabica_interpolated, "Raw_Data/Coffee_Data/Arabica_Futures_Close_USD_60kg_Interpolated.csv", row.names = FALSE)

##########################################################################################################
###                             4. Optional: Save Full Unfilled for Reference                         ###
##########################################################################################################

# Save the raw merged file (with NAs on weekends)
write.csv(arabica_full, "Raw_Data/Coffee_Data/Arabica_Futures_Close_USD_60kg_Unfilled.csv", row.names = FALSE)