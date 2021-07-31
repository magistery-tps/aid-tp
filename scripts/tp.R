options(warn=-1)
#
#
# ==============================================================================
# Importamos dependencias
# ==============================================================================
#
#
# ===> IMPORTANTE: Instalar la librería PACMAN es requisito!!! <=====
#
# ===> install.packages('pacman')
#
#
library(pacman)
p_load(this.path, dplyr)
setwd(this.path::this.dir())
source('../lib/import.R')
#
# Contiene todas las librerías y funciones comunes usadas en este TP.
import('../lib/common-lib.R')
# ==============================================================================
#
#
#
#
#
#
# ==============================================================================
# Funciones Helper
# ==============================================================================
#
# Devuelve únicamente los features del dataset.
#
feat <- function(df) df %>% dplyr::select(-Hazardous)
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
# ==============================================================================
#
#
#
#
#
#
# ==============================================================================
# Inicio del análisis
# ==============================================================================
set.seed(1)
#
#
#
#
# ------------------------------------------------------------------------------
# 1. Cargamos el dataset.
# ------------------------------------------------------------------------------
# Excluimos las columnas no numéricas que no nos interesan para este análisis.
excluded_columns <- c(
  'Neo.Reference.ID',
  'Name',
  'Close.Approach.Date',
  'Epoch.Date.Close.Approach',
  'Orbit.ID',
  'Orbit.Determination.Date',
  'Orbiting.Body',
  'Est.Dia.in.Feet.min.',
  'Est.Dia.in.Feet.max.',
  'Est.Dia.in.M.min.',
  'Est.Dia.in.M.max.',
  'Est.Dia.in.KM.min.',
  'Est.Dia.in.KM.max.',
  'Equinox',
  'Orbit.Uncertainity'
)

#
# Cargamos NASA dataset:
# (https://www.kaggle.com/shrutimehta/nasa-asteroids-classification)
#
ds_step_1 <- loadcsv('../datasets/nasa.csv') %>% 
  dplyr::select(-excluded_columns) %>%
  na.omit

str(ds_step_1)
#
#
#
#
# ------------------------------------------------------------------------------
# 2. Eliminamos las columnas que están altamente co-relacionadas
# ------------------------------------------------------------------------------
high_correlated_columns <- find_high_correlated_columns(
  feat(ds_step_1), 
  cutoff=0.8
)
length(high_correlated_columns)
length(ds_step_1)

ds_step_2 <- ds_step_1 %>% dplyr::select(-high_correlated_columns[-1])
rm(ds_step_1)

length(ds_step_2)
#
#
#
#
# ------------------------------------------------------------------------------
# 3. Tomamos las columnas que mejor separan las clases.
# ------------------------------------------------------------------------------
result <- features_importance(ds_step_2, target = 'Hazardous')
result

plot_features_importance(result)

n_best_features = 5
# n_best_features = 15

best_features <- top_acc_features(result, top=n_best_features)
best_features
length(best_features)

ds_step_3 <- ds_step_2 %>% dplyr::select(c(best_features, c(Hazardous)))
rm(ds_step_2)

str(ds_step_3)
#
#
#
#
# ------------------------------------------------------------------------------
# 4. Transformamos las clases a números
# ------------------------------------------------------------------------------
ds_step_4 <- ds_step_3 %>% 
  mutate(Hazardous = case_when(Hazardous %in% c('True') ~ 1, TRUE ~ 0))

str(ds_step_4)
#
#
#
#
# ------------------------------------------------------------------------------
# 5. Análisis Exploratorio
# ------------------------------------------------------------------------------
#
#
# 5.1. Boxplot comparativos
coparative_boxplot(feat(ds_step_4), to_col=n_best_features)
#
#
# 5.2. Histogramas y densidad
comparative_histplot(feat(ds_step_4), to_col=n_best_features)
#
# 5.3. Analizamos gráfico de normalidad univariado
comparative_qqplot(feat(ds_step_4), to_col=n_best_features)
#
# Observaciones: 
#    Al parecer una sola variable parece ser normal.
#
# 5.3. Test de normalidad uni-variado
uni_shapiro_test(feat(ds_step_4))
#
# Observaciones: 
#    El resultado de los test uni-variados no es consistente ya que el qqplot 
#    me muestra que lo mas probable es que una sola variable sea normal pero 
#    para shapiro todas son normales.
#
#
# 5.4. Test de normalidad muti-variado
mult_shapiro_test(feat(ds_step_4))
#
# Observaciones: 
#    El p-valore < 0.05 por lo tanto no se rechaza normalidad y tenemos 
#    normalidad multi-variada. Se corresponde con el resultado del test de 
#    shapiro uni-variado pero no con el qqplot de cada variable. Entiendo que
#    todos las variables se acercan a una normal, pero no o son completamente.
#
#
# 5.4. Correlaciones entre variables
plot_correlations(feat(ds_step_4))
#
# 5.5. Análisis completo
ggpairs(feat(ds_step_4), aes(colour = ds_step_3$Hazardous, alpha = 0.4))
#
#
# 5.6. PCA: Comparación de variables originales con/sin la variable a predecir.
plot_pca_original_variables(feat(ds_step_4))
plot_pca_original_variables(ds_step_4)
#
#
# 5.6. PCA: Con observaciones discriminadas pro clase. Primero quitamos 
# outliers para poder ver con mas claridad el biplot.
ds_without_outliers <- filter_outliers(ds_step_4, max_score=0.52)
plot_robust_pca(ds_without_outliers)
#
#
#
# ------------------------------------------------------------------------------
# 6. Train test split
# ------------------------------------------------------------------------------
c(train_set, test_set) %<-% train_test_split(ds_step_4, train_size=.8)
nrow(train_set)
nrow(test_set)
#
#
#
# ------------------------------------------------------------------------------
# 7. Escalamos las variables numéricas(Restamos la media y dividimos por el
#    desvío).
# ------------------------------------------------------------------------------
scaled_train_set <- train_set %>% 
  mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))
