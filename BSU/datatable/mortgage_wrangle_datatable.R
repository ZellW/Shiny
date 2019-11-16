# LEARNING LAB 13 -----
# WRANGLING LARGE DATA WITH DATA.TABLE
# WORKSHOP: NVIDIA GTC 2019 - GPU Accelerated Forecasting of Mortgage Default Risk
# CREDITS: 
#  - STEVEN THORNTON OF RNFC FOR NVIDIA GTC CODE. USED DATA.TABLE FOR PREPROCESSING.
#  - FANNIE MAE DATA SET & R CODE: http://www.fanniemae.com/portal/funding-the-market/data/loan-performance-data.html

# Also consider dtplyr https://github.com/tidyverse/dtplyr
# - Each dplyr verb must do some work to convert dplyr syntax to data.table syntax. This takes time proportional to the complexity of the input code, 
#   - not the input data, so should be a negligible overhead for large datasets. Initial benchmarks suggest that the overhead should be under 1ms 
#   - per dplyr call.
# - Some data.table expressions have no direct dplyr equivalent. For example, there’s no way to express cross- or rolling-joins with dplyr.
# - To match dplyr semantics, mutate() does not modify in place by default. This means that most expressions involving mutate() must make 
#   - a copy that would not be necessary if you were using data.table directly. (You can opt out of this behaviour in lazy_dt() with immutable = FALSE).

# dplyr:  <10M rows
# data.table:  < 50M rows.  Uses := to overwrite data rather than make copies like dplyr
# Spark:  > 100M records

# 1.0 LIBRARIES -----

# Tidyverse
library(tidyverse)
library(vroom)

# Data Table
library(data.table)

# # Rolling Mean
# library(zoo) #usually used for rolling means

# Counter
library(tictoc)

# Visualization
library(plotly)

setwd("~/GitHub/R_Programming/BSU/datatable")

# 2.0 DATA IMPORT ----


# 2.1 Loan Acquisitions Data ----
col_types_acq <- list(
    loan_id                            = col_factor(),
    original_channel                   = col_factor(NULL),
    seller_name                        = col_factor(NULL),
    original_interest_rate             = col_double(),
    original_upb                       = col_integer(),
    original_loan_term                 = col_integer(),
    original_date                      = col_date("%m/%Y"),
    first_pay_date                     = col_date("%m/%Y"),
    original_ltv                       = col_double(),
    original_cltv                      = col_double(),
    number_of_borrowers                = col_double(),
    original_dti                       = col_double(),
    original_borrower_credit_score     = col_double(),
    first_time_home_buyer              = col_factor(NULL),
    loan_purpose                       = col_factor(NULL),
    property_type                      = col_factor(NULL),
    number_of_units                    = col_integer(),
    occupancy_status                   = col_factor(NULL),
    property_state                     = col_factor(NULL),
    zip                                = col_integer(),
    primary_mortgage_insurance_percent = col_double(),
    product_type                       = col_factor(NULL),
    original_coborrower_credit_score   = col_double(),
    mortgage_insurance_type            = col_double(),
    relocation_mortgage_indicator      = col_factor(NULL))

acquisition_data <- vroom(
      file       = "../../../LargeDataFiles/datatable/Acquisition_2018Q1.txt", 
      delim      = "|", 
      col_names  = names(col_types_acq),
      col_types  = col_types_acq,
      na         = c("", "NA", "NULL"))

acquisition_data %>% glimpse()


# 2.2 Performance Data ----

