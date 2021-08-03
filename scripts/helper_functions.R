# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(this.path, dplyr)
setwd(this.path::this.dir())
source('../lib/import.R')
#
import('../lib/pca.R')
import('../lib/importance.R')
# ------------------------------------------------------------------------------

#
# Devuelve únicamente los features del dataset.
#
feat <- function(df) df %>% dplyr::select(-Hazardous)

#
# Devuelve únicamente la variable target.
#
target <- function(df) df %>% pull(Hazardous)

# 
# Filtra las observaciones que sean ourliers multi-variados mediante el 
# argumento max_score. También permite visualizar un boxplot de la variable
# score, para ver donde se puede poner el punto de corte.
#
filter_outliers <- function(df, max_score, plot_score_boxplot=TRUE) {
  tmp_df <- data.frame(df)
  tmp_df$score <- isolation_forest_scores(feat(tmp_df), plot=plot_score_boxplot)
  
  ds_without_outliers <- filter_by_score(tmp_df, max_score=max_score)
  
  rm(tmp_df)
  
  ds_without_outliers
}
#
# Gráfica dos componentes principales(Las de mayor varianza)usando el método
# robusto MVE para evitar outliers multi-variados.
#
plot_robust_pca <- function(
  df,
  target_col     = "Hazardous",
  title          = "Hazardous Asteroids",
  alpha          = 0.08,
  obs.scale      = 2,
  var.scale      = 0.5,
  varname.adjust = 1.2,
  varname.size   = 3.8,
  colours        = c("green", "red"),
  labels         = c("No", "Yes"),
  groups         = NULL
) {
  pca_result <- pca(feat(df), scale = TRUE, robust = "MVE")
  
  if(is.null(groups)) {
    groups <- factor(df[[target_col]])
  }

  result <- plot_pca(
    pca_result,
    alpha = alpha,
    obs.scale = obs.scale,
    var.scale = var.scale,
    varname.adjust = varname.adjust,
    varname.size = varname.size,
    colours = colours,
    labels = labels,
    title=title,
    groups=groups
  )
  
  rm(pca_result)
  
  result
}