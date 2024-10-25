# Assume we have ran the code to produce the paper
# This will extract the non demographic growth rate for non-mitigatable emergency / urgemt

non_mitigatable_emer <- filter(activity_mitigators_gam_data_split$IpEmer, mitigatable=="none")
non_mitigatable_emer$sex <- factor(non_mitigatable_emer$sex)

non_mitigatable_emer_gam <- gam(activity ~ year + s(age, by = sex) + offset(log(population)), 
    family = nb(link = "log"),
    weights = population_share, 
    data = non_mitigatable_emer
    )

non_mitigatable_emer_gam_results <- broom::tidy(non_mitigatable_emer_gam, parametric = TRUE)


non_mitigatable_emer_ndg <- non_mitigatable_emer_gam_results |> 
  filter(term=="year") |> 
  mutate(ndg = exp(estimate)-1,
         lower_ci = exp(estimate - 1.96 * std.error)-1,
         higher_ci = exp(estimate + 1.96 * std.error)-1) |> 
  dplyr::select(ndg, lower_ci, higher_ci) 

clipr::write_clip(non_mitigatable_emer_ndg)


#####################################################

mitigatable_emer <- activity_mitigators_gam_data_split$IpEmer
mitigatable_emer$sex <- factor(mitigatable_emer$sex)

mitigatable_emer_gam <- gam(activity ~ year + s(age, by = sex) + offset(log(population)), 
                                family = nb(link = "log"),
                                weights = population_share, 
                                data = mitigatable_emer
)

mitigatable_emer_gam_results <- broom::tidy(mitigatable_emer_gam, parametric = TRUE)


mitigatable_emer_ndg <- mitigatable_emer_gam_results |> 
  filter(term=="year") |> 
  mutate(ndg = exp(estimate)-1,
         lower_ci = exp(estimate - 1.96 * std.error)-1,
         higher_ci = exp(estimate + 1.96 * std.error)-1) |> 
  dplyr::select(ndg, lower_ci, higher_ci) 

clipr::write_clip(mitigatable_emer_ndg)



######################################################
# USE THIWS
IpEmer_model <- gam(activity ~s(age, by = sex_mitigatable) + sex + mitigatable + year + year:mitigatable + offset(log(population)),
             family = nb(link = "log"),
             weights = population_share,
             data = activity_mitigators_gam_data_split$IpEmer)

IpEmer_coefficients <- broom::tidy(IpEmer_model, parametric = TRUE)

IpEmer_results <- IpEmer_coefficients |> 
  mutate(lower_ci = exp(estimate-1.96*std.error)-1,
         higher_ci = exp(estimate+1.96*std.error)-1,
         estimate = exp(estimate)-1) |> 
  dplyr::select(term, estimate, lower_ci, higher_ci)

## calculating the std error - method 3
library(multcomp)
mitigatable_prev_mod <- broom::tidy(glht(IpEmer_model, "year + mitigatableprev:year = 0"))
mitigatable_reSu_mod <- broom::tidy(glht(IpEmer_model, "year + mitigatablereSu:year = 0"))


mitigatable_prev_estimate <- scales::percent(exp(mitigatable_prev_mod$estimate[[1]])-1, accuracy = 0.01)
mitigatable_prev_lower_ci <- scales::percent(exp(mitigatable_prev_mod$estimate[[1]] - 1.96 * mitigatable_prev_mod$std.error[[1]]) - 1, accuracy = 0.01)
mitigatable_prev_higher_ci <- scales::percent(exp(mitigatable_prev_mod$estimate[[1]] + 1.96 * mitigatable_prev_mod$std.error[[1]]) - 1, accuracy = 0.01)
mitigatable_prev_ndg <- paste0(mitigatable_prev_estimate, " (", mitigatable_prev_lower_ci, ", ", mitigatable_prev_higher_ci, ")")

mitigatable_reSu_estimate <- scales::percent(exp(mitigatable_reSu_mod$estimate[[1]])-1,accuracy = 0.01)
mitigatable_reSu_lower_ci <- scales::percent(exp(mitigatable_reSu_mod$estimate[[1]] - 1.96 * mitigatable_reSu_mod$std.error[[1]]) - 1, accuracy = 0.01)
mitigatable_reSu_higher_ci <- scales::percent(exp(mitigatable_reSu_mod$estimate[[1]] + 1.96 * mitigatable_reSu_mod$std.error[[1]]) - 1, accuracy = 0.01)
mitigatable_reSu_ndg <- paste0(mitigatable_reSu_estimate, " (", mitigatable_reSu_lower_ci, ", ", mitigatable_reSu_higher_ci, ")")


