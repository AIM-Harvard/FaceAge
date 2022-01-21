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
               "Adj. for age and gender:")

## --------------------------------------------

## -- BREAST COHORT --

df_breast <- structure(list(mean  = c(NA, 1.854, 1.456, 1.453), 
                            lower = c(NA, 1.505, 1.073, 1.071),
                            upper = c(NA, 2.284, 1.975, 1.972)),
                       .Names = c("mean", "lower", "upper"), 
                       row.names = c(NA, -4L), 
                       class = "data.frame")

pvals_breast = c("p value", "< 0.001", "0.0159", "0.0165")


## --------------------------------------------

## -- GI COHORT --

df_breast <- structure(list(mean  = c(NA, 1.854, 1.456, 1.453), 
                            lower = c(NA, 1.505, 1.073, 1.071),
                            upper = c(NA, 2.284, 1.975, 1.972)),
                       .Names = c("mean", "lower", "upper"), 
                       row.names = c(NA, -4L), 
                       class = "data.frame")

pvals_breast = c("p value", "< 0.001", "0.0159", "0.0165")


## --------------------------------------------

## -- GU COHORT --

df_gu <- structure(list(mean  = c(NA, 2.138, 1.387, 1.311), 
                        lower = c(NA, 1.768, 1.068, 1.004),
                        upper = c(NA, 2.584, 1.801, 1.712)),
                   .Names = c("mean", "lower", "upper"), 
                   row.names = c(NA, -4L), 
                   class = "data.frame")

pvals_gu = c("p value", "< 0.001", "0.0143", "0.0464")

## --------------------------------------------

## -- LUNG COHORT --

df_lung <- structure(list(mean  = c(NA, 1.243, 1.079, 1.123), 
                          lower = c(NA, 1.108, 0.932, 0.969),
                          upper = c(NA, 1.395, 1.249, 1.303)),
                     .Names = c("mean", "lower", "upper"), 
                     row.names = c(NA, -4L), 
                     class = "data.frame")

pvals_lung = c("p value", "< 0.001", "0.3085", "0.1240")

## --------------------------------------------
## --------------------------------------------

tabletext <- cbind(covariates, pvals_lung)
sel_df = df_lung

font = "Times New Roman"

# forestplot styling
styles <- fpShapesGp(zero = gpar(col = NA, lwd = .5, lty = 2),
                     # box styling
                     box = list(gpar(fill = NA),
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
