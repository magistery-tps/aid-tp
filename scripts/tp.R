# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
install.packages('pacman')
library(pacman)
p_load(this.path, dplyr, MASS, stats, klaR, e1071)
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
# 4. Transformamos las clases a numeros
# ------------------------------------------------------------------------------
ds_step_4 <- ds_step_3 %>% 
  mutate(Hazardous = case_when(Hazardous %in% c('True') ~ 1, TRUE ~ 0))
str(ds_step_4)
#
#
#
#
# ------------------------------------------------------------------------------
# 5. Graficamos
# ------------------------------------------------------------------------------
# Correlation:
plot_correlations(feat(ds_step_4))

# Pairs:
ggpairs(feat(ds_step_4), aes(colour = ds_step_3$Hazardous, alpha = 0.4))

# PCA:
pca_result <- prcomp(feat(ds_step_4), scale = TRUE)
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
c(train_set, test_set) %<-% train_test_split(ds_step_4, train_size=.8)
nrow(train_set)
nrow(test_set)
#
#
#
# ------------------------------------------------------------------------------
# 5. Escalamos las variables numéricas(Restamos la media y dividimos por el
#    desvío).
# ------------------------------------------------------------------------------
scaled_train_set <- train_set %>% mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))
scaled_test_set  <- test_set %>% mutate_at(vars(-Hazardous), ~(scale(.) %>% as.vector))
#
#
#
# ------------------------------------------------------------------------------
# 6. Entrenamos un modelo LDA
# ------------------------------------------------------------------------------
reg_formula <- formula(Hazardous~.)

lda_model <- lda(reg_formula, scaled_train_set)

lda_train_pred <- predict(lda_model, scaled_train_set)
lda_test_pred  <- predict(lda_model, scaled_test_set)

plot_cm(lda_train_pred$class, scaled_train_set$Hazardous)
plot_cm(lda_test_pred$class, scaled_test_set$Hazardous)
plot_roc(lda_test_pred$class, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 7. Entrenamos un modelo RDA
# ------------------------------------------------------------------------------
rda_model <- rda(reg_formula, scaled_train_set)

rda_train_pred <- predict(rda_model, scaled_train_set)
rda_test_pred  <- predict(rda_model, scaled_test_set)

plot_cm(rda_train_pred$class, scaled_train_set$Hazardous)
plot_cm(rda_test_pred$class, scaled_test_set$Hazardous)
plot_roc(rda_test_pred$class, scaled_test_set$Hazardous)
#
#
#
# ------------------------------------------------------------------------------
# 8. Entrenamos un modelo de regresion logistica
# ------------------------------------------------------------------------------
rl_threshold <- 0.5

rl_model <- glm(reg_formula, scaled_train_set, family=binomial)

rl_train_pred <- predict(rl_model, scaled_train_set)
rl_train_pred <- ifelse(rl_train_pred >= rl_threshold, 1, 0)

rl_test_pred <- predict(rl_model, scaled_test_set)
rl_test_pred <- ifelse(rl_test_pred >= rl_threshold, 1, 0)

plot_cm(rl_train_pred, scaled_train_set$Hazardous)
plot_cm(rl_test_pred, scaled_test_set$Hazardous)
plot_roc(rl_test_pred, scaled_test_set$Hazardous)
