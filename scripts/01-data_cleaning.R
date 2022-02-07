#### Preamble ####
# Purpose: Clean the survey data downloaded from Open Data Toronto
# Author: Zihan Jin
# Data: 5 Feb 2021
# Contact: zihan.jin@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have downloaded the ACS data and saved it to inputs/data



#### Workspace setup ####
# Use R Projects, not setwd().
library(opendatatoronto)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(patchwork)
library(scales)
library(knitr)
library(janitor)
library(tidyr)

# Read in the raw data. 
package <- show_package("64b54586-6180-4485-83eb-81e8fae3b8fe")
resources <- list_package_resources("64b54586-6180-4485-83eb-81e8fae3b8fe")
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))
covid <- filter(datastore_resources, row_number()==1) %>% get_resource()

# data cleaning

# copy a new datatset for cleaning data
covid_clean <- covid

# rename the columns

names(covid_clean)[1] <- "id"
names(covid_clean)[3] <- "Outbreak_Associated"
names(covid_clean)[4] <- "Age_Group"
names(covid_clean)[5] <- "Neighbourhood_Name"
names(covid_clean)[7] <- "Source_of_Infection"
names(covid_clean)[9] <- "Episode_Date"
names(covid_clean)[10] <- "Reported_Date"
names(covid_clean)[11] <- "Client_Gender"
names(covid_clean)[13] <- "Currently_Hospitalized"
names(covid_clean)[14] <- "Currently_in_ICU"
names(covid_clean)[15] <- "Currently_Intubated"
names(covid_clean)[16] <- "Ever_Hospitalized"
names(covid_clean)[17] <- "Ever_in_ICU"
names(covid_clean)[18] <- "Ever_Intubated"

# remove meaningless columns
covid_clean <- covid_clean %>%
  select(- id) %>%
  select(- Assigned_ID)

# drop missing value
covid_clean <- covid_clean %>% 
  filter(!is.na(Age_Group)) %>%
  filter(!is.na(Outcome)) %>%
  filter(!is.na(Source_of_Infection)) %>%
  filter(!is.na(Client_Gender))

# create new column to calculate the effectiveness of covid-19 information gain
covid_clean$Time_Lag<- difftime(covid_clean$Reported_Date ,covid_clean$Episode_Date , units = c("days"))

covid_clean$time_lag <- as.numeric(covid_clean$Time_Lag)


# drop unreliable data
covid_clean <- covid_clean %>%
  filter(Time_Lag > 0 | Time_Lag == 0)



         