col_types_perf = list(
    loan_id                                = col_factor(),
    monthly_reporting_period               = col_date("%m/%d/%Y"),
    servicer_name                          = col_factor(NULL),
    current_interest_rate                  = col_double(),
    current_upb                            = col_double(),
    loan_age                               = col_double(),
    remaining_months_to_legal_maturity     = col_double(),
    adj_remaining_months_to_maturity       = col_double(),
    maturity_date                          = col_date("%m/%Y"),
    msa                                    = col_double(),
    current_loan_delinquency_status        = col_double(),
    modification_flag                      = col_factor(NULL),
    zero_balance_code                      = col_factor(NULL),
    zero_balance_effective_date            = col_date("%m/%Y"),
    last_paid_installment_date             = col_date("%m/%d/%Y"),
    foreclosed_after                       = col_date("%m/%d/%Y"),
    disposition_date                       = col_date("%m/%d/%Y"),
    foreclosure_costs                      = col_double(),
    prop_preservation_and_repair_costs     = col_double(),
    asset_recovery_costs                   = col_double(),
    misc_holding_expenses                  = col_double(),
    holding_taxes                          = col_double(),
    net_sale_proceeds                      = col_double(),
    credit_enhancement_proceeds            = col_double(),
    repurchase_make_whole_proceeds         = col_double(),
    other_foreclosure_proceeds             = col_double(),
    non_interest_bearing_upb               = col_double(),
    principal_forgiveness_upb              = col_double(),
    repurchase_make_whole_proceeds_flag    = col_factor(NULL),
    foreclosure_principal_write_off_amount = col_double(),
    servicing_activity_indicator           = col_factor(NULL))


performance_data <- vroom(
    file       = "../../../LargeDataFiles/datatable/Performance_2018Q1.txt", 
    delim      = "|", 
    col_names  = names(col_types_perf),
    col_types  = col_types_perf,
    na         = c("", "NA", "NULL"))

performance_data %>% glimpse()

# 3.0 CONVERT TO DATA.TABLE ----

# 3.1 Acquisition Data ----
class(acquisition_data)

setDT(acquisition_data)

class(acquisition_data)

acquisition_data

acquisition_data %>% glimpse()

# 3.2 Performance Data ----
setDT(performance_data)

performance_data

performance_data %>% glimpse()


# 4.0 DATA WRANGLING ----

# 4.1 Joining / Merging Data ----

tic()
combined_data <- merge(x = acquisition_data, y = performance_data, 
                       by    = "loan_id", 
                       all.x = TRUE, 
                       all.y = FALSE)
toc() #~13 sec

combined_data %>% glimpse()

tic()
performance_data %>% left_join(acquisition_data, by = "loan_id")
toc() #~10 sec

# Preparing the Data Table
?setkey
setkey(combined_data, "loan_id")
key(combined_data)

?setorder()
setorderv(combined_data, c("loan_id", "monthly_reporting_period"))


# 4.1 Select Columns ----
combined_data %>% dim()

keep_cols <- c("loan_id",
               "monthly_reporting_period",
               "seller_name",
               "current_interest_rate",
               "current_upb",
               "loan_age",
               "remaining_months_to_legal_maturity",
               "adj_remaining_months_to_maturity",
               "current_loan_delinquency_status",
               "modification_flag",
               "zero_balance_code",
               "foreclosure_costs",
               "prop_preservation_and_repair_costs",
               "asset_recovery_costs",
               "misc_holding_expenses",
               "holding_taxes",
               "net_sale_proceeds",
               "credit_enhancement_proceeds",
               "repurchase_make_whole_proceeds",
               "other_foreclosure_proceeds",
               "non_interest_bearing_upb",
               "principal_forgiveness_upb",
               "repurchase_make_whole_proceeds_flag",
               "foreclosure_principal_write_off_amount",
               "servicing_activity_indicator",
               "original_channel",
               "original_interest_rate",
               "original_upb",
               "original_loan_term",
               "original_ltv",
               "original_cltv",
               "number_of_borrowers",
               "original_dti",
               "original_borrower_credit_score",
               "first_time_home_buyer",
               "loan_purpose",
               "property_type",
               "number_of_units",
               "property_state",
               "occupancy_status",
               "primary_mortgage_insurance_percent",
               "product_type",
               "original_coborrower_credit_score",
               "mortgage_insurance_type",
               "relocation_mortgage_indicator")

combined_data <- combined_data[, ..keep_cols]

combined_data %>% dim()

combined_data %>% glimpse()

