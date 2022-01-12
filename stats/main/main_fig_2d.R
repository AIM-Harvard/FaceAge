# -----------------
# MAIN PAPER
# FIGURE 2D
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
library(ggbeeswarm)
library(pheatmap)

## ----------------------------------------------------------
## ----------------------------------------------------------

# MAASTRO cohort
maastro_base_path = "/mnt/data1/FaceAge/stats"
maastro_file_name = "stats_maastro_cur_qa_all.csv"
maastro_file_path = file.path(maastro_base_path, maastro_file_name)

maastro_cur = read.csv(file = maastro_file_path, stringsAsFactors = FALSE)

# fix empty in $smoking
maastro_cur$smoking[which(maastro_cur$smoking == "")] = NA
maastro_cur$smoking[which(maastro_cur$smoking == "passive")] = NA

# convert sex = M/F in 0/1
maastro_cur$sex = factor(maastro_cur$sex)
maastro_cur$sex_int = NA
maastro_cur$sex_int[which(maastro_cur$sex == 'M')] = 0
maastro_cur$sex_int[which(maastro_cur$sex == 'F')] = 1

# group the smaller sites
maastro_cur$site[which(maastro_cur$site == "UNK")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "NEU")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "HEM")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "DER")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "ALG")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "SAR")] = "OTH"
maastro_cur$site[which(maastro_cur$site == "GYN")] = "OTH"

maastro_cur$site = factor(maastro_cur$site)
maastro_cur$delta = (maastro_cur$faceage - maastro_cur$chrono_age)

## SITE AND INTENT

# exclude DCIS patients
maastro_cur = maastro_cur[-which(maastro_cur$site == "MAM" & maastro_cur$exclude == 1), ]

maastro_breast = maastro_cur[which(maastro_cur$site == 'MAM'), ]
maastro_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
maastro_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
maastro_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
maastro_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
maastro_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------

maastro_cur <- rename(maastro_cur, c("ECOG" = "ps"))

sel_cohort = maastro_cur
sel_cohort = sel_cohort %>% drop_na(ECOG)

sel_cohort$ECOG = factor(sel_cohort$ECOG)

site_name = "MAASTRO"
custom_palette = c("#00b4d8", "#0077b6", "#03045e", "#03045e")

median_zero = median(sel_cohort$delta[which(sel_cohort$ECOG == 0)])

ecog_zero = nrow(sel_cohort[which(sel_cohort$ECOG == 0), ])
ecog_one = nrow(sel_cohort[which(sel_cohort$ECOG == 1), ])
ecog_two = nrow(sel_cohort[which(sel_cohort$ECOG == 2), ])
ecog_three = nrow(sel_cohort[which(sel_cohort$ECOG == 3), ])
ecog_four = nrow(sel_cohort[which(sel_cohort$ECOG == 4), ])

custom_names = c(sprintf("0\n(n = %g)\n", ecog_zero),
                 sprintf("1\n(n = %g)\n", ecog_one),
                 sprintf("2\n(n = %g)\n", ecog_two),
                 sprintf("3\n(n = %g)\n", ecog_three),
                 sprintf("4\n(n = %g)\n", ecog_four))


gtheme <- theme(text = element_text(family = "Times New Roman"),
                axis.title.x = element_text(size = 16, margin = unit(c(6, 0, 0, 0), "mm")),
                axis.text.x = element_text(size = 13),
                axis.title.y = element_text(size = 16, margin = unit(c(0, 6, 0, 0), "mm")),
                axis.text.y = element_text(size = 13))

ggplot(sel_cohort, aes(x = ECOG, y = delta, fill = ECOG, col = ECOG)) +
  geom_abline(slope = 0, col = "black", size = 0.25) +
  geom_abline(slope = 0, intercept = median(median_zero), col = "grey", size = 0.5, linetype = 3) +
  
  geom_beeswarm(priority = 'density', size = 1/2, alpha = 2/10, cex = 2/3) + 
  
  geom_boxplot(aes(x = ECOG, y = delta, group = ECOG),
               notch = FALSE, size = 1/3, alpha = 1, colour = "grey30",
               fill = NA, outlier.shape = NA, width = 2/5, notchwidth = 1/5) + 
  
  ylab('FaceAge - Age') + xlab("ECOG") +
  
  scale_y_continuous(breaks = c(-20, -10, -5, 0, 5, 10, 20),
                     limits = c(-20, 37)) + 
  
  scale_x_continuous(limits = c(-0.25, 4.15)) + 
  scale_x_discrete(labels = custom_names) + 
  
  scale_fill_manual(values = custom_palette) +
  scale_colour_manual(values = custom_palette) +
  
  theme_hc() + gtheme + 
  guides(fill = FALSE, col = FALSE) 

## ----------------------------------------------------------

# PAIR-WISE
ecog0 = sel_cohort[which(sel_cohort$ECOG == 0), ]
ecog1 = sel_cohort[which(sel_cohort$ECOG == 1), ]
ecog2 = sel_cohort[which(sel_cohort$ECOG == 2), ]
ecog3 = sel_cohort[which(sel_cohort$ECOG == 3), ]

pval_df <- data.frame(matrix(ncol = 4, nrow = 4))
names(pval_df) <- c("ECOG 0", "ECOG 1", "ECOG 2", "ECOG 3")
rownames(pval_df) <- c("ECOG 0", "ECOG 1", "ECOG 2", "ECOG 3")

#stat_test = wilcox.test
stat_test = t.test

pval_df[1, 1] = stat_test(x = ecog0$delta, y = ecog0$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 2] = stat_test(x = ecog0$delta, y = ecog1$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 3] = stat_test(x = ecog0$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 4] = stat_test(x = ecog0$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[2, 2] = stat_test(x = ecog1$delta, y = ecog1$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 3] = stat_test(x = ecog1$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 4] = stat_test(x = ecog1$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[3, 3] = stat_test(x = ecog2$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[3, 4] = stat_test(x = ecog2$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[4, 4] = stat_test(x = ecog3$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value

dat <- matrix(rnorm(16, 4, 1), ncol = 4)
names(dat) <- paste("ECOG", 1:4)

pheatmap(pval_df, display_numbers = T, cluster_rows = F, cluster_cols = F,
         show_rownames = TRUE, show_colnames = TRUE, na_col = "white", border_color = "grey60",
         number_color = "black", legend = FALSE,
         labels_row = paste0("ECOG ", 0:3), labels_col = paste0("ECOG ", 0:3),
         number_format = "%1.3f", fontsize_number = 15, fontsize_row = 15, fontsize_col = 15,
         fontfamily = "Times New Roman")

