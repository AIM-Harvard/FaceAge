# The code and data of this repository are intended to promote reproducible research of the paper
# "$PAPER_TITLE"
# Details about the project can be found at the following webpage: 
# https://aim.hms.harvard.edu/$FACEAGE_HANDLE

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

library(survival)
library(survcomp)
library(survminer)

library(plyr)
library(dplyr)
library(tidyr)

library(ggplot2)
library(ggthemes)

## ----------------------------------------------------------

res_base_path <- "/mnt/data1/FaceAge/stats"

maastro_file_name = "stats_maastro_cur_qa_all.csv"
maastro_file_path = file.path(res_base_path, maastro_file_name)

maastro_whole = read.csv(file = maastro_file_path, stringsAsFactors = FALSE)

# cap survival AT 7 years
cap_years = 7
maastro_whole$death[which(maastro_whole$days_survived >= cap_years*365)] = 0
maastro_whole$days_survived[which(maastro_whole$days_survived >= cap_years*365)] = cap_years*365

# convert sex = M/F in 0/1
maastro_whole$sex = factor(maastro_whole$sex)
maastro_whole$sex_int = NA
maastro_whole$sex_int[which(maastro_whole$sex == 'M')] = 0
maastro_whole$sex_int[which(maastro_whole$sex == 'F')] = 1

# group the smaller sites
maastro_whole$site[which(maastro_whole$site == "UNK")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "NEU")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "HEM")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "DER")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "ALG")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "SAR")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "GYN")] = "OTH"

maastro_whole$site = factor(maastro_whole$site)

# results per decade
maastro_whole$dec_faceage = NA
maastro_whole$dec_faceage = 0.1 * maastro_whole$faceage

maastro_whole$dec_chrono_age = NA
maastro_whole$dec_chrono_age = 0.1 * maastro_whole$chrono_age
maastro_whole$dec_product = (maastro_whole$dec_faceage * maastro_whole$dec_chrono_age)

maastro_whole$difference = (maastro_whole$chrono_age - maastro_whole$faceage)
maastro_whole$dec_difference = (maastro_whole$dec_chrono_age - maastro_whole$dec_faceage)

## SITE AND INTENT
maastro_cur = maastro_whole[which(maastro_whole$intent == 'cur'), ]

# exclude DCIS patients
maastro_cur = maastro_cur[-which(maastro_cur$site == "MAM" & maastro_cur$exclude == 1), ]

maastro_breast = maastro_cur[which(maastro_cur$site == 'MAM'), ]
maastro_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
maastro_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
maastro_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
maastro_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
maastro_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------
## ----------------------------------------------------------

## -- STATS --

sel_cohort = maastro_breast

## -- FaceAge --

uva = coxph(Surv(days_survived, death) ~ dec_faceage, data = sel_cohort)
uva_summary = summary(uva)

uva_lower95 = round(uva_summary$conf.int[, 3], 3)
uva_upper95 = round(uva_summary$conf.int[, 4], 3)

uva_res = data.frame("HR" = round(uva_summary$conf.int[, 1], 5), 
                     "CI" = paste(uva_lower95, "-", uva_upper95, sep = ""), 
                     "p-value" = round(uva_summary$coefficients[ , "Pr(>|z|)"], 20))

uva_res$p.value = round(uva_res$p.value, 5)
uva_res$p.value[which(uva_res$p.value < 0.001)] = "< 0.001"

row.names(uva_res) = c("dec_faceage")

## ----------------------------------------------------------

## -- Corrected for Age --

mva_age = coxph(Surv(days_survived, death) ~ dec_faceage + dec_chrono_age, data = sel_cohort)
mva_age_summary = summary(mva_age)

mva_age_res = data.frame(round(mva_age_summary$conf.int[,-2], 5), 
                         "p-value" = round(mva_age_summary$coefficients[ , "Pr(>|z|)"], 20))

mva_age_res$p.value = round(mva_age_res$p.value, 5)
mva_age_res$p.value[which(mva_age_res$p.value < 0.001)] = "< 0.001"

mva_age_res$CI = paste(mva_age_res$lower..95, "-",
                       mva_age_res$upper..95, sep = "")

mva_age_res = mva_age_res[, c("exp.coef.","CI","p.value")]
mva_age_res = rename(mva_age_res, c("HR" = "exp.coef.",
                                    "p value" = "p.value"))

## ----------------------------------------------------------

## -- Corrected for Age and Gender --

mva_age_gender = coxph(Surv(days_survived, death) ~ dec_faceage + sex + dec_chrono_age,
                       data = sel_cohort)
mva_age_gender_summary = summary(mva_age_gender)

mva_age_gender_res = data.frame(round(mva_age_gender_summary$conf.int[,-2], 5), 
                                "p-value" = round(mva_age_gender_summary$coefficients[ , "Pr(>|z|)"], 20))

mva_age_gender_res$p.value = round(mva_age_gender_res$p.value, 5)
mva_age_gender_res$p.value[which(mva_age_gender_res$p.value < 0.001)] = "< 0.001"

mva_age_gender_res$CI = paste(mva_age_gender_res$lower..95, "-",
                              mva_age_gender_res$upper..95, sep = "")

mva_age_gender_res = mva_age_gender_res[, c("exp.coef.","CI","p.value")]
mva_age_gender_res = rename(mva_age_gender_res, c("HR" = "exp.coef.",
                                                  "p value" = "p.value"))

## ----------------------------------------------------------

cat(sprintf("N=%g, N Events=%g\n", uva_summary$n, uva_summary$nevent))
print(uva_res)
print(mva_age_res)
print(mva_age_gender_res)
