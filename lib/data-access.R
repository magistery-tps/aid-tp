library(pacman)
p_load(mongolite)

source('../lib/plot.R')

get_collection <- function(name, db="spotify") { 
  mongo(collection=name, db = db)
}

get_collection_fields <- function(collection_name, field_name) {
  collection <- get_collection(collection_name)
  projection <- paste('{ "', field_name, '": 1 }', sep='')
  collection$find(fields = projection)
}

get_freq_table <- function(collection_name) {
  hist_collection <- get_collection(collection_name)

  hist_collection$find(
    query = '{}', 
    fields = '{"_id": false, "frequency": true, "value": true}'
  )
}

plot_hist_collection <- function(collection_name, name, binwidth=0.5) {
  gplot_hist_from_freq_table(
    get_freq_table(collection_name),
    name=name,
    binwidth=binwidth
  )
}



