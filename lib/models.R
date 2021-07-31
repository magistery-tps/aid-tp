# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(MASS, stats, klaR, e1071, cluster, pracma, mvnormtest)
# ------------------------------------------------------------------------------
#
#
#
#
mult_shapiro_test <- function(features) {
  mshapiro.test(t(as.matrix(features)))
}