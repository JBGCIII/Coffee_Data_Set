##########################################################################################################
#                              NASA POWER Weather Data Collection Script
##########################################################################################################

# 1. Load or install required packages
required_packages <- c("readxl", "dplyr", "lubridate", "rbcb", "nasapower", "quantmod", "zoo", "xts")

installed <- required_packages %in% installed.packages()
if (any(!installed)) {
  install.packages(required_packages[!installed])
}
invisible(lapply(required_packages, library, character.only = TRUE))


# 2. Define date range
start_date <- "2000-01-03"
end_date <- "2025-07-09"

# 3. Create output directory
dir.create("Raw_Data/Weather_Data", recursive = TRUE, showWarnings = FALSE)

# 4. Define all locations with clear naming
locations <- list(
  Brazil_Minas_Gerais_Patrocinio = c(lon = -46.9923, lat = -18.9349), #1
  Brazil_Minas_Gerais_Varginha = c(lon = -45.4300, lat = -21.5500), #2
  Brazil_Minas_Gerais_Manhuacu = c(lon = -46.1628, lat = -20.2579), #3
  Brazil_Minas_Gerais_Aqua_Boa = c(lon = -42.3906, lat = -17.9910),#4
  Brazil_Sao_Paulo_Campinas = c(lon = -47.0579, lat = -22.7884), #5 missing
  Brazil_Sao_Paulo_Sao_Jose = c(lon = -47.5833, lat = -20.5333), #6
  Brazil_Espirito_Santo_Afonso = c(lon = -40.9743, lat = -20.0421), #7
  Brazil_Espirito_Santo_Conceicao = c(lon = -41.2502, lat = -20.3633), #8
  Colombia_Morelia = c(lon = -75.6736, lat = 1.3799), #9
  Colombia_Andes = c(lon = -75.8469, lat = 5.6959), #10
  Colombia_Santuario = c(lon = -75.9548, lat = 5.0608), # 11 Missing
  Colombia_Timbio = c(lon = -76.6960, lat = 2.3433), #12
  Ethiopia_Limu_Kosa = c(lon = 36.8249, lat = 7.9320), #13
  Ethiopia_Bare = c(lon = 35.2119, lat = 8.2428), #14
  Ethiopia_Aleto1 = c(lon = 38.4061, lat = 6.5759), #15
  Ethiopia_Aleto2 = c(lon = 35.3337, lat = 6.8553), #16
  Honduras_Campamento = c(lon = -86.6347, lat = 14.5579), #17
  Honduras_Danli = c(lon = -86.2882, lat = 13.9339), #18
  Honduras_San_Jose = c(lon = -87.9285, lat = 14.2203), #19
  Guatemala_San_Marcos = c(lon = -92.0892, lat = 15.1130), #20
  Guatemala_Huehuetenango = c(lon = -91.7718, lat = 15.5633), #21
  Guatemala_Jalapa = c(lon = -89.9874, lat = 14.7118), #22
  Peru_Jaen = c(lon = -78.7938, lat = -5.6981), #23
  China_Puer = c(lon = 100.9535, lat = 22.6555) #24
)

# 5. Create empty list to store results
weather_data_list <- list()

# 6. Loop over locations and fetch data individually
for (loc_name in names(locations)) {
  coords <- locations[[loc_name]]
  cat("Fetching data for:", loc_name, "\n")
  
  # Try fetching data, catch and log errors
  result <- tryCatch({
    data <- get_power(
      community = "AG",
      pars = c("T2M_MAX", "T2M_MIN", "RH2M", "ALLSKY_SFC_SW_DWN", "PRECTOTCORR"),
      dates = c(start_date, end_date),
      temporal_api = "daily",
      lonlat = coords
    )
    
    df <- as.data.frame(data)
    df$Location <- loc_name
    df
  }, error = function(e) {
    cat("Failed to fetch:", loc_name, "\nReason:", e$message, "\n")
    NULL
  })
  
  if (!is.null(result)) {
    weather_data_list[[loc_name]] <- result
  }
}

# 7. Combine all successful datasets
weather_combined <- dplyr::bind_rows(weather_data_list)

# 8. Convert date and rename variables
weather_clean <- weather_combined %>%
  dplyr::rename(
    Date = YYYYMMDD,
    Temp_Max = T2M_MAX,
    Temp_Min = T2M_MIN,
    Humidity = RH2M,
    Solar_Radiation = ALLSKY_SFC_SW_DWN,
    Precipitation_mm = PRECTOTCORR
  ) %>%
  mutate(Date = as.Date(Date))

# 9. Save to CSV
output_path <- "Raw_Data/Weather_Data/weather_dataset_all_locations.csv"
write.csv(weather_clean, output_path, row.names = FALSE)
cat("Weather data saved to:", output_path, "\n")





locations2 <- list(
  Brazil_Sao_Paulo_Campinas = c(lon = -47.0579, lat = -22.7884), #5 missing
  Colombia_Santuario = c(lon = -75.9548, lat = 5.0608),) # 11 Missing


# 5. Create empty list to store results
weather_data_list2 <- list()

# 6. Loop over locations and fetch data individually
for (loc_name in names(locations2)) {
  coords <- locations2[[loc_name]]
  cat("Fetching data for:", loc_name, "\n")
  
  # Try fetching data, catch and log errors
  result <- tryCatch({
    data <- get_power(
      community = "AG",
      pars = c("T2M_MAX", "T2M_MIN", "RH2M", "ALLSKY_SFC_SW_DWN", "PRECTOTCORR"),
      dates = c(start_date, end_date),
      temporal_api = "daily",
      lonlat = coords
    )
    
    df <- as.data.frame(data)
    df$Location <- loc_name
    df
  }, error = function(e) {
    cat("Failed to fetch:", loc_name, "\nReason:", e$message, "\n")
    NULL
  })
  
  if (!is.null(result)) {
    weather_data_list[[loc_name]] <- result
  }
}

# 7. Combine all successful datasets
weather_combined <- dplyr::bind_rows(weather_data_list)

# 8. Convert date and rename variables
weather_clean <- weather_combined %>%
  dplyr::rename(
    Date = YYYYMMDD,
    Temp_Max = T2M_MAX,
    Temp_Min = T2M_MIN,
    Humidity = RH2M,
    Solar_Radiation = ALLSKY_SFC_SW_DWN,
    Precipitation_mm = PRECTOTCORR
  ) %>%
  mutate(Date = as.Date(Date))

# 9. Save to CSV
output_path <- "Raw_Data/Weather_Data/weather_dataset_all_locations2.csv"
write.csv(weather_clean, output_path, row.names = FALSE)
cat("Weather data saved to:", output_path, "\n")

