#' Retrieve the user's Nomis API key, or throw an error if no key found
#'
#' The Nomis API key should be found in the current R environment.
#' A key can be obtained from nomisweb.co.uk and stored in the `.Renviron` file.
get_nomis_api_key <- function() {
  nomis_api_key <- Sys.getenv("NOMIS_API_KEY")
  if (nomis_api_key == "") {
    cli::cli_abort(
      paste0(
        "You must get a Nomis API key from {.url nomisweb.co.uk} in order to ",
        "use this function. Store the key in {.file .Renviron} with the name ",
        "{.envvar NOMIS_API_KEY}. See {.url https://rstats.wtf/r-startup.html}",
        " for advice. Then restart {.emph R} before trying this function again."
      )
    )
  } else {
    nomis_api_key
  }
}

#' Base query to Nomis API using \{httr2\} and a custom user agent
nomis_base_query <- function() {
  nm_agent <- "httr2 R package - custom user script"
  httr2::request("https://www.nomisweb.co.uk") |>
    httr2::req_user_agent(nm_agent) |>
    httr2::req_url_path_append("api/v01/dataset")
}

#' Perform a query to the Nomis API
#'
#' @param req The \{httr2\} query to be performed
nomis_query_perform <- function(req) {
  nm_key <- get_nomis_api_key()
  req |>
    httr2::req_url_query(uid = nm_key) |>
    httr2::req_perform() |>
    httr2::resp_check_status()
}
nomis_query_perform_safely <- purrr::safely(nomis_query_perform)

#' Search for information about a Nomis dataset
#'
#' The dataset code is the reference code used on Nomis website for each
#'  dataset. For example, the dataset at
#'  https://www.nomisweb.co.uk/datasets/c2021rm121 has the code RM121.
#'
#' @param dataset_code The Nomis code for the dataset
nomis_search_dataset <- function(dataset_code) {
  nomis_base_query() |>
    httr2::req_url_path_append("def.sdmx.json") |>
    httr2::req_url_query(search = paste0("name-", dataset_code, "*")) |>
    nomis_query_perform() |>
    httr2::resp_body_json() |>
    purrr::pluck("structure", "keyfamilies", 1)
}

get_dataset_id <- \(dataset_info) purrr::pluck(dataset_info, 1, "id")

get_dataset_concepts <- function(dataset_info) {
  comps <- purrr::pluck(purrr::map(dataset_info, "components"), 1)
  tibble::tibble(
    id = get_dataset_id(dataset_info),
    name = purrr::pluck(dataset_info, 1, "name", "value"),
    concept = purrr::map(purrr::pluck(comps, "dimension"), "conceptref"),
    time = purrr::pluck(comps, "timedimension", "conceptref"),
    value = purrr::pluck(comps, "primarymeasure", "conceptref")
  ) |>
    tidyr::unnest_longer(!c("id", "name"), transform = tolower) |>
    tidyr::pivot_longer(
      cols = !c("id", "name"),
      values_to = "concept",
      names_to = NULL
    ) |>
    dplyr::distinct()
}

build_concept_query <- function(id, concept) {
  nomis_base_query() |>
    httr2::req_url_path_append(id) |>
    httr2::req_url_path_append(paste0(concept, ".def.sdmx.json"))
}
build_code_query <- function(id, concept, code) {
  nomis_base_query() |>
    httr2::req_url_path_append(id) |>
    httr2::req_url_path_append(concept) |>
    httr2::req_url_path_append(paste0(code, ".def.sdmx.json"))
}

process_query <- function(query) {
  json_data <- query |>
    nomis_query_perform() |>
    httr2::resp_body_json() |>
    purrr::pluck("structure", "codelists", "codelist", 1, "code")
  tibble::tibble(
    name = purrr::map(purrr::map(json_data, "description"), "value"),
    code = purrr::map(json_data, "value")
  ) |>
    dplyr::mutate(across(c("name", "code"), \(x) unlist(as.character(x))))
}

get_concept_info <- function(concepts_tbl) {
  get_info <- function(id, name, concept) {
    build_concept_query(id, concept) |>
      process_query()
  }
  purrr::pmap(concepts_tbl, get_info) |>
    rlang::set_names(concepts_tbl[["concept"]])
}
get_code_info <- function(code, id, concept) {
  build_code_query(id, concept, code) |>
    process_query()
}

pull_code <- function(concept_info_tbl, rx) {
  concept_info_tbl |>
    dplyr::filter(if_any("name", \(x) grepl(rx, x))) |>
    dplyr::pull("code")
}

batch_it <- function(x, size) {
  unname(split(x, rep(1:ceiling(length(x) / size), each = size)[seq_along(x)]))
}
