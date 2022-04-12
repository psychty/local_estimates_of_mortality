library(easypackages)

# libraries(c("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'stringr'))
libraries(c("readxl", "readr", "png", "scales", "tidyverse", 'ggtext', 'd3r', 'igraph'))

github_repo <- paste0('~/Github/local_estimates_of_mortality/')

arc_theme = function(){
  theme(
    plot.title = element_text(colour = "#000000", face = "bold", size = 12),
    plot.subtitle = element_text(colour = "#000000", size = 11),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "#FFFFFF"),
    legend.position = "bottom",
    legend.title = element_text(colour = "#000000", size = 9, face = "bold"),
    legend.background = element_rect(fill = "#ffffff"),
    legend.key = element_rect(fill = "#ffffff", colour = "#ffffff"),
    legend.text = element_text(colour = "#000000", size = 9),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank()
  )
}

msoa_names <- read_csv('https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest.csv') %>%
  select(msoa11cd, msoa11hclnm, Laname) %>%
  rename(Area_Code = msoa11cd)

# Local Health data from fingertips
local_health_metadata <- read_csv('https://fingertips.phe.org.uk/api/indicator_metadata/csv/by_profile_id?profile_id=143') %>%
  rename(ID = 'Indicator ID',
         Source = 'Data source') %>% 
  select(ID, Definition, Rationale, Methodology, Source)

msoa_local_health_data <- read_csv('https://fingertips.phe.org.uk/api/all_data/csv/by_profile_id?child_area_type_id=3&parent_area_type_id=402&profile_id=143&parent_area_code=E10000032') %>% 
  filter(is.na(Category)) %>% 
  select(!c('Parent Code', 'Parent Name', 'Category Type', 'Category', 'Lower CI 99.8 limit', 'Upper CI 99.8 limit', 'Recent Trend', 'New data', 'Compared to goal')) %>% 
  rename(ID = 'Indicator ID',
         Indicator_Name = 'Indicator Name',
         Area_Code = 'Area Code',
         Area_Name = 'Area Name',
         Type = 'Area Type',
         Period = 'Time period',
         Lower_CI = 'Lower CI 95.0 limit',
         Upper_CI = 'Upper CI 95.0 limit',
         Numerator = 'Count',
         Compared_to_eng = 'Compared to England value or percentiles',
         Compared_to_wsx = 'Compared to Counties & UAs (from Apr 2021) value or percentiles',
         Note = 'Value note') %>% 
  mutate(Indicator = trimws(paste(ifelse(Indicator_Name == 'Life expectancy at birth, (upper age band 90+)', Sex, ''), Indicator_Name, Age, Period, sep = ' '), which = 'left')) %>% 
  select(ID, Indicator, Area_Code, Area_Name, Value, Lower_CI, Upper_CI, Numerator, Denominator, Note, Compared_to_wsx, Compared_to_eng, Sex)

LE_data <- msoa_local_health_data %>% 
  filter(ID == '93283') %>% 
  left_join(msoa_names, by = 'Area_Code') %>%
  select(ID, Area_Code, Area_Name, msoa11hclnm, Laname, Sex, Value) %>% 
  mutate(Area_type_label = factor(ifelse(Area_Name == 'West Sussex', 'West Sussex', ifelse(Area_Name == 'England', 'England', 'West Sussex Neighbourhoods')), levels = c('West Sussex Neighbourhoods', 'West Sussex', 'England'))) %>% 
  mutate(msoa11hclnm = ifelse(Area_Name == 'West Sussex', 'West Sussex', ifelse(Area_Name == 'England', 'England', msoa11hclnm))) %>% 
  arrange(Area_type_label) %>% 
  mutate(Laname_ns = gsub(' ','_', Laname))

#  Add msoa deprivation data so that we can use one data source for the scatter
lookup <- read_csv('https://opendata.arcgis.com/datasets/65664b00231444edb3f6f83c9d40591f_0.csv') %>% 
  select(LSOA11CD, MSOA11CD, MSOA11NM) %>% 
  unique()

