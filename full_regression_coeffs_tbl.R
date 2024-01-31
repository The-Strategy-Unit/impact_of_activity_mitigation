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
           central_estimate = exp(estimate),
           confidence_interval_lower = exp(estimate - 1.96 * std.error),
           confidence_interval_higher = exp(estimate + 1.96 * std.error),
           p.value = p.value) |>
    dplyr::select(pod, parametric, term, central_estimate, confidence_interval_lower, confidence_interval_higher, p.value)
  
  # Extract the non-parametric coefficients
  coefs_non_parametric <- broom::tidy(model, parametric = FALSE)
  
  # Filter to the relevant rows and do the manipulations
  coefs_non_parametric <- coefs_non_parametric |>
    mutate(pod = df_name,
           parametric = "non-parametric") |>
    dplyr::select(pod, parametric, term, edf, ref.df, p.value)
  
  # Outputs a list containing the parametric terms and non-parametric terms with labels
  return(list(parametric = coefs_parametric, non_parametric = coefs_non_parametric))
}


# Names of the data frames in the list
df_names <- names(activity_mitigators_gam_data_split)

# Use map2 from purrr to pass both the data frames and their names
model_coefs <- map2(activity_mitigators_gam_data_split, df_names, extract_model_coefs)

# We now have a list of lists. The higher level list has 4 elements - one for 
# each pod - and the lower level list contains the two data frames - one for the
# parametric terms and one for the non-parametric terms. We use the list_flatten
# function to collapse this into one list of 8 data frames.
model_coefs <- list_flatten(model_coefs)

# write the tables to a multi-worksheet workbook
openxlsx::write.xlsx(model_coefs, file = "full_model_coefs.xlsx")
