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
  mutate(Proportions = Freq/sum(Freq))

ggplot(proportions) + 
  aes(x = reorder(Classification, Proportions), y = Proportions) + 
  geom_bar(stat='identity') + 
  labs(x = 'BMI Classification', 
       y = 'Proportion of Total Athletes', 
       title = 'A Barplot Showing the Proportion of Total Athletes in Each BMI Classification') + 
  scale_y_continuous(labels = scales::label_percent())

mean_bmi_per_sport <- athlete_data %>%
  group_by(Sport_Type) %>% 
  select(Sport_Type, BMI) %>%
  summarise(mean_bmi = mean(BMI))

ggplot(mean_bmi_per_sport) + 
  aes(x = reorder(Sport_Type, mean_bmi), y = mean_bmi) + 
  geom_bar(stat='identity') + 
  labs(x = 'Type of Sport', 
       y = 'Mean BMI', 
       title = 'A Barplot Showing the Mean BMI per Sport') + 
  theme(axis.text.x = element_text(angle = 90)) + 
  geom_hline(yintercept = 25) + 
  geom_hline(yintercept = 18.5) #talk to the teachers about if it is redundant 

proportion_per_sport <- athlete_data %>% 
  select(Sport_Type, Classification) %>%
  group_by(Sport_Type, Classification) %>% 
  summarise(number = n()) %>% 
  pivot_wider(names_from = Classification, values_from = number) %>%
  mutate(Obese = ifelse(is.na(Obese), 0, Obese)) %>%
  mutate(Overweight = ifelse(is.na(Overweight), 0, Overweight)) %>%
  mutate(Underweight = ifelse(is.na(Underweight), 0, Underweight)) %>%
  mutate(proportion_overweight = Overweight/(Underweight+Healthy+Overweight+Obese)) %>% 
  mutate(proportion_obese = Obese/(Underweight+Healthy+Overweight+Obese))

ggplot(proportion_per_sport, aes(fill=, y=, x=)) + 
  geom_bar(position="stack", stat="identity")
