library(pacman)
p_load(stringi, tidyverse)


freq_table_mean <- function(freq_table) {
  sum(freq_table$value * freq_table$frequency) / sum(freq_table$frequency)
}
