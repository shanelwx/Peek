# Clear environment
rm(list=ls())

print(paste0(Sys.time()," / Begin Hydro Services / "))

### Load Packages
library(readxl)
library(janitor)
library(lubridate)
library(tidyverse)
library(RODBC)
library(dplyr)
library(tictoc)

tic()

# ### Connecting to csv
cn_DCS <- read.csv("C:/Users/user/Desktop/Work/upload_Tbl_DCS_Raw.csv") # C:\Shane Excel Export HydroServices (location in SVC)
cn_SCADA <- read.csv("C:/Users/user/Desktop/Work/upload_Tbl_SCADA_Raw.csv") # C:\Shane Excel Export HydroServices (location in SVC)

# Seperate connection into dataframes
df_DCS <- cn_DCS
df_SCADA <- cn_SCADA

# Add Source to connected dataframes
df_DCS$Source <- "DCS" 
df_SCADA$Source <- "SCADA"

# Make same col names and rearrange
# names(df_DCS)[5] <- "Flow"
# names(df_SCADA)[5] <- "Flow"
names(df_DCS)[names(df_DCS) == "Mean"] <- "Flow"
names(df_SCADA)[names(df_SCADA) == "Mean"] <- "Flow"
df_DCS <- subset(df_DCS, select = c(DATE, Tag, Flow, Description, Wellhouse, Source, UNIT, resolution_s))
df_SCADA <- subset(df_SCADA, select = c(DATE, Tag, Flow, Description, Wellhouse, Source, UNIT, resolution_s))

# Seperate flows from pressure
df_DCS_pressure <- filter(df_DCS, UNIT == 'kPa')
df_DCS_flow <- filter(df_DCS, UNIT == 'L/s')
df_SCADA_pressure <- filter(df_SCADA, UNIT == 'kPa')
df_SCADA_flow <- filter(df_SCADA, UNIT == 'L/s')

# Bind data together
v_Flow_Master <- rbind(df_DCS_flow, df_SCADA_flow)
v_Pressure_Master <- rbind(df_DCS_pressure, df_SCADA_pressure)

## v_FlowPressure_Master


df_flowpressuremaster <- left_join(v_Flow_Master, v_Pressure_Master,
                                   by = c("DATE",
                                          "Description",
                                          "Wellhouse",
                                          "Source"))

df_flowpressuremaster <- subset(df_flowpressuremaster, select = c(DATE,
                                                                  Tag.x,
                                                                  Tag.y,
                                                                  Wellhouse,
                                                                  Description,
                                                                  Flow.x,
                                                                  Flow.y,
                                                                  Source))

names(df_flowpressuremaster)[1:8] <- c("DATE",
                                       "tag_flow",
                                       "tag_pressure",
                                       "Wellhouse",
                                       "Description",
                                       "flowrate_ls",
                                       "pressure_kpa",
                                       "historian") 

df_flowpressuremaster[is.na(df_flowpressuremaster)] <- ""

write.csv(df_flowpressuremaster,"//adlfs/Hydrology/DEPOSITS/FMW/PRODUCTION_ANALYSIS/Hydroservices Script Output/v_FlowPressure_Master.csv",
          row.names =  FALSE)

print("ALL DONE!")
toc()
