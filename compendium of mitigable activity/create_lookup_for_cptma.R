# create unified lookup

# load in the yaml
yaml <- yaml::read_yaml(
  "compendium of mitigable activity/golem-config.yml"
)

# Abbreviate the path to the mitigators_config list
mitigator_yaml <- yaml$default$mitigators_config

# Use purrr to map over the list of categories and create the data frame
mitigator_yaml_df <- purrr::map_df(names(mitigator_yaml), function(category_name) {
  
  # Extract the relevant components for each category
  activity_type <- mitigator_yaml[[category_name]]$activity_type
  mitigator_type <- mitigator_yaml[[category_name]]$mitigators_type
  strategy_variable <- names(mitigator_yaml[[category_name]]$strategy_subset)
  measure <- mitigator_yaml[[category_name]]$y_axis_title
  
  # Return a data frame with category, element, and y_axis_title
  tidyr::tibble(
    activity_type = activity_type,
    mitigator_type = mitigator_type,
    category = category_name,
    strategy_variable = strategy_variable,
    measure = measure
  )
})

# mitigator lookup
mitigator_lookup <- read.csv("compendium of mitigable activity/mitigator_lookup.csv")

full_table <- mitigator_lookup |> 
  dplyr::inner_join(dplyr::select(
    mitigator_yaml_df,
    strategy_variable, 
    measure), by = c("Variable" = "strategy_variable")) 

# save

write.csv(full_table, "compendium of mitigable activity/combined_mitigation_lookup_rates.csv")
