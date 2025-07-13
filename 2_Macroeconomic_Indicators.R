# Load libraries
library(fredr)
library(dplyr)
library(zoo)
library(purrr)

# Set FRED API key from .Renviron
fredr_set_key(Sys.getenv("FRED_API_KEY"))

# Define date range
start_date <- as.Date("2001-01-01")
end_date <- as.Date("2025-07-01")

# Download exchange rate series
usd_brl <- fredr(series_id = "DEXBZUS", observation_start = start_date, observation_end = end_date) %>%
  select(date, brl = value)

usd_cny <- fredr(series_id = "DEXCHUS", observation_start = start_date, observation_end = end_date) %>%
  select(date, cny = value)

usd_mxn <- fredr(series_id = "DEXMXUS", observation_start = start_date, observation_end = end_date) %>%
  select(date, mxn = value)

# Merge into one dataset
exchange_rates <- list(usd_brl, usd_cny, usd_mxn) %>%
  reduce(full_join, by = "date") %>%
  arrange(date)

# Create complete daily calendar
all_days <- data.frame(date = seq.Date(start_date, end_date, by = "day"))

# Merge with full calendar
exchange_full <- merge(all_days, exchange_rates, by = "date", all.x = TRUE)

# Flag interpolated values (before filling)
exchange_full <- exchange_full %>%
  mutate(
    brl_interpolated = is.na(brl),
    cny_interpolated = is.na(cny),
    mxn_interpolated = is.na(mxn)
  )

# Forward-fill exchange rates
exchange_full <- exchange_full %>%
  mutate(
    brl = na.locf(brl, na.rm = FALSE),
    cny = na.locf(cny, na.rm = FALSE),
    mxn = na.locf(mxn, na.rm = FALSE)
  )

# Save cleaned dataset
dir.create("Raw_Data/Exchange_Data", recursive = TRUE, showWarnings = FALSE)
write.csv(exchange_full, "Raw_Data/Exchange_Data/USD_to_BRL_CNY_MXN_filled.csv", row.names = FALSE)

# Done!
print("Exchange rates with interpolation flags saved successfully.")