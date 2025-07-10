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



# Define date range
start_date <- "2001-11-08"
end_date <- "2025-05-29"



locations <- list(

# Define multiple coffee-producing locations with their names, longitudes, and latitudes
# Important: These coordinates are approximate and should be verified for the most precise coffee-growing centers.



# Define multiple coffee-producing locations with their names, longitudes, and latitudes
# Important: These coordinates are approximate and should be verified for the most precise coffee-growing centers.

locations <- list(
  ################################ Brazil ########################################################
  Brazil_Minas_Gerais_Patrocinio = c(lon = -46.9923, lat = -18.9349), #1
  Brazil_Minas_Gerais_Varginha = c(lon = -45.4300, lat = -21.5500), #2
  Brazil_Minas_Gerais_Manhuaçu = c(lon = -46.9923, lat = -18.9349), #3
  Brazil_Minas_Gerais_Áqua_Boa = c(lon = -42.3906, lat = -17.9910), #4
  Brazil_Sao_Paulo_Campinas = c(lon = -47.0579, lat = -22.7884), #5
  Brazil_Sao_Paulo_Sao_Jose_Da_Bela_Vista = c(lon = -47.5833, lat = -20.5333), #6
  Brazil_Espirito_Santo_Afonso_Claudio = c(lon = -40.9743, lat = -20.0421), #7
  Brazil_Espirito_Santo_Conceicao_do_Castelo = c(lon = -41.2502, lat = -20.3633), #8

  ################################ Colombia ######################################################
  Colombia_Western_Morelia_Caqueta = c(lon = -75.6736, lat = 1.3799), #9
  Colombia_Western_Andes_Antioquia = c(lon = -75.8469, lat = 5.6959), #10
  Colombia_Western_Santuario_Risaralda = c(lon = -75.9548, lat = 5.0608), #11
  Colombia_South_Timbio_Cauca = c( lon = -76.6960, lat = 2.3433), #12

  ################################ Ethiopia ######################################################
  Ethiopia_Oromia_Limu_Kosa = c(lon = 36.8249, lat = 7.9320),
  Ethiopia_Oromia_Bure = c(lon = 35.2119, lat = 8.2428),
  Ethiopia_SSNPR_Aleta_Wondo = c(lon = 38.4061, lat = 6.5759),
  Ethiopia_SSNPR_Aleta_Wondo = c(lon = 35.3337, lat = 6.8553),

  ################################ Honduras ######################################################
  Honduras_Olancho_Campamento = c(lon = -86.6437, lat = 14.5579),
  Honduras_El_Paraiso_Danli = c(lon = -86.2882, lat = 13.9339),
  Honduras_San_Jose_La_Paza = c(lon = -86.2882, lat = 13.9339), 


  ################################ Guatemala #####################################################
  Guatemala_San_Marcos = c(lon = -92.0892, lat = 15.1130), #
  Guatemala_Huehuetenango = c(lon = -91.7718, lat = 15.5633), #
  Guatemala_Jalapa_Jalapa = c(lon = -89.9874, lat = 14.7118), #

  ################################ Peru #####################################################
  Peru_Cajamarca_Jaen = c(lon = -78.7938, lat = -5.6981), #

  ################################ Peru ##########################################################
  China_Yunnan_Puer_City = c(lon = 100.9535, lat = 22.6555), #

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


print("Attempting to write CSV...")

write.csv(weather_clean, "Raw_Data/Weather_Data/weather.csv", row.names = FALSE)
print("CSV file written.")