# 4.2 Arranging / Reording Columns ----
# - Sort by Loan ID and monthly Reporting Period

# Taken care of with setorderv()
combined_data <- combined_data[order(loan_id, monthly_reporting_period), ]
combined_data %>% glimpse()

# 4.3 Grouped Mutations ----
# - Add response variable (Predict wether load will become delinquent in next 3 months)
# - Use modify in place := to speed up calc's

combined_data$current_loan_delinquency_status %>% unique()

# dplyr
tic()
temp <- combined_data %>%
  group_by(loan_id) %>%
  mutate(gt_1mo_behind_in_3mo_dplyr = lead(current_loan_delinquency_status, n = 3) >= 1) %>%
  ungroup()  
toc()

combined_data %>% dim()
temp %>% dim()

# data.table
tic()
combined_data[, gt_1mo_behind_in_3mo := lead(current_loan_delinquency_status, n = 3) >= 1,
              by = loan_id]
toc()

combined_data %>% dim()

rm(temp)




# 5.0 ANALYSIS ----

combined_data %>% glimpse()

# 5.1 How many loans in a month ----
tic()
combined_data[!is.na(monthly_reporting_period), .N, by = monthly_reporting_period]
toc()

tic()
combined_data %>%
    filter(!is.na(monthly_reporting_period)) %>%
    count(monthly_reporting_period) 
toc()

g <- combined_data[!is.na(monthly_reporting_period), .N, by = monthly_reporting_period] %>%
    ggplot(aes(monthly_reporting_period, N)) +
    geom_point() +
    expand_limits(y = 0)

ggplotly(g)

# 5.2 Which loans have the most outstanding delinquencies ----
tic()
combined_data[current_loan_delinquency_status >= 1, 
              list(loan_id, monthly_reporting_period, current_loan_delinquency_status, seller_name, current_upb)][
                , max(current_loan_delinquency_status), by = loan_id][
                  order(V1, decreasing = TRUE)]
toc()

tic()
combined_data %>%
  group_by(loan_id) %>%
  summarize(total_delinq = max(current_loan_delinquency_status)) %>%
  ungroup() %>%
  arrange(desc(total_delinq))
toc()

# 5.3 Get last unpaid balance value for delinquent loans (?"special-symbols") ----
tic()
combined_data[current_loan_delinquency_status >= 1, .SD[.N], by = loan_id][
  !is.na(current_upb)][
  order(-current_upb), .(loan_id, monthly_reporting_period, current_loan_delinquency_status, seller_name, current_upb)  
  ]
toc()

tic()
combined_data %>%
  filter(current_loan_delinquency_status >= 1) %>%
  filter(!is.na(current_upb)) %>%
  
  group_by(loan_id) %>%
  slice(n()) %>%
  ungroup() %>%
  
  arrange(desc(current_upb)) %>%
  select(loan_id, monthly_reporting_period, current_loan_delinquency_status, seller_name, current_upb)
toc()

# 5.4 Loan Companies with highest unpaid balance
tic()
upb_by_company_dt <- combined_data[!is.na(current_upb), .SD[.N], by = loan_id][
  , .(sum_current_upb = sum(current_upb, na.rm = TRUE), cnt_current_upb = .N), by = seller_name][
    order(sum_current_upb, decreasing = TRUE)]
toc()

upb_by_company_dt

tic()
upb_by_company_tbl <- combined_data %>%
  
  filter(!is.na(current_upb)) %>%
  group_by(loan_id) %>%
  slice(n()) %>%
  ungroup() %>%
  
  group_by(seller_name) %>%
  summarise(
    sum_current_upb = sum(current_upb, na.rm = TRUE),
    cnt_current_upb = n()
  ) %>%
  ungroup() %>%
  
  arrange(desc(sum_current_upb))
toc()
temp


# 6.0 FINDINGS ----
# - Both DT & dplyr great for data manipulation
# - DT is faster on grouped mutations (). Speedup of 2X-10X on inplace calculations using := 
# - DT can be slower than dplyr on grouped summarizations