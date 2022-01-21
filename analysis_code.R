library('tidyverse')
athlete_data <- read_csv('filtered_data3.csv')
athlete_data <- athlete_data %>%
  filter(Height > 1.45) %>%
  filter(Height < 2.50) %>%
  filter(Weight > 35.0) %>%
  filter(Weight < 250.0) %>% 
  rename(Sport_Type = 'Type of Sportsman') %>%
  mutate(BMI = Weight/(Height*Height)) %>% 
  mutate(Classification = ifelse(BMI < 18.5, 'Underweight', 
                                 ifelse(BMI >= 18.5 & BMI < 25.0, 'Healthy', 
                                        ifelse(BMI >= 25.0 & BMI < 30.0, 'Overweight', 'Obese')))) %>% 
  mutate(Obesity_Type = ifelse(Classification == 'Obese' & BMI >= 30.0 & BMI < 34.9, 'Obese Class I',
                               ifelse(Classification == 'Obese' & BMI >= 35.0 & BMI < 39.9, 'Obese Class II',
                                      ifelse(Classification == 'Obese' & BMI >= 40.0, 'Obese Class III', 'N/A'))))


proportions <- as.data.frame(table(athlete_data$Classification))
proportions <- proportions %>% 
  rename(Classification = Var1) %>% 
  mutate(Classification = fct_relevel(Classification, 
              'Underweight', 'Healthy', 'Overweight', 'Obese')) %>%
  mutate(Proportions = Freq/sum(Freq))

ggplot(proportions) + 
  aes(x = Classification, y = Proportions) + 
  geom_bar(stat='identity', fill = '#4a8cff') +
  theme_light() + 
  labs(x = 'BMI Classification', 
       y = 'Proportion of Total Athletes', 
       title = 'Proportion of Total Athletes in Each BMI Classification') + 
  scale_y_continuous(labels = scales::label_percent())
ggsave('graph1.jpg')

mean_bmi_per_sport <- athlete_data %>%
  group_by(Sport_Type) %>% 
  select(Sport_Type, BMI) %>%
  summarise(mean_bmi = mean(BMI)) %>%
  arrange(mean_bmi)

ggplot(mean_bmi_per_sport) + 
  aes(x = reorder(Sport_Type, mean_bmi), y = mean_bmi) + 
  geom_bar(stat='identity', fill = '#4a8cff') + 
  labs(x = 'Type of Sport', 
       y = 'Mean BMI', 
       title = 'Mean BMI per Sport') +
  theme_light() + 
  theme(axis.text.x = element_text(angle = 60, vjust = 0.9, hjust = 0.9), 
        strip.background = element_blank()) + 
  geom_hline(yintercept = 25) + 
  geom_hline(yintercept = 18.5) + 
  facet_grid(~(Sport_Type == 'other'), scales = 'free_x', space = 'free')
ggsave('graph2.jpg')

proportion_per_sport <- athlete_data %>% 
  select(Sport_Type, Classification) %>%
  group_by(Sport_Type, Classification) %>% 
  summarise(number = n()) %>% 
  pivot_wider(names_from = Classification, values_from = number) %>%
  mutate(Obese = ifelse(is.na(Obese), 0, Obese)) %>%
  mutate(Overweight = ifelse(is.na(Overweight), 0, Overweight)) %>%
  mutate(Underweight = ifelse(is.na(Underweight), 0, Underweight)) %>%
  mutate(proportion_over = (Overweight + Obese)/(Underweight+Healthy+Overweight+Obese)) %>% 
  mutate(proportion_under = Underweight/(Underweight+Healthy+Overweight+Obese)) %>% 
  pivot_longer(cols = c(proportion_over, proportion_under))

