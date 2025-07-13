











##########################################################################################################
###                               2. Exchange Rate (PTAX)                                              ### 
##########################################################################################################

start_year <- 2000
end_year <- year(Sys.Date())

all_data <- lapply(start_year:end_year, function(y) {
  start_date <- as.Date(paste0(y, "-01-01"))
  end_date_temp <- if (y == end_year) Sys.Date() else as.Date(paste0(y, "-12-31"))
  tryCatch({
    get_series(1, start_date, end_date_temp)
  }, error = function(e) {
    message("Failed for year ", y, ": ", e$message)
    NULL
  })
})

all_data <- Filter(Negate(is.null), all_data)
ptax_data <- bind_rows(all_data) %>%
  rename(PTAX = `1`) %>%
  arrange(date)

write.csv(ptax_data, "Raw_Data/Exchange_Rate/USD_BRL_Exchange_Rate.csv", row.names = FALSE)