IMD_2019 <- read_csv('https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/845345/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators_3.csv') %>% 
  select("LSOA code (2011)",  "Local Authority District name (2019)", "Index of Multiple Deprivation (IMD) Score",  "Total population: mid 2015 (excluding prisoners)" ) %>% 
  rename(LSOA11CD = 'LSOA code (2011)',
         LTLA = 'Local Authority District name (2019)',
         IMD_2019_score = 'Index of Multiple Deprivation (IMD) Score',
         Population = 'Total population: mid 2015 (excluding prisoners)') %>%
  mutate(Pop_weighted_score = IMD_2019_score * Population) %>% 
  left_join(lookup, by = 'LSOA11CD') %>% 
  group_by(MSOA11CD) %>% 
  summarise(Pop_weighted_imd_score = sum(Pop_weighted_score),
            Population = sum(Population)) %>% 
  mutate(Pop_weighted_imd_score = Pop_weighted_imd_score / Population) %>% 
  arrange(desc(Pop_weighted_imd_score)) %>% 
  mutate(Pop_weighted_rank = rank(desc(Pop_weighted_imd_score))) %>% 
  left_join(read_csv('https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest.csv')[c('msoa11cd', 'msoa11hclnm')], by = c('MSOA11CD' = 'msoa11cd')) %>% 
  select(MSOA11CD, msoa11hclnm, Population, Pop_weighted_imd_score, Pop_weighted_rank) %>% 
  mutate(Pop_weighted_decile = abs(ntile(Pop_weighted_imd_score, 10) - 11)) 

LE_data <- LE_data %>% 
  left_join(IMD_2019[c('MSOA11CD', 'Pop_weighted_imd_score', 'Pop_weighted_rank')], by = c('Area_Code' = 'MSOA11CD'))

wsx_LE <- LE_data %>% 
  filter(Area_Name == 'West Sussex') %>% 
  pivot_wider(names_from = 'Sex',
              values_from = 'Value')

Wsx_le_text <- paste0('Males born in West Sussex can expect to live, on average, <b>', round(wsx_LE$Male, 1), ' years</b>. This is ', round(wsx_LE$Female - wsx_LE$Male, 1), ' years lower than the life expectancy for females (<b>', round(wsx_LE$Female, 1), ' years</b>).')

lowest_msoa_males <- LE_data %>%
  filter(Sex == 'Male') %>% 
  filter(Value == min(Value, na.rm = TRUE))

lowest_msoa_females <- LE_data %>% 
  filter(Sex == 'Female') %>% 
  filter(Value == min(Value, na.rm = TRUE))

highest_msoa_males <- LE_data %>% 
  filter(Sex == 'Male') %>% 
  filter(Value == max(Value, na.rm = TRUE))

highest_msoa_females <- LE_data %>% 
  filter(Sex == 'Female') %>% 
  filter(Value == max(Value, na.rm = TRUE))

WSX_male_LE_data_text <- paste0('The gap in male life expectancy<br>between the highest neighbourhood (', highest_msoa_males$msoa11hclnm, ', ', round(highest_msoa_males$Value, 1), ' years) and the lowest (', lowest_msoa_males$msoa11hclnm, ', ', round(lowest_msoa_males$Value,1), ' years) in West Sussex is <b>', round(highest_msoa_males$Value - lowest_msoa_males$Value, 1), ' years</b>.')

wsx_eng_text <- paste0('Compared to England overall, life expectancy is around <b>one year higher in West Sussex</b>, for both males and females. However, there is a lot of variation in life expectancy across smaller areas in the county.')

WSX_female_LE_data_text <- paste0('Females born in the highest life expectancy neighbourhood (', highest_msoa_females$msoa11hclnm, ', ', round(highest_msoa_females$Value, 1), ' years), can expect to live, on average, <b>', round(highest_msoa_females$Value - lowest_msoa_females$Value, 1), ' years longer</b> than females born in the lowest life expectancy neighbourhood (', lowest_msoa_females$msoa11hclnm, ', ',  round(lowest_msoa_females$Value, 1), ' years).')

LE_labels <- data.frame(ID = c(1,2,3,4,5, 6), Label = c(paste0('West Sussex <b>male</b><br>Life expectancy<br>at birth: <b>', round(wsx_LE$Male, 1), ' years</b>'), paste0('West Sussex <b>female</b><br>Life expectancy<br>at birth: <b>', round(wsx_LE$Female, 1), ' years</b>'), Wsx_le_text, wsx_eng_text, WSX_male_LE_data_text, WSX_female_LE_data_text), Y_position = c(1.2,-1.2, .4, -.4, .8, -1), X_position = c(0, 0, 20, 20, 80, 80))

