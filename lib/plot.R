library(pacman)
p_load(devtools, stringi, tidyverse, WVPlots, DT, plotly, GGally, Hmisc, ggrepel)
p_load_gh("vqv/ggbiplot")
options(warn=-1)

source('../lib/plot/hist.R')
source('../lib/plot/pie.R')

plot_correlations <- function(data) {
  cor_matrix = cor(data) 
  cor_matrix[lower.tri(cor_matrix, diag = TRUE)] <- NA
  plot_heatmap(
    cor_matrix, 
    colors = c('blue', 'white', 'green')
  )
}

plot_heatmap <- function(data, colors = c('white', 'red')) {
  plot_ly(
    z = data, 
    y = colnames(data),
    x = rownames(data),
    colors = colorRamp(colors),
    type = "heatmap"
  )
}

show_table <- function(table, page_size = 6, filter = 'top') {
  datatable(
    table, 
    rownames = FALSE, 
    filter=filter, 
    options = list(page_size = page_size, scrollX=T)
  )
}


box_plot <- function(data, horizontal = TRUE, xlab="", ylab="") {
  boxplot(
    data,
    xlab=xlab, 
    ylab=ylab,
    horizontal = horizontal,
    las=1,
    cex.lab=0.8, 
    cex.axis=0.6,
    pars=list(boxlwd = 2, boxwex=.8),
    col=colors()
  )
}

data.frame.num.hist <- function(df) {
  hist.data.frame(df %>% select(where(is.numeric)))
}
