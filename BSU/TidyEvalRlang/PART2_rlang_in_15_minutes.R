# LEARNING LAB 12 ----
# RLANG IN 10 MINUTES

# 1.0 Libraries ----
library(tidyverse)
# library(rlang) # loaded with tidyverse

# 2 common design patterns

# 1. Vector functions
# 2. Data functions

# Scale these with purrr


set.seed(123)
time_series_tbl <- tibble(
    date  = seq.Date(from = ymd("2019-01-01"), by = "d", length.out = 100),
    value = rnorm(100, mean = 5, sd = 2) + 
        c(rep(0, 79), c(5, 20, 25, 24, 22, 18, 10, 7, 6, 4, 1), rep (0, 10))
)

time_series_tbl %>% ggplot(aes(date, value)) + geom_line()

# 2.0 The 2 Types of Functions ----

# 2.1 Vector Functions ----

mean(time_series_tbl$value)

log(time_series_tbl$value)

outlier <- function(x, alpha = 0.05) {
    
    quantile_x <- quantile(x, prob = c(0.25, 0.75), na.rm = TRUE)
    iq_range   <- quantile_x[[2]] - quantile_x[[1]]
    limits     <- quantile_x + (0.15 / alpha) * iq_range * c(-1, 1)
    
    outlier_idx      <- ((x < limits[1]) | (x > limits[2]))
    outlier_vals     <- x[outlier_idx]
    outlier_response <- ifelse(outlier_idx == TRUE, "Yes", "No")
    
    return(outlier_response)
}

outlier(x = time_series_tbl$value, alpha = 0.05)

# 2.2 Data Functions ----

time_series_tbl %>% summarize(average = mean(value))

time_series_tbl %>% mutate(value_log = log(value))

time_series_tbl %>% mutate(outlier = outlier(value))



# 3.0 RLANG ----

# 3.1 PROBLEM ----

detect_outlier <- function(data, column, alpha = 0.05) {
    data %>% mutate(outlier = outlier(column, alpha = alpha))
    }

time_series_tbl %>% detect_outlier(column = value)
# R does not know what `value` is.
    

# 3.2 enquo(): Freezes column names before they cause errors ----

detect_outlier <- function(data, column, alpha = 0.05) {
    
    column_expr <- enquo(column)
    data %>% mutate(outlier = outlier(!! column_expr, alpha = alpha))
}

time_series_tbl %>% detect_outlier(value)


time_series_tbl %>% detect_outlier(value, alpha = 0.05) %>%
    
    ggplot(aes(date, value)) +
    geom_line(color = "#2c3e50", alpha = 0.5) +
    geom_point(aes(color = outlier), size = 3, alpha = 0.75) +
    scale_color_tq() +
    theme_tq()


websites_sample_tbl %>% group_by(Page) %>% detect_outlier(visits)
