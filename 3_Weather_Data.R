##########################################################################################################
#                         NASA POWER Weather Data Collection Script 
##########################################################################################################

# 1. Load or install required packages
required_packages <- c("dplyr", "lubridate", "nasapower")
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

# 4. Define all regions and locations

location_brazil <- list(
  Brazil_Minas_Gerais_Patrocinio = c(lon = -46.9923, lat = -18.9349),
  Brazil_Minas_Gerais_Varginha = c(lon = -45.4300, lat = -21.5500),
  Brazil_Minas_Gerais_Manhuacu = c(lon = -46.1628, lat = -20.2579),
  Brazil_Minas_Gerais_Aqua_Boa = c(lon = -42.3906, lat = -17.9910),
  Brazil_Sao_Paulo_Campinas = c(lon = -47.0579, lat = -22.7884),
  Brazil_Sao_Paulo_Sao_Jose = c(lon = -47.5833, lat = -20.5333),
  Brazil_Espirito_Santo_Afonso = c(lon = -40.9743, lat = -20.0421),
  Brazil_Espirito_Santo_Conceicao = c(lon = -41.2502, lat = -20.3633)
)

location_colombia <- list(
  Colombia_Morelia = c(lon = -75.6736, lat = 1.3799),
  Colombia_Andes = c(lon = -75.8469, lat = 5.6959),
  Colombia_Santuario = c(lon = -75.9548, lat = 5.0608),
  Colombia_Timbio = c(lon = -76.6960, lat = 2.3433)
)

location_ethiopia <- list(
  Ethiopia_Limu_Kosa = c(lon = 36.8249, lat = 7.9320),
  Ethiopia_Bare = c(lon = 35.2119, lat = 8.2428),
  Ethiopia_Aleto1 = c(lon = 38.4061, lat = 6.5759),
  Ethiopia_Aleto2 = c(lon = 35.3337, lat = 6.8553)
)

location_honduras <- list(
  Honduras_Campamento = c(lon = -86.6347, lat = 14.5579),
  Honduras_Danli = c(lon = -86.2882, lat = 13.9339),
  Honduras_San_Jose = c(lon = -87.9285, lat = 14.2203)
)

location_guatemala <- list(
  Guatemala_San_Marcos = c(lon = -92.0892, lat = 15.1130),
  Guatemala_Huehuetenango = c(lon = -91.7718, lat = 15.5633),
  Guatemala_Jalapa = c(lon = -89.9874, lat = 14.7118)
)

location_peru <- list(
  Peru_Jaen = c(lon = -78.7938, lat = -5.6981)
)

location_china <- list(
  China_Puer = c(lon = 100.9535, lat = 22.6555)
)

# 5. Combine all locations
locations <- c(
  location_brazil,
  location_colombia,
  location_ethiopia,
  location_honduras,
  location_guatemala,
  location_peru,
  location_china
)

# 6. Initialize lists
weather_data_list <- list()
failed_locations <- list()

# 7. Download data for each location
for (loc_name in names(locations)) {
  coords <- locations[[loc_name]]
  output_file <- paste0("Raw_Data/Weather_Data/", loc_name, ".csv")

  if (file.exists(output_file)) {
    cat("Skipping (already exists):", loc_name, "\n")
    next
  }

  cat("Fetching data for:", loc_name, "\n")
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
    write.csv(df, output_file, row.names = FALSE)
    weather_data_list[[loc_name]] <- df
    cat("Success:", loc_name, "\n")
  }, error = function(e) {
    cat("Failed:", loc_name, "\nReason:", e$message, "\n")
    failed_locations[[loc_name]] <- coords
    return(NULL)
  })
  Sys.sleep(2) # Gentle pause to avoid rate limits
}

# 8. Save failed locations for retry
if (length(failed_locations) > 0) {
  saveRDS(failed_locations, file = "Raw_Data/Weather_Data/failed_locations.rds")
  cat("Some locations failed. Retry using 'failed_locations.rds'\n")
} else {
  cat("All locations fetched successfully.\n")
}

# 9. Combine all into one dataset
if (length(weather_data_list) > 0) {
  weather_combined <- dplyr::bind_rows(weather_data_list) %>%
    dplyr::rename(
      Date = YYYYMMDD,
      Temp_Max = T2M_MAX,
      Temp_Min = T2M_MIN,
      Humidity = RH2M,
      Solar_Radiation = ALLSKY_SFC_SW_DWN,
      Precipitation_mm = PRECTOTCORR
    ) %>%
    mutate(Date = as.Date(Date))

  write.csv(weather_combined, "Raw_Data/Weather_Data/weather_dataset_all_locations.csv", row.names = FALSE)
  cat("Combined weather data saved to: weather_dataset_all_locations.csv\n")
}


