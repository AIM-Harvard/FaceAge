# -----------------
# EXTENDED DATA
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

# MAASTRO cohort
maastro_base_path = "/mnt/data1/FaceAge/stats"
maastro_file_name = "stats_maastro_cur_qa_all.csv"
maastro_file_path = file.path(maastro_base_path, maastro_file_name)

maastro_cur = read.csv(file = maastro_file_path, stringsAsFactors = FALSE)

# fix empty in $smoking
maastro_cur$smoking[which(maastro_cur$smoking == "")] = NA
maastro_cur$smoking[which(maastro_cur$smoking == "passive")] = NA

# exclude DCIS patients
maastro_cur = maastro_cur[-which(maastro_cur$site == "MAM" & maastro_cur$exclude == 1), ]

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


# results per decade
maastro_cur$dec_faceage = NA
maastro_cur$dec_faceage = 0.1 * maastro_cur$faceage

maastro_cur$dec_chrono_age = NA
maastro_cur$dec_chrono_age = 0.1 * maastro_cur$chrono_age

maastro_cur$delta = (maastro_cur$faceage - maastro_cur$chrono_age)

maastro_breast = maastro_cur[which(maastro_cur$site == 'MAM'), ]
maastro_gi = maastro_cur[which(maastro_cur$site == 'GE'), ]
maastro_gu = maastro_cur[which(maastro_cur$site == 'URO'), ]
maastro_lung = maastro_cur[which(maastro_cur$site == 'LON'), ]
maastro_hn = maastro_cur[which(maastro_cur$site == 'KNO'), ]
maastro_oth = maastro_cur[which(maastro_cur$site == 'OTH'), ]

## ----------------------------------------------------------

## -- BOXPLOTS --

maastro_to_plot = maastro_cur
maastro_to_plot = maastro_to_plot %>% drop_na(smoking)

never_delta = median(maastro_to_plot$delta[which(maastro_to_plot$smoking == "never")])

num_never = nrow(maastro_to_plot[which(maastro_to_plot$smoking == "never"), ])
num_current = nrow(maastro_to_plot[which(maastro_to_plot$smoking == "current"), ])
num_former = nrow(maastro_to_plot[which(maastro_to_plot$smoking == "former"), ])

custom_palette = c("#e63946", "#f8961e", "#52b788")

sites_key = c("MAM", "URO", "GE", "LON", "KNO", "OTH")
sites_names = c("Breast", "GU", "GI", "Lung", "H&N", "Other")

for(idx in 1:length(sites_key)){
  name = sites_key[idx]
  n_pat = nrow(maastro_to_plot[which(maastro_to_plot$site == name), ])
  sites_names[idx] = paste(sites_names[idx], sprintf("\n(n=%g)", n_pat), sep = "")
}

gtheme <- theme(text = element_text(family = "Times New Roman"),
                axis.title.x = element_text(size = 16, margin = unit(c(6, 0, 0, 0), "mm")),
                axis.text.x = element_text(size = 14),
                axis.title.y = element_text(size = 16, margin = unit(c(0, 6, 0, 0), "mm")),
                axis.text.y = element_text(size = 14))


ggplot(maastro_to_plot, aes(x = factor(site, levels = c("MAM", "URO", "GE", "LON", "KNO", "OTH"), ordered = TRUE),
                            y = delta, col = factor(smoking))) +
  
  geom_abline(slope = 0, col = "black", size = 0.25) +
  
  geom_boxplot(data = maastro_to_plot,
               notch = FALSE, size = 1/3, alpha = 1,
               fill = NA, outlier.shape = NA, width = 4/5, notchwidth = 1/5) +
  
  geom_beeswarm(dodge.width = 4/5, priority = 'density', size = 1/2, alpha = 4/10, cex = 2/5) +
  
  ylab('FaceAge - Age') + xlab("Site") +
  
  scale_colour_manual(values = custom_palette) +
  
  scale_x_discrete(labels = sites_names) +
  
  scale_y_continuous(breaks = c(-20, -10, -5, 0, 5, 10, 20),
                     limits = c(-20, 33)) + 
  
  theme_hc() + gtheme +
  
  guides(fill = FALSE, col = FALSE)

## ----------------------------------------------------------

## -- STATS --

sel_cohort = maastro_to_plot[which(maastro_to_plot$site == "MAM"), ]
sel_cohort_name = "breast"


# PAIR-WISE
never = sel_cohort[which(sel_cohort$smoking == "never"), ]
former = sel_cohort[which(sel_cohort$smoking == "former"), ]
current = sel_cohort[which(sel_cohort$smoking == "current"), ]

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
