# -----------------
# MAIN PAPER
# FIGURE 2B
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

# exclude DCIS patients
maastro_cur = maastro_cur[-which(maastro_cur$site == "MAM" & maastro_cur$exclude == 1), ]

maastro_breast = maastro_cur[which(maastro_cur$site == 'MAM'), ]
maastro_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
maastro_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
maastro_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
maastro_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
maastro_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------

# smokers only
maastro_to_plot = maastro_cur
maastro_to_plot = maastro_to_plot %>% drop_na(smoking)

site_name = "MAASTRO"
custom_palette = c("#e63946", "#f8961e", "#52b788")

never_delta = median(maastro_to_plot$delta[which(maastro_to_plot$smoking == "never")])

num_never = nrow(maastro_to_plot[which(maastro_to_plot$smoking == "never"), ])
num_current = nrow(maastro_to_plot[which(maastro_to_plot$smoking == "current"), ])
num_former = nrow(maastro_to_plot[which(maastro_to_plot$smoking == "former"), ])

custom_names = c(sprintf("Current\n(n = %g)\n", num_current), 
                 sprintf("Former\n(n = %g)\n", num_former), 
                 sprintf("Never\n(n = %g)\n", num_never))

## ----------------------------------------------------------

gtheme <- theme(text = element_text(family = "Times New Roman"),
                axis.title.x = element_text(size = 16, margin = unit(c(6, 0, 0, 0), "mm")),
                axis.text.x = element_text(size = 13),
                axis.title.y = element_text(size = 16, margin = unit(c(0, 6, 0, 0), "mm")),
                axis.text.y = element_text(size = 13))

ggplot(maastro_to_plot, aes(x = smoking, y = delta, col = smoking)) +
  
  geom_abline(slope = 0, col = "black", size = 0.25) +
  
  geom_beeswarm(priority = 'density', size = 1/2, alpha = 2/10, cex = 2/3) + 
  
  geom_boxplot(data = maastro_to_plot,
               notch = FALSE, size = 1/3, alpha = 1,
               colour = "grey30", fill = NA, outlier.shape = NA, width = 2/5, notchwidth = 1/5) + 
  
  geom_signif(comparisons = list(c("current", "former"), c("never", "current")), 
              map_signif_level = TRUE, y_position = c(31, 34),
              color = "black", size = 0.2, vjust = 0.5) + 
  
  scale_fill_manual(values = custom_palette) +
  scale_colour_manual(values = custom_palette) +
  ylab('FaceAge - Age') + xlab("Group (smoking)") +
  scale_x_discrete(labels = custom_names) +
  
  scale_y_continuous(breaks = c(-20, -10, -5, 0, 5, 10, 20),
                     limits = c(-20, 37)) + 

  theme_hc() + gtheme + 
  guides(fill = FALSE, col = FALSE)  #+

## ----------------------------------------------------------

# -- STATS --

# PAIR-WISE
never = maastro_to_plot[which(maastro_to_plot$smoking == "never"), ]
former = maastro_to_plot[which(maastro_to_plot$smoking == "former"), ]
current = maastro_to_plot[which(maastro_to_plot$smoking == "current"), ]

pval_df <- data.frame(matrix(ncol = 3, nrow = 3))
names(pval_df) <- c("never", "former", "current")
rownames(pval_df) <- c("never", "former", "current")


stat_test = t.test

pval_df[1, 1] = stat_test(x = never$delta, y = never$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 2] = stat_test(x = never$delta, y = former$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 3] = stat_test(x = never$delta, y = current$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[2, 2] = stat_test(x = former$delta, y = former$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 3] = stat_test(x = former$delta, y = current$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[3, 3] = stat_test(x = current$delta, y = current$delta, paired = FALSE, alternative = "two.sided")$p.value

dat <- matrix(rnorm(9, 3, 1), ncol=3)
names(dat) <- paste("X", 1:3)

pheatmap(pval_df, display_numbers = T, cluster_rows = F, cluster_cols = F,
         show_rownames = TRUE, show_colnames = TRUE, na_col = "white",
         number_color = "black", legend = FALSE,
         number_format = "%g", fontsize_number = 15, fontsize_row = 15, fontsize_col = 15)

