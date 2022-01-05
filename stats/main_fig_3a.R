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
library(ggbeeswarm)

## ----------------------------------------------------------
## ----------------------------------------------------------

# MAASTRO cohort
maastro_base_path = "/mnt/data1/FaceAge/stats"
maastro_file_name = "stats_maastro_cur_qa_all.csv"
maastro_file_path = file.path(maastro_base_path, maastro_file_name)

maastro_whole = read.csv(file = maastro_file_path, stringsAsFactors = FALSE)

# cap survival AT 7 years - longest period of time possible without losing to FUP >90% of the cohort
cap_years = 7

maastro_whole$death[which(maastro_whole$days_survived >= cap_years*365)] = 0
#maastro_whole$days_survived[which(maastro_whole$days_survived >= cap_years*365)] = cap_years*365 + 1

# convert sex = M/F in 0/1
maastro_whole$sex = factor(maastro_whole$sex)
maastro_whole$sex_int = NA
maastro_whole$sex_int[which(maastro_whole$sex == 'M')] = 0
maastro_whole$sex_int[which(maastro_whole$sex == 'F')] = 1

# use Breast cancer patients as reference group
maastro_whole$site[which(maastro_whole$site == "MAM")] = "0_MAM"

# group the smaller sites
maastro_whole$site[which(maastro_whole$site == "GYN")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "UNK")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "NEU")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "HEM")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "DER")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "ALG")] = "OTH"
maastro_whole$site[which(maastro_whole$site == "SAR")] = "OTH"

maastro_whole$site = factor(maastro_whole$site)

# results per decade
maastro_whole$dec_faceage = NA
maastro_whole$dec_faceage = 0.1 * maastro_whole$faceage

maastro_whole$dec_chrono_age = NA
maastro_whole$dec_chrono_age = 0.1 * maastro_whole$chrono_age

# convert faceage in classes
# FIXME
maastro_whole$faceage_group = NA
maastro_whole$faceage_group[which(maastro_whole$faceage <= 65)] = 0
maastro_whole$faceage_group[which(maastro_whole$faceage > 65 & maastro_whole$faceage <= 75)] = 1
maastro_whole$faceage_group[which(maastro_whole$faceage > 75 & maastro_whole$faceage <= 85)] = 2
maastro_whole$faceage_group[which(maastro_whole$faceage > 85)] = 3
maastro_whole$faceage_group = factor(maastro_whole$faceage_group)


maastro_whole$dec_product = (maastro_whole$dec_faceage * maastro_whole$dec_chrono_age)
maastro_whole$product = (maastro_whole$faceage * maastro_whole$chrono_age)
maastro_whole$product_group = (as.numeric(maastro_whole$faceage_group) * maastro_whole$chrono_age)

maastro_whole$difference = (maastro_whole$chrono_age - maastro_whole$faceage)
maastro_whole$dec_difference = (maastro_whole$dec_chrono_age - maastro_whole$dec_faceage)

maastro_whole$ratio = (maastro_whole$chrono_age/maastro_whole$faceage)
maastro_whole$ratio = (maastro_whole$faceage/maastro_whole$chrono_age)

## SITE AND INTENT
maastro_cur = maastro_whole[which(maastro_whole$intent == 'cur'), ]

maastro_cur = maastro_cur[-which(maastro_cur$site == "0_MAM" & maastro_cur$exclude == 1), ]

data_breast = maastro_cur[which(maastro_cur$site == '0_MAM'), ]
data_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
data_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
data_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
data_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
data_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------
## ----------------------------------------------------------

# DeepCAC
custom_palette = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728")


fit <- survfit(Surv(days_survived, death) ~ faceage_group, data = maastro_cur)
fit_diff = survdiff(Surv(days_survived, death) ~ faceage_group, data = maastro_cur)

ggsurvplot(fit = fit,
           surv.scale = "percent",
           size = 0.75,
           ## -- risk table --
           risk.table = TRUE,
           tables.theme = theme_cleantable(),
           risk.table.height = 0.225,
           ## -- conf int and censor --
           conf.int = FALSE, conf.int.style = "step",
           censor = FALSE, censor.size = 1,
           ## -- log rank and stats --
           pval = TRUE, pval.method = TRUE,
           log.rank.weights = "1",
           ## -- axes --
           xlim = c(0, 2700), xscale = "d_y", break.time.by = 365.25,
           xlab = 'Time (Years)', ylab = "Survival Probability [%]",
           ## -- legend and theme --
           legend.labs = c("FaceAge ≤ 65", "65 < FaceAge ≤ 75",
                           "75 < FaceAge ≤ 85", "FaceAge > 85"),
           palette = custom_palette,
           legend.title = "",
           ggtheme = theme_classic2(base_size = 16, base_family = "Times New Roman"),
           font.family = "Times New Roman")

## ----------------------------------------------------------
## ----------------------------------------------------------

## -- FaceAge --

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

## -- Corrected for Age, Gender, and Site (should be used with the whole cohort only) --

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