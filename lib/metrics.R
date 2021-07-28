# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(ROCit, cvms)
# ------------------------------------------------------------------------------
#
#
#
#
plot_roc <- function(predictions, reality) plot(rocit(predictions, reality))

plot_cm <- function(predictions, reality) {
  plot_confusion_matrix(
    confusion_matrix(targets=reality,prediction=predictions)
  )
}