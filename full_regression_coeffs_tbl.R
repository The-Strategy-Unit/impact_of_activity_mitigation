extract_model_coefs <- function(df, df_name) {
  # Fit the GAM model
  model <- gam(activity ~s(age, by = sex_mitigatable) + sex + mitigatable + yearN + yearN:mitigatable + offset(log(population)),
               family = nb(link = "log"),
               weights = population_share,
               data = df)
  
  # Extract the parametric coefficients
  coefs_parametric <- broom::tidy(model, parametric = TRUE)
  
  # Filter to the relevant rows and do the manipulations
  coefs_parametric <- coefs_parametric |>
    mutate(pod = df_name,
           parametric = "parametric",
           central_estimate = estimate,
           confidence_interval_95pc_lower = estimate - 1.96 * std.error,
           confidence_interval_95pc_higher = estimate + 1.96 * std.error,
           p.value = p.value) |>
    dplyr::select(pod, parametric, term, central_estimate, confidence_interval_95pc_lower, confidence_interval_95pc_higher, p.value)
  
  
}


# Names of the data frames in the list
df_names <- names(activity_mitigators_gam_data_split)

# Use map2 from purrr to pass both the data frames and their names
model_coefs <- map2(activity_mitigators_gam_data_split, df_names, extract_model_coefs)


# write the tables to a multi-worksheet workbook
openxlsx::write.xlsx(model_coefs, file = "full_model_coefs.xlsx")
