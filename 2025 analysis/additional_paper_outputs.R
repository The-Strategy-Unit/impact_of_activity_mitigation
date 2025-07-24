
# plots -------------------------------------------------------------------

## Figure 1: Counts of hospital activity across points of delivery and mitigation 
## class from 2011/12 to 2019/20.

# Create a mapping between fyear and financial year labels
fyear_labels <- current_mitigators_data |> 
  distinct(fyear) |> 
  arrange(fyear) |> 
  mutate(fyear_label = paste0(fyear, "/", substr(fyear + 1, 3, 4)))

# Join back to original data
current_mitigators_data <- current_mitigators_data |> 
  left_join(fyear_labels, by = "fyear")

# Plot: Absolute Activity
activity_by_mitigation_plot <- current_mitigators_data |> 
  summarise(activity = sum(activity), .by = c(fyear, fyear_label, pod, mitigation_type)) |> 
  mitigator_lengthener_fn() |> 
  pod_lengthener_fn() |> 
  ggplot(aes(x = fyear, y = activity, colour = mitigatable_long)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = scales::label_number(suffix = "m", scale = 1e-6), limits = c(0, NA)) +
  facet_wrap(~pod_long, scales = "free_y") +
  scale_x_continuous(
    breaks = fyear_labels$fyear,
    labels = fyear_labels$fyear_label
  ) +
  NHSRtheme::scale_colour_nhs() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_blank()) +
  guides(colour = guide_legend(nrow = 2)) +
  xlab("Financial year") +
  ylab("Activity")


## Figure 2 Activity volumes indexed to the values in the initial year of 2011/12 
## across points of delivery and mitigation class from 2011/12 to 2019/20.
indexed_activity_by_mitigation_plot <- current_mitigators_data |> 
  summarise(activity = sum(activity), .by = c(fyear, fyear_label, pod, mitigation_type)) |> 
  mitigator_lengthener_fn() |> 
  pod_lengthener_fn() |> 
  mutate(activity_indexed = activity / first(activity, order_by = fyear), .by = c(pod, mitigatable_long)) |> 
  ggplot(aes(x = fyear, y = activity_indexed, colour = mitigatable_long)) + 
  geom_line(linewidth = 1) +
  facet_wrap(~pod_long, scales = "free_y") +
  scale_x_continuous(
    breaks = fyear_labels$fyear,
    labels = fyear_labels$fyear_label
  ) +
  NHSRtheme::scale_colour_nhs() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_blank()) +
  guides(colour = guide_legend(nrow = 2)) +
  xlab("Financial year") +
  ylab("Activity (indexed)")

# Save plots
ggplot2::ggsave("2025 analysis/plots/activity_by_mitigation_plot.png", activity_by_mitigation_plot)
ggplot2::ggsave("2025 analysis/plots/indexed_activity_by_mitigation_plot.png", indexed_activity_by_mitigation_plot)


# Tables s1-4 -------------------------------------------------------------
age_grouper <- function(data) {
  data |> 
    mutate(
      age_group = case_when(
        age < 18 ~ "0-17",
        age < 65 ~ "18-64",
        age >= 65 ~ "65+",
        TRUE ~ NA_character_
      ))
}

# add the necessary columns for the groupings
activity_supplementary_table_data <- current_mitigators_data |>
  age_grouper() |> 
  region_lookup_fn(resgor_ons) |> 
  mitigator_lengthener_fn()

population_supplementary_table_data <- population |> 
  age_grouper() |> 
  region_lookup_fn(rgn09cd)

# and split the mitigation data on the 

activity_supplementary_table_data <- split(
  activity_supplementary_table_data, 
  activity_supplementary_table_data$pod
)

# This gets the activity by grouping variable, with the  proportions falling
# into each mitigation type in columns
activity_by_group_mitig_fn <- function(activity_data, group_var) {
  activity_data |> 
    summarise(activity = sum(activity),
              .by = c({{group_var}}, mitigatable_long)) |> 
    arrange(desc(mitigatable_long)) |> 
    pivot_wider(
      names_from = mitigatable_long,
      values_from = activity,
      values_fill = 0
    ) |>
    mutate(total_activity = rowSums(across(where(is.numeric))),
           .after = {{group_var}}) |>
    mutate(across(
      where(is.numeric) & !matches("total_activity"),
      ~ .x / total_activity
    ))
}