scaled_test_set  <- test_set %>% 
  mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))

rm(train_set)
rm(test_set)
#
#
#
# ------------------------------------------------------------------------------
# 8. Entrenamos un modelo LDA
# ------------------------------------------------------------------------------
reg_formula <- formula(Hazardous~.)

lda_model <- lda(reg_formula, scaled_train_set)
lda_test_pred  <- predict(lda_model, scaled_test_set)

plot_cm(lda_test_pred$class, scaled_test_set$Hazardous)
graphics.off()
plot_roc(lda_test_pred$class, scaled_test_set$Hazardous)

lda_model$scaling
#
#
#
# ------------------------------------------------------------------------------
# 9. Entrenamos un modelo QDA
# ------------------------------------------------------------------------------
qda_model <- qda(reg_formula, scaled_train_set)

qda_test_pred  <- predict(qda_model, scaled_test_set)

plot_cm(qda_test_pred$class, scaled_test_set$Hazardous)
plot_roc(qda_test_pred$class, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 10. Entrenamos un modelo RDA
# ------------------------------------------------------------------------------
rda_model <- rda(reg_formula, scaled_train_set)

rda_test_pred  <- predict(rda_model, scaled_test_set)

plot_cm(rda_test_pred$class, scaled_test_set$Hazardous)
plot_roc(rda_test_pred$class, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 11.Entrenamos un modelo de Regresion logistica
# ------------------------------------------------------------------------------
rl_model <- glm(reg_formula, scaled_train_set, family=binomial)

rl_test_pred <- predict(rl_model, scaled_test_set)

rl_threshold <- 0.4
rl_test_pred_threshold <- ifelse(rl_test_pred >= rl_threshold, 1, 0)

plot_cm(rl_test_pred_threshold, scaled_test_set$Hazardous)
plot_roc(rl_test_pred_threshold, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 12. Entrenamos un modelo SVM
# ------------------------------------------------------------------------------
svm_model <- svm(reg_formula, scaled_train_set, kernel="radial")

svm_test_pred <- predict(svm_model, scaled_test_set)
svm_threshold <- 0.5
svm_test_pred_threshold <- ifelse(svm_test_pred >= rl_threshold, 1, 0)

plot_text_cm(svm_test_pred_threshold, scaled_test_set$Hazardous)
plot_roc(svm_test_pred_threshold, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 13. KMeans Clustering
# ------------------------------------------------------------------------------
#
# 13.1. Primero definimos cuantos grupos utilizar.
# Tipica con estimadores de la normal
scaled_data_1 <- ds_step_4 %>%
  dplyr::select(-Hazardous) %>%
  mutate(~(scale(.) %>% as.vector))
#
# Escalamiento diferente de la tipica normal.
scaled_data_2 <- apply(
  ds_step_4 %>% dplyr::select(-Hazardous), 
  2, 
  function(x) { (x - min(x)) / (max(x) - min(x))}
)
#
clustering_metrics_plot(scaled_data_1)
clustering_metrics_plot(scaled_data_2)
#
# 13.2. Kmeans
n_clusters <- 2
kmeans_model <- kmeans(scaled_data_1, n_clusters)

km_ds_step_4 <- data.frame(ds_step_4)
km_ds_step_4$kmeans <- kmeans_model$cluster
#
# 13.2. biplot
ds_without_outliers <- filter_outliers(km_ds_step_4, max_score=0.5)
plot_robust_pca(
  ds_without_outliers %>% dplyr::select(-kmeans),
  groups = factor(ds_without_outliers$kmeans),
)
#
#
#
# ------------------------------------------------------------------------------
# 14. Hierarchical Clustering
# ------------------------------------------------------------------------------
n_clusters <- 2

# Matriz de distancias euclídeas 
mat_dist <- dist(x = ds_step_4, method = "euclidean") 

# Dendrogramas (según el tipo de segmentación jerárquica aplicada)  
hc_complete <- hclust(d = mat_dist, method = "complete") 
hc_average  <- hclust(d = mat_dist, method = "average")
hc_single   <- hclust(d = mat_dist, method = "single")
hc_ward     <- hclust(d = mat_dist, method = "ward.D2")

# Calculo del coeficiente de correlación cofenetico
cor(x = mat_dist, cophenetic(hc_complete))
cor(x = mat_dist, cophenetic(hc_average))
cor(x = mat_dist, cophenetic(hc_single))
cor(x = mat_dist, cophenetic(hc_ward))

# Construcción de un dendograma usando los resultados de la técnica de Ward
graphics.off()
plot(hc_ward )
rect.hclust(hc_ward, k=cantidad_clusters, border="red")

hc_ds <- data.frame(ds_step_4)
hc_ds$her_ward <- cutree(hc_ward, k=n_clusters)

ds_without_outliers <- filter_outliers(hc_ds, max_score=0.57)
plot_robust_pca(
  ds_without_outliers %>% dplyr::select(-her_ward),
  groups = factor(ds_without_outliers$her_ward),
)
