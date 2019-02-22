
library(sandwich)
library(AER)
library(readr)
library(ggplot2)
library(stargazer)
library(magrittr)
library(dplyr)
library(lfe)
library(zoo)


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
                age_quarters = (80 - year_born -1 )*4 + quarter_born
               )

# plots
df2 <- df %>%
        mutate(year_born = year_born + 1900,
               birth_cohort = as.yearqtr(paste(year_born, quarter_born), "%Y %q"))

group_stats <- df2 %>%
        group_by(birth_cohort) %>%
        summarize(
            education = mean(education, na.rm = TRUE),
            log_wage  = mean(log_wage, na.rm = TRUE) 
        )

ggplot(group_stats, aes(x = birth_cohort, y = education)) +
    geom_line(color = "dodger blue") +
    geom_point(color = "blue") + 
    ylim(12.0, 13.3) +
    scale_y_continuous(breaks = round(seq(12.1, 13.3, by = 0.1),1)) +
    scale_x_continuous(breaks = round(seq(1930, 1940, by = 1),1)) +
    theme_bw()

ggplot(group_stats, aes(x = birth_cohort, y = log_wage)) +
    geom_line(color = "dodger blue") +
    geom_point(color = "blue") + 
    scale_y_continuous(breaks = seq(5.85, 5.95, by = 0.1)) +
    ylim(5.86, 5.94) +
    scale_x_continuous(breaks = round(seq(1930, 1940, by = 1),1)) +
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