ggplot(proportion_per_sport, aes(fill = name, y = value, x = Sport_Type)) + 
  geom_bar(position="dodge", stat="identity") +
  scale_y_continuous(labels = scales::label_percent()) +
  theme_light() + 
  labs(x = 'Type of Sport', 
       y = 'Proportion', 
       title = 'Proportion of Athletes Who Are Under- or Over- Weight per Sport', 
       fill = 'Key') + 
  scale_fill_manual(values = c(proportion_over = '#4a8cff', proportion_under = '#003ba3'), labels = c("Overweight/Obese", "Underweight")) + 
  theme(axis.text.x = element_text(angle = 60, vjust = 0.9, hjust = 0.9))
ggsave('graph4.jpg')

source('analysis_code.R')

# We did this quite a bit different from your graph,
# so we created a new variable to indicate the difference.

proportion_per_sport_2 <- athlete_data %>%
  group_by(Sport_Type, Classification) %>%
  summarise(number = n()) %>%
  ungroup() %>%
  # Reorder the levels
  # (This part basically guarantees the ordering on the x-axis for the final plot)
  pivot_wider(names_from = Classification, values_from = number, values_fill = 0) %>%
  mutate(
    # `proportion` will be the thing that the x-axis is sorted by
    proportion = (Obese + Overweight + Underweight) / (Overweight + Healthy + Obese + Underweight),
    Sport_Type = factor(Sport_Type),  # The reordering is done by creating a 'factor',
    Sport_Type = fct_reorder(Sport_Type, -proportion)  # And the reordering the levels of the factor
  ) %>%
  select(-proportion) %>%
  pivot_longer(c(everything(), -Sport_Type), names_to = 'Classification') %>%
  mutate(
    # Reordering the order of the stacking of the bars
    Classification = factor(Classification),
    Classification = fct_relevel(Classification, rev(c('Underweight', 'Healthy', 'Overweight', 'Obese')))
  ) %>%
  # Lastly, we calculate the proportional values,
  group_by(Sport_Type) %>%
  mutate(proportion = value / sum(value)) %>%
  ungroup() %>%
  # ... and toss out 'healthy'
  filter(Classification != 'Healthy')

ggplot(proportion_per_sport_2) +
  aes(x = Sport_Type, y = proportion, fill = Classification) +
  geom_col() +
  scale_y_continuous(labels = scales::label_percent()) +
  theme_light() + 
  labs(x = 'Type of Sport', 
       y = 'Proportion', 
       title = 'Proportion of Athletes Who Are Not Classified as Healthy per Sport', 
       fill = 'Key') + 
  scale_fill_manual(values = c(Underweight = '#003ba3', Overweight = '#0d5fee', Obese = '#4a8cff'), labels = c("Underweight", "Overweight", 'Obese')) + 
  theme(
    axis.text.x = element_text(angle = 60, vjust = 0.9, hjust = 0.9),
    strip.background = element_blank()
  ) +
  facet_grid(~(Sport_Type == 'other'), scales = 'free_x', space = 'free')
ggsave('graph3.jpg')

hw <- read_csv('athleteshw.csv', col_types = 'nnc')
hw <- hw %>%
  rename(Sport_Type = 'Type of Sportsman') %>%
  mutate(has_values = ifelse(is.na(Weight) & is.na(Height), 'no values', 'values')) %>%
  group_by(Sport_Type, has_values) %>%
  summarise(number = n()) 
hw <- hw[-c(1,2,3,4,5,6,7,8),]

ggplot(hw) + 
  aes(fill = has_values, x = Sport_Type, y = number) + 
  geom_bar(position="dodge", stat="identity") + 
  theme_light() + 
  labs(x = 'Type of Sport', 
       y = 'Number of Athletes', 
       title = 'Number of Athletes With vs. Without Height and Weight Data', 
       fill = 'Key') + 
  theme(axis.text.x = element_text(angle = 60, vjust = 0.9, hjust = 0.9)) + 
  scale_fill_manual(values = c('no values' = '#003ba3', 'values' = '#4a8cff'), labels = c("No Values", 'Values'))
ggsave('graph5.jpg')

