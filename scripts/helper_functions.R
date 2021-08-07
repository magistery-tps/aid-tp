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

target_to_num <- function(df) {
  df %>% mutate(Hazardous = case_when(Hazardous %in% c('True') ~ 1, TRUE ~ 0))
}

target_to_str <- function(df) {
  df %>% mutate(Hazardous = ifelse(Hazardous == 1, 'TRUE', 'FALSE'))
}


# 
# Filtra las observaciones que sean ourliers multi-variados mediante el 
# argumento max_score. También permite visualizar un boxplot de la variable
# score, para ver donde se puede poner el punto de corte.
#
filter_outliers_m1 <- function(df, max_score, plot_score_boxplot=TRUE) {
  tmp_df <- data.frame(df)
  tmp_df$score <- isolation_forest_scores(feat(tmp_df), plot=plot_score_boxplot)
  
  ds_without_outliers <- filter_by_score(tmp_df, max_score=max_score)

  ds_without_outliers_percent <- nrow(ds_without_outliers) / nrow(df)
  print(paste('Outliers:', round(1 - ds_without_outliers_percent, 2) * 100, '%'))
  print(paste('Dataset without outliers:', round(ds_without_outliers_percent, 2) * 100, '%'))
  
  rm(tmp_df)

  ds_without_outliers
}


filter_outliers_m2 <- function(df) {
  outliers_index <- check_outliers(df)
  
  ds_without_outliers <- df[!outliers_index,]

  ds_without_outliers_percent <- nrow(ds_without_outliers) / nrow(df)
  print(paste('Outliers:', round(1 - ds_without_outliers_percent, 2) * 100, '%'))
  print(paste('Dataset without outliers:', round(ds_without_outliers_percent, 2) * 100, '%'))

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
  groups         = NULL,
  seed           = 1
) {
  set.seed(seed)
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

clusteging_pca_plot <- function(df, alpha = 0.2) {
  # km_result <- filter_outliers_m1(km_result, max_score=0.5)
  km_result <- filter_outliers_m2(df)
  
  plot_robust_pca(
    alpha = alpha,
    km_result %>% dplyr::select(-cluster),
    groups = factor(km_result$cluster),
    colours=c("orange","cyan","blue","magenta","yellow","black"),
    labels=c("Grupo 1", "Grupo 2","Grupo 3","Grupo 4","Grupo 5","Grupo 6")
  )
}
