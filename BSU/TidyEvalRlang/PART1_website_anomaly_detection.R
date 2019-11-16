# LEARNING LAB 12 ----
# R PROGRAMMING & RLANG

# 1.0 LIBRARIES ----
library(vroom)
library(tidyverse)
library(tidyquant)
library(lubridate)
library(rsample)
library(anomalize)

setwd("~/GitHub/R_Programming/BSU/TidyEvalRlang")

# Review Week 2 of 201-R course where rlang is reviewed

# 2.0 BUSINESS PROBLEM ----
# Detect spikes in timeseries.  Assess what was driving the spikes.  Challenge was there were 100,000 timeseires.  
# Required a highly scalled function

# Twitter's AnomalyDectection packge is not very scalable.  Written for 1 time series at a time.  Not written for tidyverse.
# AnomalyDetection also not built for long term trends like growth

# Matt wrote anomalize to overcome the limitations

# 3 Steps to use anomalize

# 1. Detrend and remove seasonality  - removed because it it not unusual. Only want the remainder.
# 2. Use interquartile range of the remainder. Resulting reaminder_l1 and remainder_l2 are the bands that go around the remainder.
# 3. time_recompose puts bands around the original observed values


websites_raw_tbl <- vroom::vroom("../../../LargeDataFiles/train_1_TidyRlang.csv", delim = ",")

websites_raw_tbl <- websites_raw_tbl %>% rowid_to_column(var = "id")

set.seed(123)
websites_sample_tbl <- websites_raw_tbl %>% sample_n(size = 9) %>%
    gather(key = "date", value = "visits", -id, -Page) %>%
    replace_na(replace = list(visits = 0)) %>% mutate(date = ymd(date))

websites_sample_tbl %>% ggplot(aes(date, visits, color = Page)) + geom_point(alpha = 0.5) +
    facet_wrap(~ Page, scales = "free_y") + theme_tq() + scale_color_viridis_d() + theme(legend.position = "none") +
    expand_limits(y = 0)

# 3.0 ANOMALY DETECTION -----

websites_sample_tbl %>% filter(Page %>% str_detect("Kit_Harington")) %>%
    
    time_decompose(target = visits, method = "stl") %>% #Step 1
    anomalize(target = remainder, method = "iqr", alpha = 0.3) %>% # Step 2
    time_recompose() %>% # Step 3
    
    plot_anomalies(time_recomposed = TRUE) 

websites_sample_tbl %>% group_by(Page) %>%
    
    time_decompose(target = visits, method = "stl") %>%
    anomalize(target = remainder, method = "iqr", alpha = 0.05) %>%
    time_recompose() %>%
    plot_anomalies(ncol = 3, time_recomposed = TRUE)



