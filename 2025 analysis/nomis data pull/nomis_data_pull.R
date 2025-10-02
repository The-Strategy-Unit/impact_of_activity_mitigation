source("2025 analysis/nomis data pull/nomis_helpers.R")
library(dplyr)

### Total population by Lower-Layer Super Output Area (LSOA), 2011, for England
### https://www.nomisweb.co.uk/datasets/pestoa2021
dataset_info <- nomis_search_dataset("PESTOA2021")
dataset_id <- get_dataset_id(dataset_info)
concepts_tbl <- get_dataset_concepts(dataset_info)
concept_info <- get_concept_info(concepts_tbl) |>
  purrr::modify_at("geography", \(x) {
    x |>
      dplyr::filter(if_any("name", \(x) grepl("^2021 super.*lower", x))) |>
      dplyr::pull("code") |>
      get_code_info(dataset_id, "geography")
  }) |>
  purrr::keep(\(x) nrow(x) > 1)


concept_filters <- c(
  geography = ".*", # keep all LSOAs
  time = ".*", # keep all years
  gender = "^(Fem|M)ale$", # only return data for Male and Female (not Total)
  c_age = "^(Age [0-9]+|Aged 90\\+)$", # only return single year of age
  measures = "value" # only return population numbers, not percentages
)
concept_codes <- concept_info |>
  purrr::map2(concept_filters, pull_code)

get_popn_data <- function(geo_cds, ds_id, year, age_cds, gen_cds, tot_cd) {
  result <- nomis_base_query() |>
    httr2::req_url_path_append(paste0(ds_id, ".data.json")) |>
    httr2::req_url_query(time = year) |>
    httr2::req_url_query(geography = geo_cds, .multi = "comma") |>
    httr2::req_url_query(c_age = age_cds, .multi = "comma") |>
    httr2::req_url_query(gender = gen_cds, .multi = "comma") |>
    httr2::req_url_query(measures = tot_cd) |>
    nomis_query_perform_safely() |>
    purrr::pluck("result")

  # Handle errors (safely() means result will be NULL instead of throwing error)
  if (is.null(result)) {
    tibble::tibble(error_flag = 1L)
  } else {
    data_out <- purrr::pluck(httr2::resp_body_json(result), "obs")

    # Pull values from nested list into tibble of vectors
    tibble::tibble(
      error_flag = 0L,
      year = purrr::map_int(data_out, list("time", "description")),
      lsoa21cd = purrr::map_chr(data_out, list("geography", "geogcode")),
      lsoa21nm = purrr::map_chr(data_out, list("geography", "description")),
      gender_code = purrr::map_int(data_out, list("gender", "value")),
      gender_desc = purrr::map_chr(data_out, list("gender", "description")),
      age = purrr::map_chr(data_out, list("c_age", "description")),
      population = purrr::map_int(data_out, list("obs_value", "value"))
    )
  }
}

# Get all LSOA population data by year
get_popn_data_by_year <- function(year, dataset_id, concept_codes) {
  geo_codes <- concept_codes[["geography"]]
  age_cds <- concept_codes[["c_age"]]
  gen_cds <- concept_codes[["gender"]]
  tot_cd <- concept_codes[["measures"]]
  batch_it(geo_codes, 100) |>
    purrr::map(\(x) {
      get_popn_data(x, dataset_id, year, age_cds, gen_cds, tot_cd)
    }) |>
    purrr::list_rbind()
}

popn_data_2019 <- get_popn_data_by_year(2019, dataset_id, concept_codes) |>
  # Filter to England only
  dplyr::filter(if_any("lsoa21cd", \(x) grepl("^E", x)))

# Alternatively, get all years in one go (returned as a list of tibbles)
year_codes <- concept_codes[["time"]]
popn_data_all_years <- year_codes |>
  ## Use line below to only retrieve data for certain years
  # purrr::keep(\(x) as.integer(x) %in% c(2011, 2015, 2021)) |>
  purrr::map(\(x) get_popn_data_by_year(x, dataset_id, concept_codes))
