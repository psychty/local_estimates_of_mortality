<!-- @format -->

# Local variation in estimates of mortality

This will be a short report explainer of Middle Super Output Area data and estimates of Life Expectancy and Mortality.

It will compliment the GBD estimates that model ill health and mortality at upper tier local authority level.

# Data

The data used in this report come from the https://www.localhealth.org.uk/ data store from Public Health England.

The data is reproduced under Open Government Licence.

# Site

The report will be available first as an interactive webpage.
sussex-local-mortality.netlify.app
You can access the website here: https://sussex-local-mortality.netlify.app/
[![Netlify Status](https://api.netlify.com/api/v1/badges/865134a2-80da-4571-9c7f-0d63d6332336/deploy-status)](https://app.netlify.com/sites/sussex-local-mortality/deploys)

# Arc visualisation

I came across a tweet with the hashtag #30daychartchallenge by [@pablo_alvrezin](https://twitter.com/pablo_alvrez/status/1511603048761671681) in which Life Expectancy is plotted for each area and sex on a single axis as curves. I think this really works as a visualisation showing a starting point of zero years and how long on average people might expect to live. It clearly shows females living longer (using highlights to identify one area on both male and female plots) as well as the variation within each sex (ranging from low 50s to mid 80s for males and mid 50s to late 80s for females).

This inspired me to try this out in R using just ggplot. I struggled with moving the x axis, and using facets like I have done with population pyramids, but in the end I redrew an axis in the middle and manually moved the points.

The R script for extracting LE data for West Sussex MSOAs and creating the plot is here: [life_expectancy_curves.R](https://github.com/psychty/local_estimates_of_mortality/blob/main/life_expectancy_curves.R).
