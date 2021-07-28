# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(this.path, randomForest, dplyr)
setwd(this.path::this.dir())
source('./df.R')
# ------------------------------------------------------------------------------
#
#
#
#
features_importance <- function(df, target) {
  features <- df %>% select_if(is.numeric)
  target   <- df %>% 
    dplyr::select(target) %>%
    mutate_if(is.character, as.factor) %>%
    pull(target)
  
  randomForest(x = features, y = target, importance=TRUE)
}

plot_features_importance <- function(result, title ='Features importance') {
  varImpPlot(result, main=title, bg="skyblue", cex=1, pch=22)
}

top_acc_features <- function(result, top=10) {
  index_as_column(as.data.frame(importance(result))) %>% 
    arrange(desc(MeanDecreaseAccuracy)) %>%
    top_n(top) %>%
    dplyr::select(index) %>%
    pull()
}