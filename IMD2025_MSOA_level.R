
# Higher geography IMD

packages <- c('tidyverse', 'scales','showtext', 'strex',  "viridis", "PHEindicatormethods", "lemon", 'ggmap', 'sf', 'sfnetworks', 'tidygraph','leaflet', 'leaflet.extras', 'PostcodesioR', 'htmlwidgets', 'rmapshaper', 'purrr', 'osrm', 'ukpolice', 'readxl')

install.packages(setdiff(packages, rownames(installed.packages())))
easypackages::libraries(packages)

# directories
geography_directory <- './Public Health and Social Research Unit - Tools/Geographies/'
font_pathway <- './Public Health and Social Research Unit - Tools/Fonts/'
data_directory <- './Hospital Activity/HES - CONFIDENTIAL/HDIS/Alcohol/'
premises_data_directory <- './Alcohol/Licensing/Alcohol and the environment/'
output_directory <- './Alcohol/Licensing/Alcohol and the environment/ready_reckoner/'

# Fonts  #####
font_paths(font_pathway)

font_add(family = "aptos", "aptos.ttf")
font_add(family = "aptosb", "aptos-bold.ttf")

showtext_auto(TRUE)

# Set font size
font_size <- 18

# theme for maps which are drawn in ggplot
map_theme = function(){
  theme( 
    plot.title.position = "plot",
    plot.title = element_text(colour = "#000000", family = 'aptosb', size = font_size, lineheight = .5), 
    plot.subtitle = element_text(colour = "#000000", family = 'aptos', size = font_size, lineheight = .5),
    plot.caption = element_text(colour = "#000000", family = 'aptos', size = font_size, lineheight = .5),
    panel.background = element_blank(),  
    panel.border = element_blank(),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    strip.text = element_text(colour = "white"), 
    strip.background = element_rect(fill = "#ffffff"), 
    axis.title = element_blank(),    
    axis.ticks = element_blank(),
    axis.text = element_blank(), 
    legend.title = element_text(size = font_size - 2, family = 'aptosb'),
    legend.text = element_text(size = font_size - 2, family = 'aptos'),
    legend.margin = margin(t = 0),
    legend.key.size = unit(.35, 'cm'),
    legend.spacing.y = unit(.5, 'mm'),
    legend.position = "bottom", 
    text = element_text(size = font_size - 2, family = 'aptos')) 
} 

# adding ph_theme for ggplot
ph_theme = function(){
  theme(
    plot.title.position = "plot",
    plot.title = element_text(colour = "#000000", size = font_size, family = 'aptosb', lineheight = .5),
    plot.subtitle = element_text(colour = "#000000", size = font_size, family = 'aptos', lineheight = .5),
    plot.caption = element_text(colour = "#000000", size = font_size, family = 'aptos', lineheight = .5),
    panel.background = element_rect(fill = '#ffffff'),
    panel.grid.major.y = element_line(colour = "#E7E7E7", size = .3),
    panel.grid.major.x = element_blank(),
    plot.margin = margin(t = 5.5, r = 20, b = 5.5, l = 5.5),
    strip.text = element_text(colour = "#000000", size = font_size),
    strip.background = element_blank(),
    legend.title = element_text(colour = "#000000", size = font_size, family = "aptosb", lineheight = .5),
    legend.background = element_rect(fill = "#ffffff"),
    legend.key = element_rect(fill = "#ffffff", colour = "#ffffff"),
    legend.key.size = unit(.8, "line"),
    legend.text = element_text(colour = "#000000", size = font_size, lineheight = .25),
    legend.position = 'top',
    legend.box = "vertical",
    legend.margin = margin(t = 0),
    legend.spacing.y = unit(.5, 'mm'),
    axis.text.x = element_text(size = font_size -2, angle = 90, hjust = .5, vjust = 0, colour = '#000000'),
    axis.text.y = element_text(size = font_size -2, colour = '#000000'),
    axis.ticks = element_line(colour = "#dbdbdb", linewidth = .1),
    axis.title =  element_text(colour = "#000000", size = font_size -2, family = 'aptosb', lineheight = .5),
    axis.line = element_line(colour = "#dbdbdb", , linewidth = .1),
    text = element_text(family = 'aptos', colour = '#000000', size = 16, lineheight = 0.5)
  )}



IMD_df <- read_csv(url('https://assets.publishing.service.gov.uk/media/68ff5daabcb10f6bf9bef911/File_7_IoD2025_All_Ranks_Scores_Deciles_Population_Denominators.csv')) %>% 
  select(LSOA21CD = `LSOA code (2021)`, LSOA21NM = `LSOA name (2021)`, IMD_Score = 'Index of Multiple Deprivation (IMD) Score', IMD_Rank = 'Index of Multiple Deprivation (IMD) Rank (where 1 is most deprived)', IMD_Decile = "Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOAs)", Overall_denominator = 'Total population: mid 2022') %>% 
  left_join(st_read('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/OA21_LAD23_LSOA21_MSOA21_LEP23_EN_LU/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson') %>% 
              st_drop_geometry() %>% 
              select(LSOA21CD, MSOA21CD, MSOA21NM) %>% 
              unique(),
            by = 'LSOA21CD') %>% 
  mutate(IMD_Decile = case_when(IMD_Decile == 1 ~ 'Decile 1 (most deprived 10%)',
                                IMD_Decile == 10 ~ 'Decile 10 (least deprived 10%)',
                                TRUE ~ paste0('Decile ', IMD_Decile))) %>%
  mutate(IMD_Quintile = case_when(IMD_Decile %in% c('Decile 1 (most deprived 10%)', 'Decile 2') ~ 'Quintile 1 (most deprived 20%)', # if value in IMD_Decile is 1 or 2, assign to "Quintile 1" etc
                                  IMD_Decile %in% c('Decile 3', 'Decile 4') ~ 'Quintile 2', # %in% checks if value is present in a vector/list of values
                                  IMD_Decile %in% c('Decile 5', 'Decile 6') ~ 'Quintile 3', #ifelse might be used here
                                  IMD_Decile %in% c('Decile 7', 'Decile 8') ~ 'Quintile 4',
                                  IMD_Decile %in% c('Decile 9', 'Decile 10 (least deprived 10%)') ~ 'Quintile 5 (least deprived 20%)'))


