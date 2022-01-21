# -----------------
# EXTENDED DATA
# FIGURE 4C
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

library(data.table)

library(beeswarm)
library(raincloudplots)

library(plyr)
library(dplyr)
library(tidyr)

library(ggplot2)
library(ggthemes)
library(pheatmap)
library(ggbeeswarm)

## ----------------------------------------------------------
## ----------------------------------------------------------

res_base_path <- "/mnt/data1/FaceAge/stats"

# Thoracic cohort
thor_csv_name <- "11286-thoracic.csv"
thor_csv_path <- file.path(res_base_path, thor_csv_name)

thor_df <- read.csv(file = thor_csv_path, stringsAsFactors = FALSE)
thor_df <- rename(thor_df, c("ECOG" = "ps"))

# Palliative cohort
pall_csv_name <- "17669-palliative.csv"
pall_csv_path <- file.path(res_base_path, pall_csv_name)

pall_df <- read.csv(file = pall_csv_path, stringsAsFactors = FALSE)

## ----------------------------------------------------------
## ----------------------------------------------------------

tmp_a = thor_df[c("chronologic.age", "face.age", "ECOG")]
tmp_a$source = "Thoracic"

tmp_b = pall_df[c("chronologic.age", "face.age", "ECOG")]
tmp_b$source = "Palliative"

sel_cohort = rbind(tmp_a, tmp_b)

sel_cohort = sel_cohort %>% drop_na(ECOG)
sel_cohort$delta = sel_cohort$face.age - sel_cohort$chronologic.age
sel_cohort$ECOG = factor(sel_cohort$ECOG)

site_name = "HARVARD"
custom_palette = c("#00b4d8", "#0077b6", "#03045e", "#03045e", "#03045e")

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
               notch = FALSE, size = 1/3, alpha = 1,
               colour = "grey30", border = "black",
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

## -- STATS --

# PAIR-WISE
ecog0 = sel_cohort[which(sel_cohort$ECOG == 0), ]
ecog1 = sel_cohort[which(sel_cohort$ECOG == 1), ]
ecog2 = sel_cohort[which(sel_cohort$ECOG == 2), ]
ecog3 = sel_cohort[which(sel_cohort$ECOG == 3), ]
ecog4 = sel_cohort[which(sel_cohort$ECOG == 4), ]

pval_df <- data.frame(matrix(ncol = 4, nrow = 4))
pval_df <- data.frame(matrix(ncol = 5, nrow = 5))

names(pval_df) <- c("ECOG 0", "ECOG 1", "ECOG 2", "ECOG 3", "ECOG 4")
rownames(pval_df) <- c("ECOG 0", "ECOG 1", "ECOG 2", "ECOG 3", "ECOG 4")


stat_test = t.test

pval_df[1, 1] = stat_test(x = ecog0$delta, y = ecog0$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 2] = stat_test(x = ecog0$delta, y = ecog1$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 3] = stat_test(x = ecog0$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 4] = stat_test(x = ecog0$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 5] = stat_test(x = ecog0$delta, y = ecog4$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[2, 2] = stat_test(x = ecog1$delta, y = ecog1$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 3] = stat_test(x = ecog1$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 4] = stat_test(x = ecog1$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 5] = stat_test(x = ecog1$delta, y = ecog4$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[3, 3] = stat_test(x = ecog2$delta, y = ecog2$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[3, 4] = stat_test(x = ecog2$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[3, 5] = stat_test(x = ecog2$delta, y = ecog4$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[4, 4] = stat_test(x = ecog3$delta, y = ecog3$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[4, 5] = stat_test(x = ecog3$delta, y = ecog4$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[5, 5] = stat_test(x = ecog4$delta, y = ecog4$delta, paired = FALSE, alternative = "two.sided")$p.value

dat <- matrix(rnorm(25, 5, 1), ncol = 5)
names(dat) <- paste("ECOG", 1:5)

pheatmap(pval_df, display_numbers = T, cluster_rows = F, cluster_cols = F,
         show_rownames = TRUE, show_colnames = TRUE, na_col = "white", border_color = "grey60",
         number_color = "black", legend = FALSE,
         labels_row = paste0("ECOG ", 0:4), labels_col = paste0("ECOG ", 0:4),
         number_format = "%1.3f", fontsize_number = 15, fontsize_row = 15, fontsize_col = 15,
         fontfamily = "Times New Roman")

