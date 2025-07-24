
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


