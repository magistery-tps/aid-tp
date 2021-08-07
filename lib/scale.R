max_min_scale <- function(df) {
  r <- apply(df, 2, function(x) { (x - min(x)) / (max(x) - min(x))})
  r
}
