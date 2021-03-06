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
#
# Devuelve únicamente los features del dataset.
#
feat <- function(df) features(df, 'Hazardous')

#
# Devuelve únicamente la variable target o label.
#
target <- function(df) label(df, 'Hazardous')

target_to_num <- function(df) {
  df %>% mutate(Hazardous = ifelse(tolower(Hazardous) == "true", 1, 0))
}

target_to_str <- function(df) {
  df %>% mutate(Hazardous = ifelse(Hazardous == 1, 'true', 'false'))
}


# 
# Filtra las observaciones que sean ourliers multi-variados mediante el 
# argumento max_score. También permite visualizar un boxplot de la variable
# score, para ver donde se puede poner el punto de corte.
#
filter_outliers_m1 <- function(df, max_score, plot_score_boxplot=TRUE, seed=NULL) {
  if(!is.null(seed)) {
    set.seed(seed)
  }
  
  tmp_df <- data.frame(df)
  tmp_df$score <- isolation_forest_scores(feat(tmp_df), plot=plot_score_boxplot)
  
  ds_without_outliers <- filter_by_score(tmp_df, max_score=max_score)

  ds_without_outliers_percent <- nrow(ds_without_outliers) / nrow(df)
  print(paste('Outliers:', round(1 - ds_without_outliers_percent, 2) * 100, '%'))
  print(paste('Dataset without outliers:', round(ds_without_outliers_percent, 2) * 100, '%'))
  
  rm(tmp_df)

  ds_without_outliers
}

filter_outliers_m2 <- function(df, seed=NULL) {
  if(!is.null(seed)) {
    set.seed(seed)
  }
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
  title          = "Asteroides Peligrosos",
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
  if(!is.null(seed)) {
    set.seed(seed)
  }
  pca_result <- pca(feat(df), scale = TRUE, robust = "MVE")
  
  if(is.null(groups)) {
    groups <- factor(df[[target_col]])
  }
  
  print(pca_result)

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

clusteging_pca_plot <- function(
  df,
  filter_outliers = FALSE,
  alpha           = 0.1,
  obs.scale       = 1,
  var.scale       = 3,
  varname.adjust  = 1.2,
  varname.size    = 3.5,
  seed            = 1,
  labels         = c("Grupo 1", "Grupo 2","Grupo 3","Grupo 4","Grupo 5","Grupo 6"),
  colours        = c("yellow","blue", "cyan", "magenta","yellow","black")
) {
  if(filter_outliers) {
    # km_result <- filter_outliers_m1(km_result, max_score=0.5)
    data <- filter_outliers_m2(df, seed)
  } else {
    data <- df
  }
  
  plot_robust_pca(
    data %>% dplyr::select(-cluster),
    obs.scale      = obs.scale,
    var.scale      = var.scale,
    varname.adjust = varname.adjust,
    varname.size   = varname.size,
    seed           = seed,
    alpha          = alpha,
    groups         = factor(data$cluster),
    colours        = colours,
    labels         = labels
  )
}


plot_hazardous_proportion <- function(df) {
  data <- df %>% 
    dplyr::mutate(
      Peligroso = ifelse(Hazardous == 1, 'Si', 'No'),
    ) %>%
    dplyr::group_by(Peligroso) %>%
    tally() %>%
    dplyr::mutate(Cantidad = n)

  ggplot(data, aes(fill=Peligroso, y=Cantidad, x=Peligroso)) + 
    geom_bar(position="stack", stat="identity")
}


features_mean_by_group <-function(df) {
  df %>% 
    dplyr::mutate(
      Grupo = ifelse(cluster == 1, 'Grupo 1', ifelse(cluster == 2, 'Grupo 2', 'Grupo 3'))
    ) %>%
    dplyr::group_by(Grupo) %>%
    dplyr::summarise(
      Minimum.Orbit.Intersection = mean(Minimum.Orbit.Intersection),
      Absolute.Magnitude = mean(Absolute.Magnitude),
      Est.Dia.in.Miles.min. = mean(Est.Dia.in.Miles.min.),
      Perihelion.Distance = mean(Perihelion.Distance),
      Inclination = mean(Inclination)
    )
}

plot_minimum_orbit_intersection_by_group <- function(df) {
  ggplot(df, aes(fill=Grupo, y=Minimum.Orbit.Intersection, x=Grupo)) + 
    geom_bar(position="stack", stat="identity") +
    theme(legend.position = "none")
}

plot_absolute_magnitude_by_group <- function(df) {
  ggplot(df, aes(fill=Grupo, y=Absolute.Magnitude, x=Grupo)) + 
    geom_bar(position="stack", stat="identity") +
    theme(legend.position = "none")
}

plot_est_dia_in_miles_min_by_group <- function(df) {
  ggplot(df, aes(fill=Grupo, y=Est.Dia.in.Miles.min., x=Grupo)) + 
    geom_bar(position="stack", stat="identity") +
    theme(legend.position = "none")
}

plot_Perihelion.Distance_by_group <- function(df) {
  ggplot(df, aes(fill=Grupo, y=Perihelion.Distance, x=Grupo)) + 
    geom_bar(position="stack", stat="identity") +
    theme(legend.position = "none")
}

plot_inclination_by_group <- function(df){
  ggplot(df, aes(fill=Grupo, y=Inclination, x=Grupo)) + 
    geom_bar(position="stack", stat="identity") +
    theme(legend.position = "none")
}


plot_groups_by_hazardous <- function(df) {
  data <- df %>% 
    dplyr::mutate(
      Peligroso = ifelse(Hazardous == 1, 'Si', 'No'),
      Grupo = ifelse(cluster == 1, 'Grupo 1', ifelse(cluster == 2, 'Grupo 2', 'Grupo 3'))
    ) %>%
    dplyr::group_by(Grupo, Peligroso) %>%
    tally() %>%
    dplyr::mutate(Cantidad = n)
  
  ggplot(data, aes(fill=Peligroso, y=Cantidad, x=Grupo)) + 
    geom_bar(position="stack", stat="identity")
}

biplot_fn_fp <- function(data, pred) {
  observation_with_result_type <- observations_cm(
    data,
    pred,
    target_col = 'Hazardous'
  )
  
  observation_cl <- observation_with_result_type %>% 
    dplyr::mutate(cluster = result_type) %>%
    dplyr::select(c(-pred, -true, -result_type))
  
  clusteging_pca_plot(
    observation_cl, 
    alpha     = 1,
    labels    = c("FP", "FN", "TN", "TP"),
    colours   = c("red","green", "white", "grey")
  )
}

