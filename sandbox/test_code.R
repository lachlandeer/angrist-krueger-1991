
library(sandwich)
library(AER)
library(readr)
library(ggplot2)
library(stargazer)
library(magrittr)
library(dplyr)
library(lfe)


# Download data and unzip the data
download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
unzip('asciiqob.zip')

# read in data
col_names <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

df <- read_table("asciiqob.txt",
                col_names = col_names)

# data - manipulation

# better var names

df %<>%
    rename(
        log_wage = lwklywge,
        education = educ,
        year_born = yob,
        quarter_born = qob,
        state_born = pob
    )


df <- df %>%
        mutate(born_q1 = if_else(quarter_born ==1, TRUE, FALSE),
               born_first_half = if_else(quarter_born ==1 | quarter_born ==2, TRUE, FALSE),
                age_quarters = (80 - year_born)*4 + quarter_born - 1
               )

# plots
ggplot(df, aes(x = education, y = log_wage)) +
    geom_point(alpha = 0.2) +
    geom_smooth(method='lm') +
    theme_bw()

ggplot(df, aes(x = education)) +
    geom_histogram() +
    theme_bw()

ggplot(df, aes(x = log_wage)) +
    geom_histogram() +
    theme_bw()

# models
# Column 1: OLS
col1 <- felm(log_wage ~ education, data = df)

# Column 2: OLS with YOB, POB dummies
col2 <- felm(log_wage ~ education | year_born + state_born, data = df)

# Column 3: 2SLS with instrument QOB = 1
col3 <- felm(log_wage ~ 1 | 1 | (education ~ born_q1),  data = df) 

# Column 4: 2SLS with instrument QOB = 1 or QOB = 2
col4 <- felm(log_wage ~ 1 | 1 | (education ~ born_first_half),  data = df)

# Column 5: 2SLS with YOB, POB dummies and instrument QOB = 1
col5 <- felm(log_wage ~ 1 | year_born + state_born | (education ~ born_q1),  data = df) 

# Column 6: 2SLS with YOB, POB dummies and full QOB dummies
col6 <- felm(log_wage ~ 1 | year_born + state_born | (education ~ factor(quarter_born)),  data = df) 

# Column 7: 2SLS with YOB, POB dummies and full QOB dummies interacted with YOB
col7 <- felm(log_wage ~ 1 | year_born + state_born | 
                 (education ~ factor(quarter_born) * factor(year_born)), 
                data = df) 

# Column 8: 2SLS with age, YOB, POB dummies and with full QOB dummies interacted with YOB
col8 <- felm(log_wage ~ age_quarters + I(age_quarters^2) | year_born + state_born | 
                 (education ~ factor(quarter_born) * factor(year_born)), 
             data = df) 
     
stargazer(col1, col2, col3, col4, col8,
          type = "text",
          keep = "education",
          covariate.labels = c('Years of education', 'Years of education'))

summary(col8)
