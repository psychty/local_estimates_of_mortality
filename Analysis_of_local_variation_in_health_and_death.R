library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats',"rgdal", 'rgeos', "tmaptools", 'sp', 'sf', 'maptools', 'leaflet', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'grid', 'aweek', 'xml2', 'rvest', 'officer', 'flextable', 'viridis', 'epitools', 'patchwork', 'lemon', 'PostcodesioR')

ltla_df <- read_csv("GitHub/local_estimates_of_mortality/ltla_file_local_health_mortality_le.csv")


msoa_df <- read_csv("GitHub/local_estimates_of_mortality/msoa_file_local_health_mortality_le.csv")
