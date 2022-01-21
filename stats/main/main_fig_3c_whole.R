# -----------------
# MAIN PAPER
# FIGURE 3C
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

# The numbers reported here were obtained running the "main_fig_3c_stats.R" script.

library(forestplot)
library(dplyr)

covariates = c("Covariate",
               "FaceAge (decade)",
               "Adj. for age:",
               "Adj. for age and gender:",
               "Adj. for age, gender, and tumour group:")

## --------------------------------------------

## -- WHOLE COHORT --

df_whole <- structure(list(mean  = c(NA, 1.428, 1.156, 1.213, 1.151), 
                           lower = c(NA, 1.351, 1.063, 1.114, 1.056),
                           upper = c(NA, 1.510, 1.258, 1.321, 1.254)),
                      .Names = c("mean", "lower", "upper"), 
                      row.names = c(NA, -5L), 
                      class = "data.frame")

pvals_whole = c("p value", "< 0.001", "< 0.001", "< 0.001", "0.0013")

## --------------------------------------------
## --------------------------------------------

tabletext <- cbind(covariates, pvals_whole)
sel_df = df_whole

font = "Times New Roman"

styles <- fpShapesGp(zero = gpar(col = NA, lwd = .5, lty = 2),
                     # box styling
                     box = list(gpar(fill = NA),
                                gpar(fill = "#359ade", lwd = 1),
                                gpar(fill = "#359ade", lwd = 1),
                                gpar(fill = "#359ade", lwd = 1),
                                gpar(fill = "#359ade", lwd = 1)),
                     lines = gpar(lty = 1, col = "black", lwd = .5),
                     vertices = gpar(lwd = 1, col = "black"))

sel_df %>% 
  forestplot(labeltext = tabletext, 
             fn.ci_norm = c(fpDrawCircleCI,
                            fpDrawCircleCI,
                            fpDrawCircleCI,
                            fpDrawCircleCI,
                            fpDrawCircleCI),
             is.summary = c(rep(TRUE, 1), rep(FALSE, 4)),
             xlog = FALSE,
             xlab = "HR",
             xlim = c(0.5, 2.75),
             ci.vertices = TRUE,
             ci.vertices.height = 0.2,
             boxsize = .35,
             shapes_gp = styles,
             zero = 0.5,
             xticks = c(0.5, 1, 1.5, 2, 2.5),
             
             ## -- vertical line --
             grid = structure(1,  gp = gpar(col = "black", lwd = .5, lty = 2)),
             
             ## -- horizontal line --
             hrzl_lines = list("3" = gpar(col = "black", lwd = .25, lty = 2)),
             
             txt_gp = fpTxtGp(label = list(gpar(fontfamily = font, cex = 0.9)),
                              ticks = gpar(fontfamily = font, cex = 1),
                              xlab  = gpar(fontfamily = font, cex = 1)))