LE_arc <- ggplot(LE_data) +
  geom_curve(data = subset(LE_data, Sex == 'Male'),
             aes(x = 0, 
                 y = 0.1, 
                 xend = Value, 
                 yend = 0.1, 
                 colour = Sex),
             curvature = -.5,
             show.legend = FALSE) +
  geom_curve(data = subset(LE_data, Sex == 'Female'),
             aes(x = 0, 
                 y = -0.1, 
                 xend = Value, 
                 yend = -0.1, 
                 colour = Sex),
             curvature = .5,
             show.legend = FALSE) +
  geom_point(aes(x = Value,
                 y = ifelse(Sex == 'Male', .1, -.1),
                 fill = Area_type_label,
                 size = Area_type_label),
             shape = 21,
             colour = '#ffffff00') + # add 00 as a hack to change transparency
  annotate(geom = 'segment',
           x = 0,
           xend = 100,
           y = 0,
           yend = 0,
           colour = '#f5f4f3') +
  geom_textbox(data = subset(LE_labels, ID %in% c(1,2)),
               aes(x = X_position,
                   y = Y_position,
                   label = Label),
               width = unit(0.3, "npc"),
           hjust = 0,
           size = 5,
           fill = NA,
           box.color = NA) +
  geom_textbox(data = subset(LE_labels, ID %in% c(3, 4)),
               aes(x = X_position,
                   y = Y_position,
                   label = Label),
               width = unit(0.4, "npc"),
               hjust = 0,
               halign = .5,
               size = 4.25,
               fill = NA,
               color = '#444444',
               box.color = NA) +
  geom_textbox(data = subset(LE_labels, ID %in% c(5,6)),
               aes(x = X_position,
                   y = Y_position,
                   label = Label),
               width = unit(0.2, "npc"),
               hjust = 0,
               halign = .5,
               size = 3.6,
               color = '#444444',
               fill = NA,
               box.color = NA) +
  geom_text(data  = data.frame(Age = seq(0,100, 5)),
            aes(x = Age,
                y = 0, 
                label = Age),
            size = 4,
            colour = '#999999') +
  geom_text(data = data.frame(label = 'years'),
                              aes(x =  99,
                                  y = -.15,      
                                  label = label),
            size = 4,
            colour = '#444444') +
  scale_y_continuous(limits = c(-1.5,1.5)) +
  scale_colour_manual(values = c('#94e2ff','#ff9169')) +
  scale_fill_manual(values = c('#c9c9c9', 'purple', '#000000'),
                    name = '') +
  scale_size_manual(values = c(2, 4, 2),
                    name = '') +
    labs(title = 'Life expectancy at birth; five year pooled data (2015-2019); West Sussex neighbourhoods (Middle-layer Super Output Areas); by sex',
       subtitle = 'Data source: Public Health England analysis of ONS death registration data and mid-year population estimates.',
       caption = 'Life expectancy is an estimate of the average number of years a new-born baby would survive if he or she experienced the age-specific mortality rates\nfor that area and time period throughout his or her life.\nEach line represents a neighbourhood area within West Sussex with male life expectancy along the top and female life expectancy at the bottom.\nNote that the time period included in this metric is prior to the COVID-19 pandemic.') +
  arc_theme()

png(paste0(github_repo, '/Outputs/Figure_1_West_Sussex_MSOA_LE_Arc.png'),
    width = 1580,
    height = 950,
    res = 120)
print(LE_arc)
dev.off()

# For d3 plotting ####
links <- LE_data %>% 
  mutate(target = Value,
         source = 0) %>% 
  select(source, target, names(LE_data)) %>% 
  filter(!is.na(Value)) %>% 
  filter(Sex == 'Male')

# Transform it in a graph format
network <- graph_from_data_frame(d=links, directed=F)

# Transform it in a JSON format for d3.js
data_json <- d3_igraph(network)

# Save this file
data_json %>%  
  write_lines(paste0(github_repo,'/Outputs/male_le_arc_data.json'))

links <- LE_data %>% 
  mutate(target = Value,
         source = 0) %>% 
  select(source, target, names(LE_data)) %>% 
  filter(!is.na(Value)) %>% 
  filter(Sex == 'Female')

# Transform it in a graph format
network <- graph_from_data_frame(d=links, directed=F)

# Transform it in a JSON format for d3.js
data_json <- d3_igraph(network)

# Save this file
data_json %>%  
  write_lines(paste0(github_repo,'/Outputs/female_le_arc_data.json'))

LE_data %>% 
  ggplot(aes(x = Pop_weighted_imd_score,
             y = Value,
             color = Sex)) +
  geom_point()
