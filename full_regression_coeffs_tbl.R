extract_model_coefs <- function(df, df_name) {
  # Fit the GAM model
  model <- gam(activity ~s(age, by = sex_mitigatable) + sex + mitigatable + yearN + yearN:mitigatable + offset(log(population)),
               family = nb(link = "log"),
               weights = population_share,
               data = df)
  
  # Extract the coefficients
  coefs <- broom::tidy(model, parametric = TRUE)
  
  # Filter to the relevant rows and do the manipulations
  coefs <- coefs |>
    mutate(pod = df_name,
           central_estimate = exp(estimate),
           confidence_interval_lower = exp(estimate - 1.96 * std.error),
           confidence_interval_higher = exp(estimate + 1.96 * std.error),
           p.value = p.value) |>
    dplyr::select(pod, term, central_estimate, confidence_interval_lower, confidence_interval_higher, p.value)

}

# Names of the data frames in the list
df_names <- names(activity_mitigators_gam_data_split)

# Use map2 from purrr to pass both the data frames and their names
model_coefs <- map2(activity_mitigators_gam_data_split, df_names, extract_model_coefs)

# Combine all results into a single data frame
model_coefs <- bind_rows(model_coefs)

# write to csv
write.csv(model_coefs, file="full_model_coefs.csv")
