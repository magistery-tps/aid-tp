# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
install.packages('pacman')
library(pacman)
p_load(this.path, dplyr, MASS)
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
to_num <- function(values) ifelse(values == "True", 1, 0)

show_roc <- function(predictions, reality) {
  plot_roc(to_num(predictions), to_num(reality))
}
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
  ds_step_1 %>% dplyr::select(-Hazardous), 
  cutoff=0.8
)
length(high_correlated_columns)
length(ds_step_1)

ds_step_2 <- ds_step_1 %>% dplyr::select(-high_correlated_columns[-1])

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
str(ds_step_3)
#
#
#
#
# ------------------------------------------------------------------------------
# 3. Graficamos
# ------------------------------------------------------------------------------
# Correlation:
plot_correlations(ds_step_3 %>% dplyr::select(-Hazardous))

# Pairs:
ggpairs(ds_step_3, aes(colour = ds_step_3$Hazardous, alpha = 0.4))

# PCA:
pca_result <- prcomp(ds_step_3 %>% dplyr::select(-Hazardous), scale = TRUE)
pca_result

plot_pca(pca_result, alpha = 0)

plot_pca(
  pca_result,
  groups=factor(ds_step_3$Hazardous),
  title="Hazardous Asteroids"
)
#
#
#
# ------------------------------------------------------------------------------
# 4. Train test split
# ------------------------------------------------------------------------------
c(train_set, test_set) %<-% train_test_split2(ds_step_3, train_size=.8)
nrow(train_set)
nrow(test_set)
#
#
#
# ------------------------------------------------------------------------------
# 5. Escalamos las variables numéricas(Restamos la media y dividimos por el
#    desvío).
# ------------------------------------------------------------------------------
scaled_train_set  <- train_set %>% mutate_if(is.numeric, ~(scale(.) %>% as.vector))
scaled_test_set  <- test_set %>% mutate_if(is.numeric, ~(scale(.) %>% as.vector))
#
#
#
# ------------------------------------------------------------------------------
# LDA
# ------------------------------------------------------------------------------
lda_model <- lda(formula(Hazardous~.), scaled_train_set)

lda_train_pred <- predict(lda_model, scaled_train_set)
lda_test_pred  <- predict(lda_model, scaled_test_set)

plot_cm(lda_train_pred$class, scaled_train_set$Hazardous)
plot_cm(lda_test_pred$class, scaled_test_set$Hazardous)

show_roc(lda_test_pred$class, scaled_test_set$Hazardous)


