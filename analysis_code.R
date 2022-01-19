library('tidyverse')
athlete_data <- read_csv('filtered_data2.csv')
athlete_data <- athlete_data %>%
  filter(Height > 1.45) %>%
  filter(Height < 2.50) %>%
  filter(Weight > 35.0) %>%
  filter(Weight < 250.0) %>% 
  mutate(BMI = Weight/(Height*Height)) %>% 
  mutate(Classification = ifelse(BMI < 18.5, 'Underweight', 
                                 ifelse(BMI >= 18.5 & BMI < 25.0, 'Healthy', 
                                        ifelse(BMI >= 25.0 & BMI < 30.0, 'Overweight', 'Obese')))) %>%
  group_by(Classification)
  
         