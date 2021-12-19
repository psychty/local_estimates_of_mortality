library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats',"rgdal", 'rgeos', "tmaptools", 'sp', 'sf', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'viridis', 'epitools', 'patchwork', 'lemon')

df_raw <- read_delim("~/Documents/Repositories/local_estimates_of_mortality/ltla_raw.csv", ";", escape_double = FALSE, trim_ws = TRUE) %>% 
bind_rows(read_delim("~/Documents/Repositories/local_estimates_of_mortality/utla_raw.csv", ";", escape_double = FALSE, trim_ws = TRUE)) %>% 
  filter(Label %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing', 'West Sussex'))

msoa_lookup <- read_csv('https://visual.parliament.uk/msoanames/static/MSOA-Names-Latest.csv') %>% 
  select(msoa11cd, msoa11hclnm, Laname) %>% 
  filter(Laname %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing', 'West Sussex'))


msoa_df <- read_delim("~/Documents/Repositories/local_estimates_of_mortality/msoa_raw.csv", ";", escape_double = FALSE, trim_ws = TRUE) %>% 
  filter(Code %in% msoa_lookup$msoa11cd) %>% 
  left_join(msoa_lookup, by = c('Code' = 'msoa11cd')) %>% 
  rename(All_cause_deaths_all_ages = 'Deaths from all causes, all ages',
         All_case_deaths_under_75 = 'Deaths from all causes,  under 75 years',
         Life_expectancy_at_birth_female = 'Life expectancy at birth for females',
         Life_expectancy_at_birth_male = 'Life expectancy at birth for males',
         Preventable_deaths_under_75 = 'Deaths from causes considered preventable, under 75 years, SMR',
         Stroke_deaths_all_ages = 'Deaths from stroke, all ages',
         CHD_deaths_all_ages = 'Deaths from coronary heart disease, all ages',
         Respiratory_deaths_all_ages = 'Deaths from respiratory diseases, all ages',
         Circulatory_deaths_all_ages = 'Deaths from circulatory disease, all ages',
         Circulatory_deaths_under_75 = 'Deaths from circulatory disease,  under 75 years',
         Cancer_deaths_all_ages = 'Deaths from all cancer, all ages',
         Cancer_deaths_under_75 = 'Deaths from all cancer,  under 75 years',
         Msoa_name = 'msoa11hclnm') %>% 
  select(Code, Label, Msoa_name, Laname, Life_expectancy_at_birth_female, Life_expectancy_at_birth_male, All_cause_deaths_all_ages, Stroke_deaths_all_ages, CHD_deaths_all_ages, Circulatory_deaths_all_ages, Cancer_deaths_all_ages, All_case_deaths_under_75, Preventable_deaths_under_75, Circulatory_deaths_under_75, Cancer_deaths_under_75)


msoa_df %>% 
  names()
