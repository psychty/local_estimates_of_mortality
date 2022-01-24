library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats',"rgdal", 'rgeos', "tmaptools", 'sp', 'sf', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'viridis', 'epitools', 'patchwork', 'lemon')

df_raw <- read_delim("~/GitHub/local_estimates_of_mortality/ltla_raw.csv", ";", escape_double = FALSE, trim_ws = TRUE) %>% 
bind_rows(read_delim("~/GitHub/local_estimates_of_mortality/utla_raw.csv", ";", escape_double = FALSE, trim_ws = TRUE)) %>% 
  filter(Label %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing', 'West Sussex'))

msoa_lookup <- read_csv('https://visual.parliament.uk/msoanames/static/MSOA-Names-Latest.csv') %>% 
  select(msoa11cd, msoa11hclnm, Laname) %>% 
  filter(Laname %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing', 'West Sussex'))

msoa_df <- read_delim("~/GitHub/local_estimates_of_mortality/msoa_raw.csv", ";", escape_double = FALSE, trim_ws = TRUE) %>% 
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

msoa_boundaries_json <- geojson_read(paste0('https://raw.githubusercontent.com/psychty/wsx_covid_datapack_public/master/Source%20files/failsafe_msoa_boundary.geojson'),  what = "sp") %>% 
  filter(MSOA11NM %in% msoa_df$Label) %>%
  arrange(MSOA11NM)

df <- data.frame(ID = character())

# Get the IDs of spatial polygon
for (i in msoa_boundaries_json@polygons ) { df <- rbind(df, data.frame(ID = i@ID, stringsAsFactors = FALSE))  }

# and set rowname = ID
row.names(msoa_df) <- df$ID

# Then use df as the second argument to the spatial dataframe conversion function:
msoa_boundaries_json <- SpatialPolygonsDataFrame(msoa_boundaries_json, msoa_df)  

# geojson_write(ms_simplify(geojson_json(utla_ua_boundaries_rate_geo), keep = 0.2), file = paste0(output_directory_x, '/utla_covid_rate_latest.geojson'))

geojson_write(ms_simplify(geojson_json(msoa_boundaries_json), keep = 0.2), file = paste0('~/GitHub/local_estimates_of_mortality/msoa_local_health_latest.geojson'))
