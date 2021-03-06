## Please note that information and data regarding COVID-19 is frequently being updated. 
## The data used in this project was pulled on March 17, 2020, and should not be considered to be the most up to date data available.


# Load the readr, ggplot2, and dplyr packages
library(readr)
library(ggplot2)
library(dplyr)

# Read datasets/confirmed_cases_worldwide.csv into confirmed_cases_worldwide
confirmed_cases_worldwide <- read_csv("datasets/confirmed_cases_worldwide.csv")

# See the result
confirmed_cases_worldwide


## The table above shows the cumulative confirmed cases of COVID-19 worldwide by date. 
## Just reading numbers in a table makes it hard to get a sense of the scale and growth of the outbreak. 
## Let's draw a line plot to visualize the confirmed cases worldwide.

# Draw a line plot of cumulative cases vs. date
# Label the y-axis
confirmed_cases_worldwide %>%
  ggplot(aes(x= date, y= cum_cases)) +
  geom_line() +
  labs(y= "Cumulative confirmed cases")

## The y-axis in that plot is pretty scary, with the total number of confirmed cases around the world approaching 200,000. 
## Beyond that, some weird things are happening: there is an odd jump in mid February, 
## then the rate of new cases slows down for a while, then speeds up again in March. We need to dig deeper to see what is happening.
## Early on in the outbreak, the COVID-19 cases were primarily centered in China. 
## Let's plot confirmed COVID-19 cases in China and the rest of the world separately to see if it gives us any insight.

# Read in datasets/confirmed_cases_china_vs_world.csv
confirmed_cases_china_vs_world <- read_csv("datasets/confirmed_cases_china_vs_world.csv")

# See the result
glimpse(confirmed_cases_china_vs_world)

# Draw a line plot of cumulative cases vs. date, grouped and colored by is_china
# Define aesthetics within the line geom
plt_cum_confirmed_cases_china_vs_world <- ggplot(confirmed_cases_china_vs_world) +
  geom_line(aes(x= date, y= cum_cases, group= is_china, color= is_china)) +
  ylab("Cumulative confirmed cases")

# See the plot
plt_cum_confirmed_cases_china_vs_world


## Wow! The two lines have very different shapes. In February, the majority of cases were in China. 
## That changed in March when it really became a global outbreak: around March 14, the total number of cases outside China overtook the cases inside China. 
## This was days after the WHO declared a pandemic.
## There were a couple of other landmark events that happened during the outbreak. 
## For example, the huge jump in the China line on February 13, 2020 wasn't just a bad day regarding the outbreak; 
## China changed the way it reported figures on that day (CT scans were accepted as evidence for COVID-19, rather than only lab tests).


# three important events
who_events <- tribble(
  ~ date, ~ event,
  "2020-01-30", "Global health\nemergency declared",
  "2020-03-11", "Pandemic\ndeclared",
  "2020-02-13", "China reporting\nchange"
) %>%
  mutate(date = as.Date(date))

# Using who_events, add vertical dashed lines with an xintercept at date
# and text at date, labeled by event, and at 100000 on the y-axis
plt_cum_confirmed_cases_china_vs_world +
  geom_vline(data= who_events, aes(xintercept= date), linetype= "dashed")+
  geom_text(data= who_events, aes(x=date, label=event), y=100000, size= 3)


## When trying to assess how big future problems are going to be, we need a measure of how fast the number of cases is growing. 
## A good starting point is to see if the cases are growing faster or slower than linearly.
## There is a clear surge of cases around February 13, 2020, with the reporting change in China. However, a couple of days after, the growth of cases in China slows down. 
## How can we describe COVID-19's growth in China after February 15, 2020?

# Filter for China, from Feb 15
china_after_feb15 <- confirmed_cases_china_vs_world %>%
  filter(is_china=="China", date >= "2020-02-15")

# Using china_after_feb15, draw a line plot cum_cases vs. date
# Add a smooth trend line using linear regression, no error bars
china_after_feb15 %>%
  ggplot(aes(x= date, y= cum_cases))+
  geom_line()+
  geom_smooth(method= "lm", se= F)+
  ylab("Cumulative confirmed cases")

## From the plot above, the growth rate in China is slower than linear. 
## That's great news because it indicates China has at least somewhat contained the virus in late February and early March.
## How does the rest of the world compare to linear growth?

# Filter confirmed_cases_china_vs_world for not China
confirmed_cases_china_vs_world %>%
 filter(is_china!="China", date>= 2020-02-15) -> not_china

# Using not_china, draw a line plot cum_cases vs. date
# Add a smooth trend line using linear regression, no error bars
plt_not_china_trend_lin <- not_china %>%
  ggplot(aes(x= date, y=cum_cases))+
  geom_line()+
  geom_smooth(method= "lm", se=F)+
  ylab("Cumulative confirmed cases")

# See the result
plt_not_china_trend_lin 


## From the plot above, we can see a straight line does not fit well at all, and the rest of the world is growing much faster than linearly. 
## What if we added a logarithmic scale to the y-axis?

# Modify the plot to use a logarithmic scale on the y-axis
plt_not_china_trend_lin + 
  scale_y_log10()


## With the logarithmic scale, we get a much closer fit to the data. From a data science point of view, a good fit is great news. 
## Unfortunately, from a public health point of view, that means that cases of COVID-19 in the rest of the world are growing at an exponential rate, which is terrible news.
## Not all countries are being affected by COVID-19 equally, and it would be helpful to know where in the world the problems are greatest. 
## Let's find the countries outside of China with the most confirmed cases in our dataset.

# Run this to get the data for each country
confirmed_cases_by_country <- read_csv("datasets/confirmed_cases_by_country.csv")
glimpse(confirmed_cases_by_country)

# Group by country, summarize to calculate total cases, find the top 7
top_countries_by_total_cases <- confirmed_cases_by_country %>%
  group_by(country) %>%
  summarize(total_cases = max(cum_cases)) %>%
  top_n(7, total_cases)

# See the result
arrange(top_countries_by_total_cases,desc(total_cases))


## Even though the outbreak was first identified in China, there is only one country from East Asia (South Korea) in the above table. 
## Four of the listed countries (France, Germany, Italy, and Spain) are in Europe and share borders. To get more context, we can plot these countries' confirmed cases over time.

# Run this to get the data for the top 7 countries
confirmed_cases_top7_outside_china <- read_csv("datasets/confirmed_cases_top7_outside_china.csv")

# 
glimpse(confirmed_cases_top7_outside_china)

# Using confirmed_cases_top7_outside_china, draw a line plot of
# cum_cases vs. date, grouped and colored by country
confirmed_cases_top7_outside_china %>%
ggplot(aes(x= date, y= cum_cases, group= country, color= country))+
geom_line()+
ylab("Cumulative confirmed cases")


