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

# fix blatantly wrong values in BMI
maastro_cur$bmi[which(maastro_cur$bmi > 100)] = NA

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
## ----------------------------------------------------------

# SCATTERPLOT

rsq <- function(x, y) summary(lm(y~x))$r.squared

gtheme <- theme(text = element_text(family = "Times New Roman"),
                axis.title.x = element_text(size = 20),
                axis.title.y = element_text(size = 20),
                axis.text.x = element_text(size = 18, margin = margin(t = 10)),
                axis.text.y = element_text(size = 18, margin = margin(r = 10)),
                legend.position = "none",
                plot.title = element_text(hjust = 0.5, size = 20))

overall_palette <- c("#5DADE2", "#5DADE2")

maastro_to_plot = maastro_cur
maastro_to_plot = maastro_to_plot %>% drop_na(bmi)

sel = maastro_to_plot
sel_rsq = rsq(sel$delta, sel$bmi)
sel_pearson = cor.test(sel$delta, sel$bmi, method = "pearson")

title_str = sprintf("MAASTRO Patients (N=%g)", nrow(maastro_to_plot))
pval_str = sprintf("r = %g (p-val = %g)", sel_pearson$estimate, round(sel_pearson$p.value, 5))

## ----------------------------------------------------------

ggplot(sel, aes(x = bmi, y = delta, size = 1)) + 
  ggtitle(paste(title_str, "\n", pval_str, sep = "")) +
  geom_point(size = 1.25, alpha = 1/2, color = overall_palette[1]) +
  scale_x_continuous(minor_breaks = seq(10, 50, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(11.7, 48.2)) +
  scale_y_continuous(minor_breaks = seq(-20, 35, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(-17.5, 32.8)) +
  theme_minimal() + gtheme +
  guides(fill = FALSE, col = FALSE) +
  ylab('FaceAge - Age\n') + xlab("\nBMI")

## ----------------------------------------------------------

sctpl = ggplot(sel, aes(x = bmi, y = delta, size = 1)) + 
  ggtitle(paste(title_str, "\n", pval_str, sep = "")) +
  geom_point(size = 1.25, alpha = 1/2, color = overall_palette[1]) +
  scale_x_continuous(minor_breaks = seq(10, 50, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(11.7, 48.2)) +
  scale_y_continuous(minor_breaks = seq(-20, 35, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(-17.5, 32.8)) +
  theme_minimal() + gtheme +
  guides(fill = FALSE, col = FALSE) +
  ylab('FaceAge - Age\n') + xlab("\nBMI")

# marginal histogram
ggMarginal(sctpl, type = "densigram",
           col = "black", fill = overall_palette[1], size = 6,
           xparams = list(binwidth = 1.5, size = .15, alpha = 0.9),
           yparams = list(binwidth = 2, size = .15, alpha = 0.9))

## ----------------------------------------------------------

male_palette <- c("#029c8f", "#029c8f")

maastro_to_plot_male = maastro_to_plot[which(maastro_to_plot$sex == "M"), ]

male_rsq = rsq(maastro_to_plot_male$delta, maastro_to_plot_male$bmi)
male_pearson = cor.test(maastro_to_plot_male$delta, maastro_to_plot_male$bmi, method = "pearson")
male_spearman = cor.test(maastro_to_plot_male$delta, maastro_to_plot_male$bmi, method = "spearman")

title_str = sprintf("Men (N=%g)", nrow(maastro_to_plot_male))
pval_str = sprintf("r = %g (p-val = %g)", male_pearson$estimate, round(male_pearson$p.value, 5))


sctpl = ggplot(maastro_to_plot_male, aes(x = bmi, y = delta, size = 1)) + 
  ggtitle(paste(title_str, "\n", pval_str, sep = "")) +
  geom_point(size = 1.25, alpha = 1/2, color = male_palette[1]) +
  scale_x_continuous(minor_breaks = seq(10, 50, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(11.7, 48.2)) +
  scale_y_continuous(minor_breaks = seq(-20, 35, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(-17.5, 32.8)) +
  theme_minimal() + gtheme +
  guides(fill = FALSE, col = FALSE) +
  ylab('FaceAge - Age\n') + xlab("\nBMI")

# marginal histogram
ggMarginal(sctpl, type = "densigram",
           col = "black", fill = male_palette[1], size = 6,
           xparams = list(binwidth = 1.5, size = .15, alpha = 0.9),
           yparams = list(binwidth = 2, size = .15, alpha = 0.9))

## ----------------------------------------------------------

female_palette <- c("#EE965C", "#EE965C")

maastro_to_plot_female = maastro_to_plot[which(maastro_to_plot$sex == "F"), ]

female_rsq = rsq(maastro_to_plot_female$delta, maastro_to_plot_female$bmi)
female_pearson = cor.test(maastro_to_plot_female$delta, maastro_to_plot_female$bmi, method = "pearson")
female_spearman = cor.test(maastro_to_plot_female$delta, maastro_to_plot_female$bmi, method = "spearman")

title_str = sprintf("Women (N=%g)", nrow(maastro_to_plot_female))
pval_str = sprintf("r = %g (p-val = %g)", female_pearson$estimate, round(female_pearson$p.value, 5))


sctpl = ggplot(maastro_to_plot_female, aes(x = bmi, y = delta, size = 1)) + 
  ggtitle(paste(title_str, "\n", pval_str, sep = "")) +
  geom_point(size = 1.25, alpha = 1/2, color = female_palette[1]) +
  scale_x_continuous(minor_breaks = seq(10, 50, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(11.7, 48.2)) +
  scale_y_continuous(minor_breaks = seq(-20, 35, 5),
                     expand = expansion(mult = c(0.05, 0.05)),
                     limits = c(-17.5, 32.8)) +
  theme_minimal() + gtheme +
  guides(fill = FALSE, col = FALSE) +
  ylab('FaceAge - Age\n') + xlab("\nBMI")

# marginal histogram
ggMarginal(sctpl, type = "densigram",
           col = "black", fill = female_palette[1], size = 6,
           xparams = list(binwidth = 1.5, size = .15, alpha = 0.9),
           yparams = list(binwidth = 2, size = .15, alpha = 0.9))

## ----------------------------------------------------------
## ----------------------------------------------------------

# DISTRIBUTION PLOT

bmi_thresh = c(18.5, 24.9, 29.9)

maastro_to_plot$bmi_class = NA
maastro_to_plot$bmi_class[which(maastro_to_plot$bmi >= bmi_thresh[3])] = 4
maastro_to_plot$bmi_class[which(maastro_to_plot$bmi < bmi_thresh[3])] = 3
maastro_to_plot$bmi_class[which(maastro_to_plot$bmi < bmi_thresh[2])] = 2
maastro_to_plot$bmi_class[which(maastro_to_plot$bmi < bmi_thresh[1])] = 1

num_under = nrow(maastro_to_plot[which(maastro_to_plot$bmi_class == 1), ])
num_normal = nrow(maastro_to_plot[which(maastro_to_plot$bmi_class == 2), ])
num_over = nrow(maastro_to_plot[which(maastro_to_plot$bmi_class == 3), ])
num_obese = nrow(maastro_to_plot[which(maastro_to_plot$bmi_class == 4), ])

custom_names = c(sprintf("Underweight\n(< 18.5)\n(n = %g)", num_under),
                 sprintf("Normal Weight\n(18.5 – 24.9\n(n = %g)", num_normal),
                 sprintf("Overweight\n(25.0 – 29.9\n(n = %g)", num_over),
                 sprintf("Obese\n(≥ 30.0)\n(n = %g)", num_obese))

custom_palette = c("#ff9b54", "#ff7f51", "#ce4257", "#720026")

maastro_to_plot$bmi_class = factor(maastro_to_plot$bmi_class)
maastro_to_plot = maastro_to_plot %>% drop_na(bmi_class)

gtheme <- theme(text = element_text(family = "Times New Roman"),
                axis.title.x = element_text(size = 16, margin = unit(c(6, 0, 0, 0), "mm")),
                axis.text.x = element_text(size = 13),
                axis.title.y = element_text(size = 16, margin = unit(c(0, 6, 0, 0), "mm")),
                axis.text.y = element_text(size = 13),)

ggplot(maastro_to_plot, aes(x = bmi_class, y = delta, fill = bmi_class, col = bmi_class)) +
  geom_abline(slope = 0, col = "black", size = 0.25) +
  
  geom_beeswarm(priority = 'density', size = 1/2, alpha = 2/10, cex = 2/3) + 
  
  geom_boxplot(aes(x = as.numeric(as.factor(bmi_class)), y = delta, group = bmi_class),
               notch = FALSE, size = 1/3, alpha = 1, colour = "grey30",
               fill = NA, outlier.shape = NA, width = 2/5, notchwidth = 1/5) +
  
  scale_fill_manual(values = custom_palette) +
  scale_colour_manual(values = custom_palette) +
  scale_x_discrete(labels = custom_names) + 
  ylab('FaceAge - Chrono Age') + xlab("Group (BMI)") +
  scale_y_continuous(breaks = c(-20, -10, -5, 0, 5, 10, 20),
                     limits = c(-20, 33)) + 
  theme_hc() + gtheme + 
  guides(fill = FALSE, col = FALSE)

## ----------------------------------------------------------

# STATS

# ONE-WAY ANOVA

# KRUSKAL-WALLIS (non-param ANOVA)
kruskal.test(delta ~ bmi_class, data = maastro_to_plot)

# PAIR-WISE
under = maastro_to_plot[which(maastro_to_plot$bmi_class == 1), ]
normal = maastro_to_plot[which(maastro_to_plot$bmi_class == 2), ]
over = maastro_to_plot[which(maastro_to_plot$bmi_class == 3), ]
obese = maastro_to_plot[which(maastro_to_plot$bmi_class == 4), ]

pval_df <- data.frame(matrix(ncol = 4, nrow = 4))
names(pval_df) <- c("Underweight", "Normal Weight", "Overweight", "Obese")
rownames(pval_df) <- c("Underweight", "Normal Weight", "Overweight", "Obese")

pval_df[1, 1] = wilcox.test(x = under$delta, y = under$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 2] = wilcox.test(x = under$delta, y = normal$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 3] = wilcox.test(x = under$delta, y = over$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[1, 4] = wilcox.test(x = under$delta, y = obese$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[2, 2] = wilcox.test(x = normal$delta, y = normal$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 3] = wilcox.test(x = normal$delta, y = over$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[2, 4] = wilcox.test(x = normal$delta, y = obese$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[3, 3] = wilcox.test(x = over$delta, y = over$delta, paired = FALSE, alternative = "two.sided")$p.value
pval_df[3, 4] = wilcox.test(x = over$delta, y = obese$delta, paired = FALSE, alternative = "two.sided")$p.value

pval_df[4, 4] = wilcox.test(x = obese$delta, y = obese$delta, paired = FALSE, alternative = "two.sided")$p.value

dat <- matrix(rnorm(9, 3, 1), ncol=3)
names(dat) <- paste("X", 1:3)

pheatmap(pval_df, display_numbers = T, cluster_rows = F, cluster_cols = F,
         show_rownames = TRUE, show_colnames = TRUE, na_col = "white",
         number_color = "black", legend = FALSE,
         number_format = "%g", fontsize_number = 15, fontsize_row = 15, fontsize_col = 15)
