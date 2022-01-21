# -----------------
# MAIN PAPER
# FIGURE 2A
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
maastro_base_path = "/mnt/data1/FaceAge/stats"
maastro_file_name = "stats_maastro_cur_qa_all.csv"

maastro_file_path = file.path(maastro_base_path, maastro_file_name)

maastro_whole = read.csv(file = maastro_file_path, stringsAsFactors = FALSE)

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
maastro_whole$delta = maastro_whole$faceage - maastro_whole$chrono_age

## SITE AND INTENT
maastro_cur = maastro_whole[which(maastro_whole$intent == 'cur'), ]

# exclude DCIS patients
maastro_cur = maastro_cur[-which(maastro_cur$site == "MAM" & maastro_cur$exclude == 1), ]

data_breast = maastro_cur[which(maastro_cur$site == 'MAM'), ]
data_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
data_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
data_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
data_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
data_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------
## ----------------------------------------------------------

# HARVARD cohort
harvard_base_path <- "/mnt/data1/FaceAge/stats"

# Thoracic cohort
thor_csv_name <- "11286-thoracic.csv"
thor_csv_path <- file.path(harvard_base_path, thor_csv_name)

thor_whole <- read.csv(file = thor_csv_path, stringsAsFactors = FALSE)

names(thor_whole)[names(thor_whole) == 'face.age'] <- 'faceage'
names(thor_whole)[names(thor_whole) == 'chronologic.age'] <- 'chrono_age'
names(thor_whole)[names(thor_whole) == 'survival.time'] <- 'years_survived'
names(thor_whole)[names(thor_whole) == 'event.flag'] <- 'event'

thor_whole$delta = thor_whole$faceage - thor_whole$chrono_age

## ----------------

# Palliative cohort
pall_csv_name <- "17669-palliative.csv"
pall_csv_path <- file.path(harvard_base_path, pall_csv_name)

pall_whole <- read.csv(file = pall_csv_path, stringsAsFactors = FALSE)

names(pall_whole)[names(pall_whole) == 'face.age'] <- 'faceage'
names(pall_whole)[names(pall_whole) == 'chronologic.age'] <- 'chrono_age'
names(pall_whole)[names(pall_whole) == 'survival.time'] <- 'years_survived'
names(pall_whole)[names(pall_whole) == 'event.flag'] <- 'event'

pall_whole$delta = pall_whole$faceage - pall_whole$chrono_age

## ----------------------------------------------------------
## ----------------------------------------------------------

# UTK data
utk_base_path = "/mnt/data1/utk/stability_test/res"
utk_file_name = "stability_utk_range_h250_w200_qa.csv"
utk_file_path = file.path(utk_base_path, utk_file_name)

# clinical validation on all the adults > 60 yo (same logic applied to the curation)
utk_thresh = 60
utk_whole = read.csv(file = utk_file_path, stringsAsFactors = FALSE)
utk_range = utk_whole[which(utk_whole$age >= utk_thresh), ]

## ----------------------------------------------------------
## ----------------------------------------------------------

pos_vec_x = c(1, 3.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 13.5, 14.5, 15.5)


utk_delta = utk_range$age_pred - utk_range$age
utk_df <- data.frame(utk_delta,
                     rep("UTK", times = length(utk_delta)),
                     rep("UTK", times = length(utk_delta)),
                     pos_vec_x[1])
names(utk_df) <- c("delta", "cohort", "source", "x")

## ----------------

maastro_delta = maastro_cur$faceage - maastro_cur$chrono_age
maastro_df <- data.frame(maastro_delta,
                         rep("MAASTRO", times = length(maastro_delta)),
                         rep("MAASTRO", times = length(maastro_delta)),
                         pos_vec_x[3])
names(maastro_df) <- c("delta", "cohort", "source", "x")

breast_delta = data_breast$faceage - data_breast$chrono_age
breast_df <- data.frame(breast_delta,
                        rep("Breast", times = length(breast_delta)),
                        rep("MAASTRO", times = length(breast_delta)),
                        pos_vec_x[4])
names(breast_df) <- c("delta", "cohort", "source", "x")

gi_delta = data_gi$faceage - data_gi$chrono_age
gi_df <- data.frame(gi_delta,
                    rep("GI", times = length(gi_delta)),
                    rep("MAASTRO", times = length(gi_delta)),
                    pos_vec_x[5])
names(gi_df) <- c("delta", "cohort", "source", "x")

gu_delta = data_gu$faceage - data_gu$chrono_age
gu_df <- data.frame(gu_delta,
                    rep("GU", times = length(gu_delta)),
                    rep("MAASTRO", times = length(gu_delta)),
                    pos_vec_x[6])
names(gu_df) <- c("delta", "cohort", "source", "x")

lung_delta = data_lung$faceage - data_lung$chrono_age
lung_df <- data.frame(lung_delta,
                      rep("Lung", times = length(lung_delta)),
                      rep("MAASTRO", times = length(lung_delta)),
                      pos_vec_x[7])
names(lung_df) <- c("delta", "cohort", "source", "x")

hn_delta = data_hn$faceage - data_hn$chrono_age
hn_df <- data.frame(hn_delta,
                    rep("H&N", times = length(hn_delta)),
                    rep("MAASTRO", times = length(hn_delta)),
                    pos_vec_x[8])
names(hn_df) <- c("delta", "cohort", "source", "x")

