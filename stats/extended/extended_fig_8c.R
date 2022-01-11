# -----------------
# EXTENDED DATA
# FIGURE 8C
# -----------------

# The code and data of this repository are intended to promote reproducible research of the paper
# "$PAPER_TITLE"
# Details about the project can be found at the following webpage:
# https://aim.hms.harvard.edu/$FACEAGE_HANDLE

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# AIM 2022

library(survival)
library(survcomp)
library(survminer)

library(plyr)
library(dplyr)
library(tidyr)

library(ggplot2)
library(ggthemes)

## ----------------------------------------------------------

# TEACHH cohort (clinical)
teachh_base_path <- "/mnt/data1/FaceAge/stats"
teachh_file_name <- "17669-palliative.csv"
teachh_file_path <- file.path(teachh_base_path, teachh_file_name)

teachh_cohort <- read.csv(file = teachh_file_path, stringsAsFactors = FALSE)

## ----------------------------------------------------------
## ----------------------------------------------------------

# survival observation time in years (-1 = all time)
years_cap = 3

# censor individuals whose survival is longer than the observation time
teachh_cohort$event.flag[teachh_cohort$survival.time > years_cap] = 0

# survival time cutoff by risk group in years (group B is between A and C)
t_group_a = 3/12
t_group_c = 1

# age threshold for TEACHH scoring by model (years)
age_threshold_faceage = 60
age_threshold_chrono = 60

# drop duplicate entries if any
teachh_cohort <- unique(teachh_cohort)

teachh_cohort$delta = teachh_cohort$face.age - teachh_cohort$chronologic.age

teachh_df <- teachh_cohort[c("Cancer.Type", "ECOG", "Prior.Pal.Chemo",
                             "Hospital.Admits", "Mets_liver", "chronologic.age",
                             "face.age", "delta", "event.flag", "survival.time")]


# omit rows with at least a NA in the selected columns
teachh_df = teachh_df[complete.cases(teachh_df), ]

teachh_score_func <- function(x){
  score = 0
  
  # score goes up if Cancer Type, in column one, is not "breast" or "prostate"
  if(x[1] != "breast" & x[1] != "prostate"){
    score = score + 1
  }
  
  # score goes up if ECOG, in column two, is >= 2
  if(x[2] >= 2){
    score = score + 1
  }
  
  # score goes up if prior palliative chemo (two fractions?) was administered to the patient (column three)
  if(x[3] > 2){
    score = score + 1
  }
  
  # score goes up if the patient was previously admitted to the hospital (column four)
  if(x[4] > 0){
    score = score + 1
  }
  
  # score goes up if metastases were reported for the patient (column five)
  if(x[5] > 0){
    score = score + 1
  }
  
  score_chrono = score
  score_faceage = score
  
  # score goes up if chrono age > age_threshold_chrono (column six)
  if(x[6] > age_threshold_chrono){
    score_chrono = score_chrono + 1
  }
  
  # score goes up if faceage > age_threshold_faceage (column six)
  if(x[7] > age_threshold_faceage){
    score_faceage = score_faceage + 1
  }
  
  ret_df <- data.frame(matrix(ncol = 2, nrow = 1))
  colnames(ret_df) <- c("score_chrono", "score_faceage")
  
  return(list("score_chrono" = score_chrono,
              "score_faceage" = score_faceage)) 
  
}

score_list <- apply(teachh_df, 1, teachh_score_func)
score_df <- data.frame(matrix(unlist(score_list), nrow = length(score_list), byrow = TRUE))
names(score_df) <- c("score_chrono", "score_faceage")

teachh_df$score_chrono = score_df$score_chrono
teachh_df$score_faceage = score_df$score_faceage

score_threshold_low = 2
score_threshold_high = 4

teachh_df$group_chrono = NA
teachh_df$group_chrono[which(teachh_df$score_chrono < score_threshold_low)] = "low"
teachh_df$group_chrono[which(teachh_df$score_chrono >= score_threshold_low &
                               teachh_df$score_chrono <= score_threshold_high)] = "mid"
teachh_df$group_chrono[which(teachh_df$score_chrono > score_threshold_high)] = "high"
teachh_df$group_chrono = factor(teachh_df$group_chrono)


teachh_df$group_faceage = NA
teachh_df$group_faceage[which(teachh_df$score_faceage < score_threshold_low)] = "low"
teachh_df$group_faceage[which(teachh_df$score_faceage >= score_threshold_low &
                                teachh_df$score_faceage <= score_threshold_high)] = "mid"
teachh_df$group_faceage[which(teachh_df$score_faceage > score_threshold_high)] = "high"
teachh_df$group_faceage = factor(teachh_df$group_faceage)


teachh_df$group_chrono <- factor(teachh_df$group_chrono, levels = c("low", "mid", "high"))
teachh_df$group_faceage <- factor(teachh_df$group_faceage, levels = c("low", "mid", "high"))

## ----------------------------------------------------------
## ----------------------------------------------------------

# shades of yellow and shades of blue
custom_palette = c("#dacaaa", "#c7af7f", "#b39352", # Chrono age
                   "#61C5E8", "#2DABD6", "#0E799E") # FaceAge


# Chrono age
fit_chrono <- survfit(Surv(survival.time, event.flag) ~ group_chrono, data = teachh_df)

# FaceAge
fit_faceage <- survfit(Surv(survival.time, event.flag) ~ group_faceage, data = teachh_df)


fit <- list(chrono = fit_chrono, faceage = fit_faceage)

ggsurvplot(fit,
           data = teachh_df,
           surv.scale = "percent",
           xlab = 'Time (Years)', ylab = "Survival Probability [%]",
           xlim = c(0, years_cap),
           break.time.by = .5,
           size = c(0.5, 0.1),
           legend.labs = c("Age L", "Age M", "Age H",
                           "FaceAge L", "FaceAge M", "FaceAge H"),
           legend.title = "", legend = 0,
           combine = TRUE,
           risk.table = TRUE, conf.int = FALSE, censor = FALSE,
           tables.height = 0.35,
           tables.theme = theme_cleantable(),
           palette = custom_palette,
           linetype = c("solid", "solid", "solid",
                        "solid", "solid", "solid"),
           ggtheme = theme_classic2(base_size = 16, base_family = "Times New Roman"),
           font.family = "Times New Roman")

## ----------------------------------------------------------

teachh_df$group_chrono <- factor(teachh_df$group_chrono, levels = c("mid", "low", "high"))
teachh_df$group_faceage <- factor(teachh_df$group_faceage, levels = c("mid", "low", "high"))

res_cox_chrono <- coxph(Surv(survival.time, event.flag) ~ group_chrono, data = teachh_df)

res_cox_faceage <- coxph(Surv(survival.time, event.flag) ~ group_faceage, data = teachh_df)