Pop_in_neighbourhood <- IMD_df %>% 
  group_by(MSOA21CD, MSOA21NM, IMD_Quintile) %>% 
  summarise(Neighbourhoods = n(),
            Population = sum(Overall_denominator)) %>% 
  group_by(MSOA21CD, MSOA21NM) %>% 
  mutate(Proportion = Population / sum(Population)) %>% 
  filter(IMD_Quintile == 'Quintile 1 (most deprived 20%)')


IMD_weighted <- IMD_df %>% 
  mutate(Weighted_score = IMD_Score * Overall_denominator) %>% 
  group_by(MSOA21CD, MSOA21NM) %>% 
  summarise(Total_score = sum(Weighted_score),
            Overall_denominator = sum(Overall_denominator)) %>% 
  mutate(Average_score = Total_score / Overall_denominator) %>%  
  ungroup() %>% 
  mutate(Average_score_rank = rank(desc(Average_score))) %>% 
  mutate(Average_score_decile = ntile(desc(Average_score), 10)) %>% 
  mutate(Average_score_decile = case_when(Average_score_decile == 1 ~ 'Decile 1 (most deprived 10%)',
                                          Average_score_decile == 10 ~ 'Decile 10 (least deprived 10%)',
                                TRUE ~ paste0('Decile ', Average_score_decile))) %>% 
  mutate(Average_score_quintile = case_when(Average_score_decile %in% c('Decile 1 (most deprived 10%)', 'Decile 2') ~ 'Quintile 1 (most deprived 20%)', # if value in Average_score_decile is 1 or 2, assign to "Quintile 1" etc
                                  Average_score_decile %in% c('Decile 3', 'Decile 4') ~ 'Quintile 2', # %in% checks if value is present in a vector/list of values
                                  Average_score_decile %in% c('Decile 5', 'Decile 6') ~ 'Quintile 3', #ifelse might be used here
                                  Average_score_decile %in% c('Decile 7', 'Decile 8') ~ 'Quintile 4',
                                  Average_score_decile %in% c('Decile 9', 'Decile 10 (least deprived 10%)') ~ 'Quintile 5 (least deprived 20%)')) %>% 
  left_join(Pop_in_neighbourhood, by = c('MSOA21CD', 'MSOA21NM')) %>%
  left_join(read_csv('https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest2.csv')[c('msoa21cd', 'msoa21hclnm')], by = c('MSOA21CD' = 'msoa21cd')) %>% 
  select(MSOA21CD, MSOA21NM, MSOA21HCL_NAME = msoa21hclnm, Average_score, Average_score_rank, Average_score_decile, Average_score_quintile, Q1_neighbourhoods = Neighbourhoods, Q1_population = Population, Q1_proportion = Proportion) %>% 
  mutate(
    Q1_neighbourhoods = replace_na(Q1_neighbourhoods, 0),
    Q1_population = replace_na(Q1_population, 0),
    Q1_proportion = replace_na(Q1_proportion, 0)
         ) %>% 
  filter(str_detect(MSOA21NM, 'Adur|Arun|Chichester|Crawley|Horsham|Mid Sussex|Worthing'))

IMD_weighted %>% 
  write_csv(., paste0(output_directory, 'IMD2025_pop_weighted_MSOA_scores.csv'))

# Perhaps we also want proportion of area population in most deprived quintile.


# %>%
#   mutate(IMD_Decile = case_when(IMD_Decile == 1 ~ 'Decile 1 (most deprived 10%)',
#                                 IMD_Decile == 10 ~ 'Decile 10 (least deprived 10%)',
#                                 TRUE ~ paste0('Decile ', IMD_Decile))) %>%
#   mutate(IMD_Quintile = case_when(IMD_Decile %in% c('Decile 1 (most deprived 10%)', 'Decile 2') ~ 'Quintile 1\n(most deprived 20%)', # if value in IMD_Decile is 1 or 2, assign to "Quintile 1" etc
#                                   IMD_Decile %in% c('Decile 3', 'Decile 4') ~ 'Quintile 2', # %in% checks if value is present in a vector/list of values
#                                   IMD_Decile %in% c('Decile 5', 'Decile 6') ~ 'Quintile 3', #ifelse might be used here
#                                   IMD_Decile %in% c('Decile 7', 'Decile 8') ~ 'Quintile 4',
#                                   IMD_Decile %in% c('Decile 9', 'Decile 10 (least deprived 10%)') ~ 'Quintile 5\n(least deprived 20%)'))

# As IMD25 is LSOA based, we need to aggregate up to MSOA level using a summary methodology.

# MHCLG recommend using a population weighted sum of scores and ranking the average score at the higher geography. MHCLG supply population denominators as part of the release, which is a sensible snapshot to use.

# To create 
