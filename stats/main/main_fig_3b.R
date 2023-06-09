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

# The numbers reported here were obtained running the "main_fig_3b_stats.R" script.


library(forestplot)
library(dplyr)

covariates = c("Covariate",
               "FaceAge \u2264 65 (ref.):",
               "65 < FaceAge \u2264 75:",
               "75 < FaceAge \u2264 85:",
               "FaceAge > 85:")

## --------------------------------------------

## -- UVA --

df_uva <- structure(list(mean  = c(NA, 1, 1.33300, 2.05257, 2.85671), 
                         lower = c(NA, 1, 1.16283, 1.78835, 2.30586),
                         upper = c(NA, 1, 1.52806, 2.35583, 3.53916)),
                    .Names = c("mean", "lower", "upper"), 
                    row.names = c(NA, -5L), 
                    class = "data.frame")

hr_uva = c("HR (95% CI)",
            "-",
            "1.333 (1.163-1.528)",
            "2.053 (1.789-2.306)",
            "2.857 (2.356-3.539)")

pvals_uva = c("p value",
              " - ",
              "< 0.001",
              "< 0.001",
              "< 0.001")


## --------------------------------------------

## -- MVA --

df_mva <- structure(list(mean  = c(NA, 1, 0.98354, 1.25260, 1.46775), 
                         lower = c(NA, 1, 0.84122, 1.04219, 1.11673),
                         upper = c(NA, 1, 1.14994, 1.5055, 1.92912)),
                    .Names = c("mean", "lower", "upper"), 
                    row.names = c(NA, -5L), 
                    class = "data.frame")

hr_mva = c("HR (95% CI)",
           "-",
           "0.984 (0.841-1.150)",
           "1.253 (1.042-1.506)",
           "1.468 (1.117-1.929)")

pvals_mva = c("p value",
              " - ",
              "0.83516",
              "0.01638",
              "0.00593")

## --------------------------------------------
## --------------------------------------------

cohort_name = "uva"
tabletext <- cbind(covariates, hr_uva, pvals_uva)
sel_df = df_uva

font = "Times New Roman"

# forestplot styling
styles <- fpShapesGp(zero = gpar(col = NA, lwd = .5, lty = 2),
                     # box styling
                     box = list(gpar(fill = NA),
                                gpar(fill = "#1f77b4", lwd = 1),
                                gpar(fill = "#ff7f0e", lwd = 1),
                                gpar(fill = "#2ca02c", lwd = 1),
                                gpar(fill = "#d62728", lwd = 1)),
                     lines = gpar(lty = 1, col = "black", lwd = .5),
                     vertices = gpar(lwd = 1, col = "black"))

sel_df %>% 
  forestplot(labeltext = tabletext, 
             fn.ci_norm = c(fpDrawCircleCI,
                            fpDrawCircleCI,
                            fpDrawCircleCI,
                            fpDrawCircleCI,
                            fpDrawCircleCI),
             is.summary = c(TRUE, rep(FALSE, 4)),
             graph.pos = 2,
             lineheight = unit(20,"mm"),
             graphwidth = unit(100, 'mm'),
             xlog = FALSE,
             xlab = "HR",
             ci.vertices = TRUE,
             ci.vertices.height = 0.2,
             boxsize = .35,
             shapes_gp = styles,
             zero = 0.5,
             xticks = c(0.5, 1, 2, 3, 4),
             
             ## -- vertical line --
             grid = structure(1,  gp = gpar(col = "black", lwd = .5, lty = 2)),
             
             ## -- horizontal line --
             hrzl_lines = list("3" = gpar(col = "black", lwd = .25, lty = 2)),
             
             txt_gp = fpTxtGp(label = list(gpar(fontfamily = font, cex = 0.9)),
                              ticks = gpar(fontfamily = font, cex = 1),
                              xlab  = gpar(fontfamily = font, cex = 1)))
