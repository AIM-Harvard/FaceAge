# -----------------
# EXTENDED DATA
# FIGURE 1 A-G
# -----------------

# The code and data of this repository are intended to promote transparent and reproducible research
# of the paper "Decoding biological age from face photographs using deep learning"

# All the details about the project can be found at the following webpage:
# aim.hms.harvard.edu/FaceAge

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# AIM 2022

library(ggplot2)
library(ggpubr)
library(ggExtra)

## ----------------------------------------------------------
## ----------------------------------------------------------

# UTK data
utk_base_path = "/mnt/data1/utk/stability_test/res"
utk_file_name = "stability_utk_range_h250_w200_qa.csv"
utk_file_path = file.path(utk_base_path, utk_file_name)

# technical validation on all the adults > 20 yo (high-res faces)
# (training was done on a balanced dataset, but curation was for >60 yo only)
utk_thresh = 20
utk_whole = read.csv(file = utk_file_path, stringsAsFactors = FALSE)

utk_whole$delta = NA
utk_whole$delta = utk_whole$age_pred - utk_whole$age

# output data from the model must include these columns:
# - chrono age (GT)
# - predicted age
# - delta (age_pred - chrono age)
# - race (baaad word but that's what's used in medicine)
# - gender
utk_df = utk_whole[which(utk_whole$age >= utk_thresh), ]
utk_df = utk_df[c("X", "age", "age_pred", "delta", "race", "gender")]

# from https://susanqq.github.io/UTKFace/
# race is an integer from 0 to 4, denoting:
# 0. White
# 1. Black
# 2. Asian,
# 3. Indian
# 4. Others (e.g., Hispanic, Latino, Middle Eastern).
utk_df$race_str = NA
utk_df$race_str[which(utk_df$race == 0)] = "white"
utk_df$race_str[which(utk_df$race == 1)] = "black"
utk_df$race_str[which(utk_df$race == 2)] = "asian"
utk_df$race_str[which(utk_df$race == 3)] = "indian"
utk_df$race_str[which(utk_df$race == 4)] = "other"

# from https://susanqq.github.io/UTKFace/
#gender is either 0 (male) or 1 (female)
utk_df$gender_str = NA
utk_df$gender_str[which(utk_df$gender == 0)] = "males"
utk_df$gender_str[which(utk_df$gender == 1)] = "females"

## ----------------------------------------------------------

## --  compute MAE for all the different subgroups  --

# DF for females and males
utk_male = utk_df[which(utk_df$gender == 0), ]
utk_female = utk_df[which(utk_df$gender == 1), ]

delta_male = utk_male$delta
delta_female = utk_female$delta

sprintf("MAE - male individuals: %g", mean(abs(delta_male)))
sprintf("MAE - female individuals: %g", mean(abs(delta_female)))

## ----------------------------------------------------------

# DF for different races
utk_white = utk_df[which(utk_df$race == 0), ]
utk_black = utk_df[which(utk_df$race == 1), ]
utk_asian = utk_df[which(utk_df$race == 2), ]
utk_indian = utk_df[which(utk_df$race == 3), ]
utk_other = utk_df[which(utk_df$race == 4), ]

delta_white = utk_white$delta
delta_black = utk_black$delta
delta_asian = utk_asian$delta
delta_indian = utk_indian$delta
delta_other = utk_other$delta

sprintf("MAE - white individuals: %g", mean(abs(delta_white)))
sprintf("MAE - black individuals: %g", mean(abs(delta_black)))
sprintf("MAE - asian individuals: %g", mean(abs(delta_asian)))
sprintf("MAE - indian individuals: %g", mean(abs(delta_indian)))
sprintf("MAE - other individuals: %g", mean(abs(delta_other)))

## ----------------------------------------------------------
## ----------------------------------------------------------

## --  compute R² for all the different subgroups  --
rsq <- function(x, y) summary(lm(y~x))$r.squared

rsq_male = rsq(utk_male$age_pred, utk_male$age)
rsq_female = rsq(utk_female$age_pred, utk_female$age)

sprintf("R² - male individuals: %g", rsq_male)
sprintf("R² - female individuals: %g", rsq_female)

## ----------------------------------------------------------

rsq_white = rsq(utk_white$age_pred, utk_white$age)
rsq_black = rsq(utk_black$age_pred, utk_black$age)
rsq_asian = rsq(utk_asian$age_pred, utk_asian$age)
rsq_indian = rsq(utk_indian$age_pred, utk_indian$age)
rsq_other = rsq(utk_other$age_pred, utk_other$age)

sprintf("R² - white individuals: %g", rsq_white)
sprintf("R² - black individuals: %g", rsq_black)
sprintf("R² - asian individuals: %g", rsq_asian)
sprintf("R² - indian individuals: %g", rsq_indian)
sprintf("R² - other individuals: %g", rsq_other)

## ----------------------------------------------------------

## --  SCATTERPLOT  --

gtheme <- theme(text = element_text(family = "Times New Roman"),
                axis.title.x = element_text(size = 25),
                axis.title.y = element_text(size = 25),
                axis.text.x = element_text(size = 22, margin = margin(t = 10)),
                axis.text.y = element_text(size = 22, margin = margin(r = 10)),
                legend.position = "none",
                plot.title = element_text(hjust = 0.5, size = 25))

# palette per gender and ethnicity
custom_palette = c("#1B4F72", # overall
                   "#029c8f", "#EE965C", # sex
                   "#2471A3", "#2980B9", "#5499C7", "#7FB3D5") # ethnicity

# manually set based on the cohort
sel = utk_df
color = custom_palette[1]
cohort_name = "UTK"
title_str = sprintf("%s (N=%g)", cohort_name, nrow(sel))


# R² of the selected cohort
sel_rsq = rsq(sel$age_pred, sel$age)

# Pearson's r of the selected cohort
sel_pearson = cor.test(sel$age_pred, sel$age, method = "pearson")

# quick and dirty fix for plot exporting - set it to < eps
if(sel_pearson$p.value < 2.2e-16){
  # if the Pearsons's p-val is < 2.2e-16, display it like that instead of the raw value
  pval_str = sprintf("r = %g (p-val < 2.2e-16)", sel_pearson$estimate)
} else{
  pval_str = sprintf("r = %g (p-val = %g)",
                     sel_pearson$estimate,
                     round(sel_pearson$p.value, 5))
}

mae_str = sprintf("MAE = %g",  mean(abs(sel$delta)))

## ------------------

sctpl = ggplot(sel, aes(x = age, y = age_pred, size = 1)) + 
  ggtitle(paste(title_str, "\n", pval_str, "\n", mae_str, sep = "")) +
  geom_point(size = 1, alpha = 1/2, color = color) +
  geom_smooth(method = lm, color = "#34495E", fill = "#85929E", size = 0.75) +
  scale_x_continuous(minor_breaks = seq(0 , 110, 5),
                     expand = expansion(mult = c(0.0, 0.0)),
                     lim = c(14.9, 105.1)) +
  scale_y_continuous(minor_breaks = seq(0 , 110, 5),
                     expand = expansion(mult = c(0.0, 0.0)),
                     lim = c(14.9, 105.1)) +
  theme_minimal() + gtheme +
  guides(fill = FALSE, col = FALSE) +
  ylab('FaceAge') + xlab("Age")


# marginal histogram
ggMarginal(sctpl, type = "densigram",
           col = "black", fill = color, size = 6,
           xparams = list(binwidth = 3, size = .15, alpha = 0.9),
           yparams = list(binwidth = 3, size = .15, alpha = 0.9))