oth_delta = data_oth$faceage - data_oth$chrono_age
oth_df <- data.frame(oth_delta,
                     rep("Other", times = length(oth_delta)),
                     rep("MAASTRO", times = length(oth_delta)),
                     pos_vec_x[9])
names(oth_df) <- c("delta", "cohort", "source", "x")

## ----------------

thoracic_delta = thor_whole$faceage - thor_whole$chrono_age
thor_df <- data.frame(thoracic_delta,
                      rep("Thoracic", times = length(thoracic_delta)),
                      rep("HARVARD", times = length(thoracic_delta)),
                      pos_vec_x[10])
names(thor_df) <- c("delta", "cohort", "source", "x")


pall_delta = pall_whole$faceage - pall_whole$chrono_age
pall_df <- data.frame(pall_delta,
                      rep("Palliative", times = length(pall_delta)),
                      rep("HARVARD", times = length(pall_delta)),
                      pos_vec_x[11])
names(pall_df) <- c("delta", "cohort", "source", "x")


harvard_df = rbind(thor_df, pall_df)
harvard_df$cohort = "HARVARD"
harvard_df$source = "HARVARD"
harvard_df$x = pos_vec_x[12]

## ----------------

all_df = rbind(maastro_df, harvard_df)
all_df$cohort = "ALL"
all_df$source = "ALL"
all_df$x = pos_vec_x[2]

maastro_men = maastro_cur[which(maastro_cur$sex == "M"), ]
maastro_men_delta = maastro_men$faceage - maastro_men$chrono_age

thor_men = thor_whole[which(thor_whole$gender == 0), ]
thor_men_delta = thor_men$faceage - thor_men$chrono_age

pall_men = pall_whole[which(pall_whole$Sex == "Male"), ]
pall_men_delta = pall_men$faceage - pall_men$chrono_age

all_men_delta = c(pall_men_delta, thor_men_delta, maastro_men_delta)
all_men_df <- data.frame(all_men_delta,
                         rep("Men", times = length(all_men_delta)),
                         rep("ALL", times = length(all_men_delta)),
                         4)
names(all_men_df) <- c("delta", "cohort", "source", "x")


maastro_women = maastro_cur[which(maastro_cur$sex == "F"), ]
maastro_women_delta = maastro_women$faceage - maastro_women$chrono_age

thor_women = thor_whole[which(thor_whole$gender == 1), ]
thor_women_delta = thor_women$faceage - thor_women$chrono_age

pall_women = pall_whole[which(pall_whole$Sex == "Female"), ]
pall_women_delta = pall_women$faceage - pall_women$chrono_age

all_women_delta = c(pall_women_delta, thor_women_delta, maastro_women_delta)
all_women_df <- data.frame(all_women_delta,
                           rep("Women", times = length(all_women_delta)),
                           rep("ALL", times = length(all_women_delta)),
                           3)
names(all_women_df) <- c("delta", "cohort", "source", "x")

## ----------------

newdf <- rbind(utk_df,
               all_df,
               maastro_df, breast_df, gi_df, lung_df, gu_df, hn_df, oth_df,
               harvard_df, thor_df, pall_df)

custom_palette <- c("#595959", # UTK
                    "#a5a5a5", # All sites, both cohorts
                    "#F77D2B", # whole, Maastro
                    "#ED7D31", "#DF8649", "#D98D59", "#D18E5F", "#C38B64", "#B28363",
                    "#0D779A", # whole, Harvard
                    "#35ACD3", "#73CEEC") # sites, Harvard

custom_names <- c(levels(unique(newdf$cohort)))

for(idx in 1:length(custom_names)){
  name = custom_names[idx]
  n_pat = nrow(newdf[which(newdf$cohort == name), ])
  custom_names[idx] = paste(custom_names[idx], sprintf("\n(n=%g)", n_pat), sep = "")
}

## ----------------------------------------------------------
## ----------------------------------------------------------

gtheme <- theme(axis.title.x = element_text(size = 16,
                                            margin = unit(c(6, 0, 0, 0), "mm"),
                                            family = "Times New Roman"),
                axis.text.x = element_text(size = 10, family = "Times New Roman"),
                axis.title.y = element_text(size = 16,
                                            margin = unit(c(0, 6, 0, 0), "mm"),
                                            family = "Times New Roman"),
                axis.text.y = element_text(size = 14, family = "Times New Roman"))


ggplot(newdf, aes(x = cohort, y = delta, fill = cohort, col = cohort)) +
  geom_abline(slope = 0, col = "black", size = 0.25) +
  
  geom_vline(xintercept = 2.25, linetype = "dashed",
             col = "black", size = 0.25) +
  
  geom_beeswarm(aes(x = x, y = delta, group = x),
                priority = 'density', size = 1/5, alpha = 2/10, cex = 1/6) + 
  
  geom_boxplot(aes(x = x, y = delta, group = x),
               notch = FALSE, size = 1/3, alpha = 1, colour = "grey30",
               fill = NA, outlier.shape = NA, width = 2/5, notchwidth = 1/5) + 
  
  scale_fill_manual(values = custom_palette) +
  scale_colour_manual(values = custom_palette) +
  ylab('FaceAge - Age') +

  scale_y_continuous(breaks = c(-20, -10, -5, 0, 5, 10, 20), limits = c(-35, 40)) + 
  
  xlab("Cohort") +
  scale_x_continuous(breaks = pos_vec_x,
                     labels = custom_names,
                     limits = c(0.75, 15.75)) +
  
  theme_hc() + gtheme + 
  guides(fill = FALSE, col = FALSE) 
