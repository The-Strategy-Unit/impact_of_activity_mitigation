library(readxl)
library(tidyverse)
library(janitor)

# Aim ---------------------------------------------------------------------

# Extract ONS population estimates by year, single year of age, sex, IMD quintile, and region

# Data sources ------------------------------------------------------------

# ONS population estimates
## https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimates 
## three workbooks for 2011-14, 2015-18 and 2019 with one worksheet per year. One LSOA21 per row and one column for each year-sex combination with counts

# Finger Tips LSOA21 to IMD19 lookup
## https://fingertips.phe.org.uk/documents/2021-lsoa-imd-lookup.xlsx
## a lookup which importantly contains LSOA21 to IMD19 as well as region codes


# Loading ONS data --------------------------------------------------------

# Function to read all relevant sheets from a given file
read_population_data <- function(filepath, years_to_include) {
  
  # Filter only the sheets matching the years of interest
  relevant_sheets <- paste0("Mid-", years_to_include, " LSOA 2021")
  
  # Read the sheets into a named list
  popn_list <- map(setNames(relevant_sheets, relevant_sheets), 
                   ~ read_excel(filepath, sheet = .x, skip = 3))
  
  return(popn_list)
}

# Read data from each workbook
popn_2011_2014 <- read_population_data("2025 analysis/Population data/ONS data/sapelsoasyoa20112014.xlsx", 
                                       years_to_include = 2011:2014)

popn_2015_2018 <- read_population_data("2025 analysis/Population data/ONS data/sapelsoasyoa20152018.xlsx", 
                                       years_to_include = 2015:2018)

popn_2019 <- read_population_data("2025 analysis/Population data/ONS data/sapelsoasyoa20192022.xlsx", 
                                  years_to_include = 2019)

# Combine all lists into one
popn_data <- c(popn_2011_2014, popn_2015_2018, popn_2019)

# Wrangling ONS data ------------------------------------------------------

# We now have a list of 9 data frames, one for each year between 2011:2019
# The data frames need to be lengthened as the age and sex variables are spread
# across 180 columns (1 sexes, and 90 ages). The columns are written in format
# "M90" to a indicate 90-year-old male or "F45" to a indicate 45-year-old female


# Function to clean and reshape a single population data table
clean_popn_table <- function(data, table_name) {
  
  # Extract the four-digit year from the table name
  year <- stringr::str_extract(table_name, "\\d{4}") |> as.integer()
  
  # Clean and reshape the data
  data |> 
    clean_names() |>  # Standardize column names
    select(lsoa_2021_code, f0:m90) |>  # Keep only relevant columns
    pivot_longer(
      cols = f0:m90,  
      names_to = "age_sex",  
      values_to = "population"
    ) |>  
    separate(
      col = age_sex,  
      into = c("sex", "age"),  
      sep = 1,  # Split after the first character
      convert = TRUE  # Convert 'age' to integer
    ) |>  
    mutate(year = year)  # Add extracted year as a column
}

# Apply the function to all tables in popn_data, extracting year from table names
popn_long <- imap_dfr(popn_data, clean_popn_table)

# Display the structure of the final dataset
glimpse(popn_long)

# save as an RDS for future reference
saveRDS(popn_long, "2025 analysis/Population data/population_data_2011_2019.Rds")


# Loading & wrangling LSOA21-IMD19 lookup ---------------------------------

# Loading the LSOA21 - IMD19 lookup
lsoa21_imd19_lookup <- read_excel("2025 analysis/reference data/2021-lsoa-imd-lookup.xlsx",
                          sheet = "IMD lookup",
                          skip = 5) |> 
  janitor::clean_names() |> 
  select(lsoa21cd, imd_quintile = imd2019_quintiles_lsoa21_within_ctry09, rgn09cd)


# A function to change region codes to names
region_code_to_name <- function(data, region_code) {
  data |> 
    mutate(
      region = case_match(
        {{region_code}},
        "E12000001" ~ "North East",
        "E12000002" ~ "North West",
        "E12000003" ~ "Yorkshire and Humber",
        "E12000004" ~ "East Midlands",
        "E12000005" ~ "West Midlands",
        "E12000006" ~ "East of England",
        "E12000007" ~ "London",
        "E12000008" ~ "South East",
        "E12000009" ~ "South West",
        "E99999999" ~ "England (not otherwise stated)",
        "L99999999" ~ "Channel Islands",
        "M99999999" ~ "Isle of Man",
        "N99999999" ~ "Northern Ireland",
        "S99999999" ~ "Scotland",
        "W99999999" ~ "Wales",
        "U" ~ "No fixed abode",
        "X" ~ "Foreign",
        "Y" ~ "Unknown"
      )
    )
}

# getting the regions
lsoa21_imd19_lookup <- lsoa21_imd19_lookup |> 
  region_code_to_name(rgn09cd) |> 
  select(-rgn09cd)

# Getting population by IMD quintile and region ---------------------------

# We now can join the lsoa lookup onto the population data
popn_long <- popn_long |> 
  left_join(lsoa21_imd19_lookup, by = c("lsoa_2021_code" = "lsoa21cd"))

# basically what we want is the population by year, age, sex, imd_quintile and region.
# so we just aggregate accordingly and consequently lose the LSOA granularity

popn <- popn_long |> 
  summarise(
    population = sum(population), 
    .by = c(
      year, 
      age, 
      sex, 
      region, 
      imd_quintile
    )
  )

glimpse(popn)

# The data is now ~75,000 rows instead of ~58m as a result of removing the 
# LSOA cut from the data. This makes sense as from the LSOA lookup we can see 
# that there are ~34,000 LSOAs and 75,000 * 34,000 is approximately 58m

# FINAL SAVE
write.csv(popn, "2025 analysis/Population data/population_2011_2019_age_sex_region_imd.csv")
