library(treemapify)
library(ggplot2)
library(dplyr)

hospitalActivity_Df_adj |>
  mutate(mitigatable = case_when(mitigatable=="none" ~ "Not mitigatable",
                                 mitigatable=="prev" ~ "Prevention",
                                 mitigatable=="rati" ~ "De-adoption",
                                 mitigatable=="reSu" ~ "Redirection & substitution",
                                 TRUE ~ NA_character_)) |> 
  filter(yr == 2013) |> 
  summarise(activity = sum(activity), .by = mitigatable) |> 
  ggplot(aes(area = activity, fill = mitigatable, label = paste0(mitigatable, "\n", round(activity/1e6,1),"m"))) +
  geom_treemap() +
  geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                    grow = TRUE) +
  #ggtitle("Activity in 2013 by mitigation class") +
  scale_fill_manual(
    values = c("#ED8B00", #de-adoption - orange
               "#005EB8", #not mitigatable - blue
               "#7C2855", #prevention - dark pink
               "#009639" #Redirection & substitution - green
    )
  ) +
  theme(legend.position="none") 



