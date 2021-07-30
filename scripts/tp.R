# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
# install.packages('pacman')
library(pacman)
p_load(this.path, dplyr)
setwd(this.path::this.dir())
source('../lib/all.R')
# ------------------------------------------------------------------------------
#
#
#
#
# ------------------------------------------------------------------------------
# Funciones
# ------------------------------------------------------------------------------
feat <- function(df) df %>% dplyr::select(-Hazardous)
#
#
#
#
# ------------------------------------------------------------------------------
# 1. Cargamos el dataset.
# ------------------------------------------------------------------------------
# Excluimos las columnas no numericas que no nos interesan para este analisis.
excluded_columns <- c(
  'Neo.Reference.ID',
  'Name',
  'Close.Approach.Date',
  'Epoch.Date.Close.Approach',
  'Orbit.ID',
  'Orbit.Determination.Date',
  'Orbiting.Body',
  'Equinox'
)

# NASA DATASET: https://www.kaggle.com/shrutimehta/nasa-asteroids-classification
ds_step_1 <- loadcsv('../datasets/nasa.csv') %>% 
  dplyr::select(-excluded_columns) %>%
  na.omit 

str(ds_step_1)
#
#
#
#
# ------------------------------------------------------------------------------
# 2: Eliminamos las columnas que estan altamente correlacionadas
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

best_features <- top_acc_features(result, top=10)
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
# 4. Transformamos las clases a numeros
# ------------------------------------------------------------------------------
ds_step_4 <- ds_step_3 %>% 
  mutate(Hazardous = case_when(Hazardous %in% c('True') ~ 1, TRUE ~ 0))

original_hazardous <- ds_step_3 %>% dplyr::select(Hazardous)
rm(ds_step_3)

str(ds_step_4)
#
#
#
#
# ------------------------------------------------------------------------------
# 5. Analisis exploratorio
# ------------------------------------------------------------------------------
coparative_boxplot(ds_step_4, to_col = 10)

comparative_histplot(ds_step_4, to_col = 10)

comparative_qqplot(ds_step_4, to_col = 10)

plot_correlations(feat(ds_step_4))

ggpairs(feat(ds_step_4), aes(colour = original_hazardous$Hazardous, alpha = 0.4))

pca_result <- prcomp(feat(ds_step_4), scale = TRUE)
pca_result

plot_pca(pca_result, alpha = 0)

plot_pca(
  pca_result,
  groups=factor(original_hazardous$Hazardous),
  title="Hazardous Asteroids"
)
rm(pca_result)
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
scaled_train_set <- train_set %>% mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))
scaled_test_set  <- test_set %>% mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))
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
# 9. Entrenamos un modelo RDA
# ------------------------------------------------------------------------------
rda_model <- rda(reg_formula, scaled_train_set)

rda_test_pred  <- predict(rda_model, scaled_test_set)

plot_cm(rda_test_pred$class, scaled_test_set$Hazardous)
plot_roc(rda_test_pred$class, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 10. Entrenamos un modelo de regresion logistica
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
# 11. Entrenamos un modelo SVM
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
# 12. Clustering: Kmeans
# ------------------------------------------------------------------------------
# Tipica con estimadores de la normal
scaled_data_1 <- ds_step_4 %>%
  dplyr::select(-Hazardous) %>%
  mutate(~(scale(.) %>% as.vector))

# Escalamiento diferente de la tipica normal.
scaled_data_2 <- apply(
  ds_step_4 %>% dplyr::select(-Hazardous), 
  2, 
  function(x) { (x - min(x)) / (max(x) - min(x))}
)

clustering_metrics_plot(scaled_data_1)
clustering_metrics_plot(scaled_data_2)

n_clusters <- 2

kmeans_model <- kmeans(scaled_data_1, n_clusters)
ds_step_4$kmeans <- kmeans_model$cluster

pca_result <- pca(feat(ds_step_4))
plot_pca(
  pca_result,
  groups=factor(ds_step_4$kmeans),
  colours = c("green", "red", "orange","cyan","blue","magenta","yellow","black"),
  title="Hazardous Asteroids"
)
