# -----------------
# MAIN PAPER
# FIGURE 3B
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

library(survival)
library(survcomp)
library(survminer)

library(plyr)
library(dplyr)
library(tidyr)

library(ggplot2)
library(ggthemes)
library(ggbeeswarm)

## ----------------------------------------------------------
## ----------------------------------------------------------

# MAASTRO cohort
#maastro_base_path = "/mnt/data1/FaceAge/stats"
maastro_base_path = "/Users/den/Desktop/FaceAge_data_Grace"
#maastro_file_name = "stats_maastro_cur_qa_all.csv"
maastro_file_name = "stats_maastro_cur_histology_qa.csv"
maastro_file_path = file.path(maastro_base_path, maastro_file_name)

maastro_cur = read.csv(file = maastro_file_path, stringsAsFactors = FALSE)

# cap survival AT 7 years - longest period of time possible without losing to FUP >90% of the cohort
cap_years = 7

maastro_cur$death[which(maastro_cur$days_survived >= cap_years*365)] = 0
#maastro_cur$days_survived[which(maastro_cur$days_survived >= cap_years*365)] = cap_years*365 + 1

# convert sex = M/F in 0/1
maastro_cur$sex = factor(maastro_cur$sex)
maastro_cur$sex_int = NA
maastro_cur$sex_int[which(maastro_cur$sex == 'M')] = 0
maastro_cur$sex_int[which(maastro_cur$sex == 'F')] = 1

# use Breast cancer patients as reference group
maastro_cur$site[which(maastro_cur$site == "MAM")] = "0_MAM"

# group the smaller sites
maastro_cur$site[which(maastro_cur$site == "GYN")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "UNK")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "NEU")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "HEM")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "DER")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "ALG")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "SAR")] = "OTH"

maastro_cur$site = factor(maastro_cur$site)

# results per decade
maastro_cur$dec_faceage = NA
maastro_cur$dec_faceage = 0.1 * maastro_cur$faceage

maastro_cur$dec_chrono_age = NA
maastro_cur$dec_chrono_age = 0.1 * maastro_cur$chrono_age

# convert faceage in classes
maastro_cur$faceage_group = NA
maastro_cur$faceage_group[which(maastro_cur$faceage <= 65)] = 0
maastro_cur$faceage_group[which(maastro_cur$faceage > 65 & maastro_cur$faceage <= 75)] = 1
maastro_cur$faceage_group[which(maastro_cur$faceage > 75 & maastro_cur$faceage <= 85)] = 2
maastro_cur$faceage_group[which(maastro_cur$faceage > 85)] = 3
maastro_cur$faceage_group = factor(maastro_cur$faceage_group)

# exclude DCIS patients
maastro_cur = maastro_cur[-which(maastro_cur$site == "0_MAM" & maastro_cur$exclude == 1), ]

data_breast = maastro_cur[which(maastro_cur$site == '0_MAM'), ]
data_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
data_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
data_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
data_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
data_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------
## ----------------------------------------------------------

## -- UVA --

uva = coxph(Surv(days_survived, death) ~ faceage_group,
            data = maastro_cur)
uva_summary = summary(uva)

uva_res = data.frame(round(uva_summary$conf.int[,-2], 5), 
                     "p-value" = round(uva_summary$coefficients[ , "Pr(>|z|)"], 20))

uva_res$p.value = round(uva_res$p.value, 5)
uva_res$p.value[which(uva_res$p.value < 0.001)] = "< 0.001"

uva_res$CI = paste(uva_res$lower..95, "-",
                   uva_res$upper..95, sep = "")

uva_res = uva_res[, c("exp.coef.","CI","p.value")]
uva_res = rename(uva_res, c("HR" = "exp.coef.",
                            "p value" = "p.value"))


cat(sprintf("N=%g, N Events=%g\n", uva_res$n, uva_res$nevent))
print(uva_res)

## ----------------------------------------------------------
## ----------------------------------------------------------

## -- MVA --

# adjust for Age, Gender, and Site (the latter for the whole cohort only)
mva_agsite = coxph(Surv(days_survived, death) ~ faceage_group + chrono_age + site + sex,
                   data = maastro_cur)
mva_agsite_summary = summary(mva_agsite)

mva_agsite_res = data.frame(round(mva_agsite_summary$conf.int[,-2], 5), 
                            "p-value" = round(mva_agsite_summary$coefficients[ , "Pr(>|z|)"], 20))

mva_agsite_res$p.value = round(mva_agsite_res$p.value, 5)
mva_agsite_res$p.value[which(mva_agsite_res$p.value < 0.001)] = "< 0.001"

mva_agsite_res$CI = paste(mva_agsite_res$lower..95, "-",
                          mva_agsite_res$upper..95, sep = "")

mva_agsite_res = mva_agsite_res[, c("exp.coef.","CI","p.value")]
mva_agsite_res = rename(mva_agsite_res, c("HR" = "exp.coef.",
                                          "p value" = "p.value"))


cat(sprintf("N=%g, N Events=%g\n", mva_agsite_res$n, mva_agsite_res$nevent))
print(mva_agsite_res)
