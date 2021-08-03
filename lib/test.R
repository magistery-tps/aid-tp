# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(mvnormtest, biotools, car)
setwd(this.path::this.dir())
source('./import.R')
#
import('./data-frame.R')
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
# Test de homocedasticidad multi-variado
#
multi_boxm_test <- function(features, target) boxM(features, target)

#
# Test de normalidad uni-variado. Calcula el test de normalidad para cada 
# columna del dataframe pasado como argumento.
#
uni_shapiro_test <- function(features) {
  r <- foreach_col(
    features, 
    function(features, col_index) {
      print(paste('=> Variable: ', colnames(features)[col_index], sep=''))
      print('')
      print(shapiro.test(features[, col_index]))
    }
  )
}

#
# Test de homocedaticidad uni-variado. Calcula el test de homocedaticidad 
# para cada columna del dataframe pasado como argumento.
#
uni_levene_test <- function(features, target) {
  r <- foreach_col(
    features, 
    function(features, col_index) {
      print(paste('=> Variable: ', colnames(features)[col_index], sep=''))
      print('')
      r <- leveneTest(features[, col_index], target)
      print(r)
      print('')
      print('')
    }
  )
}