# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(mvnormtest)
setwd(this.path::this.dir())
source('./import.R')
#
import('../data-frame.R')
# ------------------------------------------------------------------------------
#
#
#
#

#
# Test de normalidad multi-variado
#
mult_shapiro_test <- function(features) {
  mshapiro.test(t(as.matrix(features)))
}

#
# Test de normalidad uni-variado. Calcula el test de normalidad para cada 
# columna de dataframe pasado como argumento.
#
uni_shapiro_test <- function(df) {
  foreach_col(
    feat(ds_step_4), 
    function(df, col_index) {
      print(paste(colnames(df)[col_index], '->', col_index))
      shapiro.test(df[, col_index])
    }
  )
}
