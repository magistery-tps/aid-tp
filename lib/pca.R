# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(dplyr, BiocManager, mdqc, caret)
# ------------------------------------------------------------------------------
#
#
#
#
pca <- function(df) {
  prcomp.robust(df, scale = TRUE, robust="MVE")
}

plot_pca <- function(
  pca_result, 
  groups=NULL, 
  alpha=0.08, 
  title='', 
  ellipse = TRUE, 
  colours=c("green", "red")
) {
  ggbiplot(
    pca_result,
    alpha=alpha, 
    groups=groups,
    ellipse = ellipse
  ) +
    scale_color_manual(
      name=title, 
      values=colours,
      labels=c("No", "Yes")
    ) +
    theme(legend.direction ="horizontal", legend.position = "top")
}