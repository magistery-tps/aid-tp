index_as_column <- function(df) {
  df <- cbind(index = rownames(df), df)
  rownames(df) <- 1:nrow(df)
  df
}