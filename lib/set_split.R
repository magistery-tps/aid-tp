# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(zeallot)
# ------------------------------------------------------------------------------
#
#
#
#
train_test_split <- function(df, train_size=.7) {
  train_ind <- sample(seq_len(nrow(df)), size = (nrow(df) * train_size))
  
  train_set <- df[train_ind, ]
  test_set  <- df[-train_ind, ]
  
  list(train_set, test_set)
}