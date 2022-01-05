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

## -- GU COHORT --

df_gu <- structure(list(mean  = c(NA, 2.138, 1.387, 1.311), 
                        lower = c(NA, 1.768, 1.068, 1.004),
                        upper = c(NA, 2.584, 1.801, 1.712)),
                   .Names = c("mean", "lower", "upper"), 
                   row.names = c(NA, -4L), 
                   class = "data.frame")

pvals_gu = c("p value", "< 0.001", "0.0143", "0.0464")

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

## -- LUNG COHORT --

df_breast <- structure(list(mean  = c(NA, 1.854, 1.456, 1.453), 
                            lower = c(NA, 1.505, 1.073, 1.071),
                            upper = c(NA, 2.284, 1.975, 1.972)),
                       .Names = c("mean", "lower", "upper"), 
                       row.names = c(NA, -4L), 
                       class = "data.frame")

pvals_breast = c("p value", "< 0.001", "0.0159", "0.0165")

## --------------------------------------------
## --------------------------------------------

cohort_name = "breast"
tabletext <- cbind(covariates, pvals_breast)
sel_df = df_breast

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
