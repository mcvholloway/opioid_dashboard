library(shinydashboard)
library(tidyverse)
library(tools)
library(plotly)
library(DT)

drugs_by_state <- readRDS('data/drugs_by_state.RDS')
drugs_by_specialty <- readRDS('data/drugs_by_specialty.RDS')

drugs <- toTitleCase(tolower(sort((drugs_by_state %>% select(Drug) %>% unique())$Drug)))