# Table showing growth for each pod and mitigation (with CIs)--------------


gam_ip_elec <- gam(activity ~ s(age, by = sex_mitigatable) + sex + mitigatable + year + year:mitigatable + offset(log(population)),
                   family = nb(link = "log"),
                   weights = population_share,
                   data = activity_mitigators_gam_data_split$IpElec)

variable_names <- c("mitigatableprev:year",
                    "mitigatablerati:year",
                    "mitigatablereSu:year")

model_results <- broom::tidy(gam_ip_elec, parametric = TRUE)





terms <- model_results  |> 
  filter(term %in% c("year",variable_names)) |> 
  convert_term_names() |> 
  mutate(name = if_else(term == "none",
                        "Growth p.a.",
                        "Difference in growth rate p.a.")) |> 
  extract_model_estimates() |> 
  dplyr::select(term, name, value) 

coefficients_of_interest <- model_results$term[model_results$term %in% variable_names]




comb_model_results <- map_dfr(coefficients_of_interest, ~get_combined_terms(gam_ip_elec, .))

comb_terms <- comb_model_results |> 
  mutate(name = "Growth p.a.") |> 
  extract_model_estimates()  |> 
  dplyr::select(term = contrast, name, value) |> 
  convert_term_names()
  
bind_rows(terms, comb_terms) |> 
  pivot_wider() |> 
  mutate(pod="IpElec", .before = 1)



# Final function ----------------------------------------------------------
extract_model_estimates <- function(tidy_results) {
  tidy_results |> 
    mutate(point_estimate = scales::percent(exp(estimate) - 1, accuracy = 0.01),
           lower_ci = scales::percent(exp(estimate - 1.96 * std.error) - 1, accuracy = 0.01),
           higher_ci = scales::percent(exp(estimate + 1.96 * std.error) - 1, accuracy = 0.01),
           value = paste0(point_estimate, " (", lower_ci, ", ", higher_ci, ")")) 
}

convert_term_names <- function(data) {
  data |> mutate(
    term = case_when(
      term == "year" ~ "none",
      grepl("prev", term) ~ "prev",
      grepl("rati", term) ~ "rati",
      grepl("reSu", term) ~ "reSu",
      TRUE ~ NA_character_))
}

get_combined_terms <- function(model, term) {
  broom::tidy(multcomp::glht(model, paste0("year + ", term, " = 0")))
}

extract_total_model_results <- function(df, df_name) {
  gam <- gam(activity ~ s(age, by = sex_mitigatable) + sex + mitigatable + year + year:mitigatable + offset(log(population)),
             family = nb(link = "log"),
             weights = population_share,
             data = df)
  
  model_results <- broom::tidy(gam, parametric = TRUE)
  
  terms <- model_results  |> 
    filter(term %in% c("year",variable_names)) |> 
    convert_term_names() |> 
    mutate(name = if_else(term == "none",
                          "Growth p.a.",
                          "Difference in growth rate p.a.")) |> 
    extract_model_estimates() |> 
    dplyr::select(term, name, value) 
  
  coefficients_of_interest <- model_results$term[model_results$term %in% variable_names]
  
  comb_model_results <- map_dfr(coefficients_of_interest, ~get_combined_terms(gam, .))
  
  comb_terms <- comb_model_results |> 
    mutate(name = "Growth p.a.") |> 
    extract_model_estimates()  |> 
    dplyr::select(term = contrast, name, value) |> 
    convert_term_names()
  
  bind_rows(terms, comb_terms) |> 
    pivot_wider() |> 
    mutate(pod=df_name, .before = 1)
  
  
  
}

variable_names <- c("mitigatableprev:year",
                    "mitigatablerati:year",
                    "mitigatablereSu:year")

extract_total_model_results(activity_mitigators_gam_data_split$IpEmer, "IpEmer")

df_names <- names(activity_mitigators_gam_data_split)

# Use map2 from purrr to pass both the data frames and their names
total_model_results <- map2(activity_mitigators_gam_data_split, df_names, extract_total_model_results) |> 
  bind_rows()

