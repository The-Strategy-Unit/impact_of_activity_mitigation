total_model_results_plot_data <- total_model_results |> 
  mutate(
    growth = 
    as.numeric(
      substring(
        word(`Growth p.a.`),1,nchar(word(`Growth p.a.`))-1))/100) |> 
  mutate(pod = case_when(pod=="IpElec" ~ "Elective inpatient",
                         pod=="IpEmer" ~ "Non-elective inpatient",
                         pod=="opAtt" ~ "Outpatients",
                         pod=="edAtt" ~ "Emergency department",
                         TRUE ~ NA_character_),
         Mitigation = case_when(term=="none" ~ "Not migitable",
                                term=="prev" ~ "Prevention",
                                term=="rati" ~ "De-adoption",
                                term=="reSu" ~ "Redirection & substitution",
                                TRUE ~ NA_character_))


ggplot(total_model_results_plot_data,
       aes(x = pod, y = growth, fill = term, label = scales::percent(growth))) +
  geom_col(position = position_dodge2(width = 0.9, preserve = "single")) + # Adjusted dodging
  geom_text(position = position_dodge2(width = 0.9, preserve = "single"), 
            vjust = -0.5) + 
  labs(title = "Growth rates by pod and mitigation") +
  xlab("Point of delivery") +
  ylab("Growth rate") +
  scale_y_continuous(labels = scales::percent) +
  NHSRtheme::theme_nhs() +
  NHSRtheme::scale_fill_nhs(
    labels = c("Not migitable", 
               "Prevention", 
               "De-adoption", 
               "Redirection & substitution")) 

# to add: error bars (using the confidence intervals)