# This gets the population by grouping variable (which in an input)
population_by_group_fn <- function(population_data, group_var) {
  population_data |> 
    summarise(population = sum(population),
              .by = {{group_var}})
  
}

# This gets the total row for each pod
total_row_fn <- function(activity_data, population_data) {
  total_activity = activity_data |> 
    activity_by_group_mitig_fn(NULL)
  
  total_population = population_data |> 
    population_by_group_fn(NULL)
  
  bind_cols(total_activity, total_population) |> 
    mutate(activity_rate = total_activity / population) |> 
    select(!population) |> 
    select(total_activity, activity_rate, everything()) |> 
    mutate(grouping = "total",
           levels = NA,
           .before = total_activity)
  
}

# This gets all the subtables for each pod
sub_table_fn <- function(activity_data, population_data, group_var) {
  activity_by_mitig = activity_data |> 
    activity_by_group_mitig_fn({{group_var}})
  
  population_by_group = population_data |> 
    population_by_group_fn({{group_var}})
  
  group_var_str = rlang::as_name(rlang::ensym(group_var))
  
  joined_data = inner_join(
    activity_by_mitig,
    population_by_group,
    by = group_var_str
  ) 
  
  # get the activity rate
  output = joined_data |> 
    mutate(activity_rate = total_activity / population,
           .after = total_activity) |> 
    select(!population)
  
  # Rename the grouping column to 'levels' and add a 'grouping' column
  output = output |>
    rename(levels = all_of(group_var_str)) |>
    mutate(levels = as.character(levels),
           grouping = group_var_str, .before = levels)
  
  
  output
  
}

group_vars <- c("sex", "age_group", "imd_quintile",  "region")

# Iterate over each pod (element in the activity data list)
combined_output_list <- map(
  activity_supplementary_table_data,
  function(activity_df) {
    
    # take the total
    total_row <- total_row_fn(activity_df, population_supplementary_table_data)
    
    # For each pod, iterate over all grouping variables, bind the rows
    group_wise_table <- map_dfr(group_vars, function(group_var_str) {
      group_sym <- rlang::sym(group_var_str)  # convert to symbol for tidy eval
      sub_table_fn(activity_df, population_supplementary_table_data, !!group_sym) 
    }) |> 
      mutate(grouping = factor(grouping, levels = group_vars)) |> 
      arrange(grouping, levels)  
    
    bind_rows(total_row, group_wise_table)
    
    
  }
)


# Final issue: getting the cuts by ICD-10 chapter for apc, specialty type for 
# opa, and arrival type for aae when the population data is not cut by these

# step 1: define a lookup between pod and cut
special_cut_lookup <- list(
  aae = "group",
  elective = "chapter_number",
  `non-elective` = "chapter_number",
  opa = "type"
  
)

#step 2: Write a special_cut_fn()
special_cut_fn <- function(activity_data, population_data, group_var) {
  group_var_str = rlang::as_name(rlang::ensym(group_var))
  
  activity_summary <- activity_data |> 
    activity_by_group_mitig_fn({{group_var}})
  
  total_population <- population_data |> 
    population_by_group_fn(NULL)
  
  bind_cols(activity_summary, total_population) |> 
    mutate(activity_rate = total_activity / population,
           .after = total_activity) |> 
    select(!population) |> 
    rename(levels = all_of(group_var_str)) |>
    mutate(levels = as.character(levels),
           grouping = group_var_str, .before = levels) 
  
  
  
  
}

# Step 3: iterate to create the four final outputs
special_cut_outputs <- imap(
  special_cut_lookup,
  function(group_sym, pod_name) {
    activity_df <- activity_supplementary_table_data[[pod_name]]
    
    special_cuts <- special_cut_fn(activity_df, population_supplementary_table_data, !!group_sym)
    
    if(group_sym == "chapter_number") {
      special_cuts <- special_cuts |> 
        mutate(levels = factor(levels, levels = icd10_levels))
    }
    
    special_cuts |> 
      arrange(levels)
    
  }
)

# Combine each pod from both lists by stacking rows (e.g., elective + elective)
final_output_list <- purrr::map2(
  combined_output_list,
  special_cut_outputs,
  ~ bind_rows(.x, .y)
)

openxlsx::write.xlsx(final_output_list, "2025 analysis/supplementary_tables.xlsx")

