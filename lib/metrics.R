# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(ROCit, cvms, pROC, cutpointr)

# ------------------------------------------------------------------------------
#
#
#
#
plot_roc <- function(predictions, reality) {
  result <- rocit(as.numeric(predictions), as.numeric(reality))
  plot(result)
  result
}

plot_cm <- function(predictions, reality) {
  plot_confusion_matrix(
    confusion_matrix(targets=reality, prediction=predictions)
  )
}

best_roc_threshold <- function(predictions, reality) {
  df <- data.frame(
    prediction= as.numeric(predictions),
    reality=as.numeric(reality)
  )
  cp <- cutpointr(
    df, 
    prediction, 
    reality,
    method = maximize_metric, 
    metric = sum_sens_spec
  )
  plot(cp)
  summary(cp)
}

