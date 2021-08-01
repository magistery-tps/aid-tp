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
# Es una librería de funciones comunes desarrolladas a partir de este TP.
import('../lib/common-lib.R')
#
# Funciones especificas para este TP.
import('../scripts/helper_functions.R')
# ==============================================================================
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
# rm(ds_step_2)

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
#  En todos los casos el p-valor < 0.05 y se rechaza normalidad en todas 
#  las variables. Esto coincido con los qqplot donde en todos los casos 
#  no son normales salvo en una nunca variable donde parece tender a 
#  normalidad.
#
#
# 5.4. Test de normalidad muti-variado
mult_shapiro_test(feat(ds_step_4))
#
# Observaciones: 
#  El p-valore < 0.05 por lo tanto se rechaza normalidad multi-variada. 
#  Se corresponde con el resultado del test de 
#  shapiro uni-variado pero no con el qqplot de cada variable. Entiendo que
#  todos las variables se acercan a una normal, pero no o son completamente.
#
#
# 5.5. Test de homocedasticidad uni-variado
uni_levene_test(feat(ds_step_4), ds_step_4$Hazardous)
#
# Observaciones: 
#  - Minimum.Orbit.Intersection: p-valor < 0.05 -> Rechaza homocedasticidad.
#  - Absolute.Magnitude: p-valor < 0.05 -> Rechaza homocedasticidad.
#  - Est.Dia.in.Miles.min.: p-valor > 0.05 -> No Rechaza homocedasticidad.
#  - Perihelion.Distance: p-valor < 0.05 -> Rechaza homocedasticidad.
#  - Inclination: p-valor > 0.05 -> No Rechaza homocedasticidad.
#
#
# 5.6. Test de homocedasticidad multi-variado
multi_boxm_test(feat(ds_step_4), ds_step_4$Hazardous)
#
# Observaciones: 
#  El p-valor < 0.05 por lo tanto se rechaza la hipótesis nula y 
#  podemos decir que las variables tiene no son homocedasticas.
#
#
# 5.7. Correlaciones entre variables
plot_correlations(feat(ds_step_4))
#
# 5.8. Análisis completo
ggpairs(feat(ds_step_4), aes(colour = ds_step_4$Hazardous, alpha = 0.4))
#
#
# 5.9. PCA: Comparación de variables originales con/sin la variable a predecir.
plot_pca_original_variables(feat(ds_step_2))
plot_pca_original_variables(feat(ds_step_3))
#
#
# 5.10. PCA: Con observaciones discriminadas pro clase. Primero quitamos 
# outliers para poder ver con mas claridad el biplot.
ds_without_outliers <- filter_outliers(ds_step_4, max_score=0.52)
plot_robust_pca(ds_without_outliers)
#
#
#
# ------------------------------------------------------------------------------
# 6. Train test split
# ------------------------------------------------------------------------------
c(raw_train_set, raw_test_set) %<-% train_test_split(ds_step_4, train_size=.8)
#
#
#
# ------------------------------------------------------------------------------
# 7. Método SMOTE para balancear el dataset.
# (https://www.analyticsvidhya.com/blog/2021/04/smote-and-best-subset-selection-for-linear-regression-in-r/)
# ------------------------------------------------------------------------------
# balanced_train_set <- smote_balance(raw_train_set, raw_train_set$Hazardous)
#rm(raw_train_set)
balanced_train_set <- raw_train_set
#
#
#
# ------------------------------------------------------------------------------
# 8. Escalamos las variables numéricas(Restamos la media y dividimos por el
#    desvío).
# ------------------------------------------------------------------------------
train_set <- balanced_train_set %>% 
  mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))
test_set  <- raw_test_set %>% 
  mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))

rm(balanced_train_set)
rm(raw_test_set)
#
#
#
# ------------------------------------------------------------------------------
# 9. Entrenamos un modelo LDA
# ------------------------------------------------------------------------------
reg_formula <- formula(Hazardous~.)

lda_model <- lda(reg_formula, train_set)
lda_test_pred  <- predict(lda_model, test_set)

plot_cm(lda_test_pred$class, test_set$Hazardous)
graphics.off()
plot_roc(lda_test_pred$class, test_set$Hazardous)
f_beta_score(lda_test_pred$class, test_set$Hazardous, beta=2)

lda_model$scaling
#
#
#
# ------------------------------------------------------------------------------
# 10. Entrenamos un modelo QDA
# ------------------------------------------------------------------------------
qda_model <- qda(reg_formula, train_set)

qda_test_pred  <- predict(qda_model, test_set)

plot_cm(qda_test_pred$class, test_set$Hazardous)
plot_roc(qda_test_pred$class, test_set$Hazardous)
f_beta_score(qda_test_pred$class, test_set$Hazardous, beta=2)
#
#
#
# ------------------------------------------------------------------------------
# 11. Entrenamos un modelo RDA
# ------------------------------------------------------------------------------
rda_model <- rda(reg_formula, train_set)

rda_test_pred  <- predict(rda_model, test_set)

plot_cm(rda_test_pred$class, test_set$Hazardous)
plot_roc(rda_test_pred$class, test_set$Hazardous)
f_beta_score(rda_test_pred$class, test_set$Hazardous, beta=2)
#
#
#
# ------------------------------------------------------------------------------
# 12.Entrenamos un modelo de regresión logística
# ------------------------------------------------------------------------------
rl_model <- glm(reg_formula, train_set, family=binomial)

rl_test_pred <- predict(rl_model, test_set)

rl_threshold <- 0.4
rl_test_pred_threshold <- ifelse(rl_test_pred >= rl_threshold, 1, 0)

plot_cm(rl_test_pred_threshold, test_set$Hazardous)
plot_roc(rl_test_pred_threshold, test_set$Hazardous)
f_beta_score(rl_test_pred_threshold, test_set$Hazardous, beta=2)
#
#
#
# ------------------------------------------------------------------------------
# 13. Entrenamos un modelo SVM
# ------------------------------------------------------------------------------
svm_model <- svm(reg_formula, train_set, kernel="radial")

svm_test_pred <- predict(svm_model, test_set)
svm_threshold <- 0.5
svm_test_pred_threshold <- ifelse(svm_test_pred >= rl_threshold, 1, 0)

plot_text_cm(svm_test_pred_threshold, test_set$Hazardous)
plot_roc(svm_test_pred_threshold, test_set$Hazardous)
f_beta_score(svm_test_pred_threshold, test_set$Hazardous, beta=2)
#
#
#
# ------------------------------------------------------------------------------
# 14. KMeans Clustering
# ------------------------------------------------------------------------------
#
# 14.1. Primero definimos cuantos grupos utilizar.
# Típica con estimadores de la normal
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
# 14.2. Kmeans
n_clusters <- 2
kmeans_model <- kmeans(scaled_data_1, n_clusters)

km_ds_step_4 <- data.frame(ds_step_4)
km_ds_step_4$kmeans <- kmeans_model$cluster
#
# 14.2. biplot
ds_without_outliers <- filter_outliers(km_ds_step_4, max_score=0.5)
plot_robust_pca(
  ds_without_outliers %>% dplyr::select(-kmeans),
  groups = factor(ds_without_outliers$kmeans),
)
#
#
#
# ------------------------------------------------------------------------------
# 15. Hierarchical Clustering
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
  colours=c("orange","cyan","blue","magenta","yellow","black"),
  labels=c("grupo 1", "grupo 2","grupo 3","grupo 4","grupo 5","grupo 6")
)
