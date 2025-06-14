##########################################################################################################
#                                         DATA SET CREATION FULLL
##########################################################################################################

# Load or install required packages
required_packages <- c("readxl", "dplyr", "lubridate", "rbcb", "nasapower", "quantmod", "zoo","xts" )

installed <- required_packages %in% installed.packages()
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
invisible(lapply(required_packages, library, character.only = TRUE))

# Ensure the parent directory exists
dir.create("Raw_Data/Weather_Data", recursive = TRUE, showWarnings = FALSE)


##########################################################################################################
###                               1. Weather Data (NASA)                                               ### 
##########################################################################################################


# Define the location (longitude and latitude)
lon <- -45.43
lat <- -21.55

# Define date range
start_date <- "2001-11-08"
end_date <- "2025-05-29"



locations <- list(

# Define multiple coffee-producing locations with their names, longitudes, and latitudes
# Important: These coordinates are approximate and should be verified for the most precise coffee-growing centers.


locations <- list(
  # Original Locations (from your script / Brazil example)
  Brazil_Minas_Gerais = c(lon = -45.43, lat = -21.55), #Minas Gerais
  Peru_Cajamarca = c(lon = -79.0, lat = -6.5),       # Example: Cajamarca region, Peru
  Ecuador_Loja = c(lon = -79.2, lat = -4.0),         # Adding Ecuador as it's a significant producer (Loja region)
  Bolivia_Carana = c(lon = -67.6, lat = -16.0),      # Adding Bolivia (Carana region)

  # Central America
  Ethiopia_Yirgacheffe = c(lon = 38.2, lat = 6.1),   # Example: Yirgacheffe region, Ethiopia
  Kenya_Nyeri = c(lon = 37.0, lat = -0.4),           # Example: Nyeri region, Kenya
  Indonesia_Sumatra = c(lon = 97.0, lat = 3.0),      # Example: North Sumatra, Indonesia

  # South American Coffee Regions


  # Central American Coffee Regions
  Colombia_Huila = c(lon = -75.7, lat = 2.5),        # Example: Huila region, Colombia
  Guatemala_Antigua = c(lon = -90.7, lat = 14.6),    # Example: Antigua region, Guatemala
  Honduras_Santa_Barbara = c(lon = -88.2, lat = 14.9), # Example: Santa Bárbara, Honduras
  El_Salvador_Apaneca = c(lon = -89.7, lat = 13.9),   # Example: Apaneca-Ilamatepec, El Salvador
  Nicaragua_Matagalpa = c(lon = -85.9, lat = 13.0),   # Example: Matagalpa, Nicaragua
  Panama_Boquete = c(lon = -82.4, lat = 8.8),        # Example: Boquete, Panama
  Costa_Rica_Tarrazu = c(lon = -84.0, lat = 9.7),    # Adding Costa Rica (Tarrazú region)

  # Asian Coffee Regions
  India_Chikmagalur = c(lon = 75.7, lat = 13.3),     # Example: Chikmagalur, India
  Thailand_Chiang_Rai = c(lon = 99.8, lat = 19.9),   # Example: Chiang Rai, Thailand
  China_Yunnan = c(lon = 101.0, lat = 24.0),         # Example: Yunnan Province, China
  Papua_New_Guinea_Eastern_Highlands = c(lon = 145.4, lat = -6.0), # Eastern Highlands, PNG

  # Island & Unique Terroir Regions
  Hawaii_Kona = c(lon = -155.8, lat = 19.6),         # Example: Kona (Big Island), Hawaii, USA
  Jamaica_Blue_Mountains = c(lon = -76.6, lat = 18.0), # Example: Blue Mountains, Jamaica
  Tanzania_Kilimanjaro = c(lon = 37.3, lat = -3.1)    # Example: Kilimanjaro region, Tanzania
)

)



# Retrieve weather data using nasapower
weather_full <- get_power(
  community = "AG",
  pars = c("T2M_MAX", "T2M_MIN", "RH2M", "ALLSKY_SFC_SW_DWN", "PRECTOTCORR"),
  dates = c(start_date, end_date),
  temporal_api = "daily",
  lonlat = c(lon, lat)
)

# Convert to data.frame to avoid class issues
weather_full <- as.data.frame(weather_full)

# Fix column names: YYYYMMDD → Date
names(weather_full)[names(weather_full) == "YYYYMMDD"] <- "Date"
weather_full$Date <- as.Date(weather_full$Date)

# Select and rename relevant columns
weather_clean <- weather_full %>%
  dplyr::select(Date, T2M_MAX, T2M_MIN, RH2M, ALLSKY_SFC_SW_DWN, PRECTOTCORR) %>%
  dplyr::rename(
    Temp_Max = T2M_MAX,
    Temp_Min = T2M_MIN,
    Humidity = RH2M,
    Solar_Radiation = ALLSKY_SFC_SW_DWN,
    Precipitation_mm = PRECTOTCORR
  )

# Write to CSV
print(getwd())
print("Attempting to write CSV...")

write.csv(weather_clean, "Raw_Data/Weather_Data/weather.csv", row.names = FALSE)
print("CSV file written.")

#############################################################################################################
##                                                                                                         ##


# Define date range (already in your script)
start_date <- "2001-11-08"
end_date <- "2025-05-29"


# The rest of your loop structure would be the same as previously provided:
# all_weather_data <- list()
# for (loc_name in names(locations)) { ... your nasapower call and cleaning ... }
# final_weather_df <- bind_rows(all_weather_data)
# write.csv(final_weather_df, "Raw_Data/Weather_Data/weather_multiple_locations.csv", row.names = FALSE)





