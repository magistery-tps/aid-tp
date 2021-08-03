# ------------------------------------------------------------------------------
# Import dependencies
# ------------------------------------------------------------------------------
library(pacman)
p_load(ROCit, cvms, pROC, cutpointr, Metrics, ggimage, rsvg)
# ------------------------------------------------------------------------------
#
#
#
#

#
# Metrica F Beta score
#
f_beta_score <- function(prediction, reality, beta=1, show=TRUE) {
  score <- fbeta_score(as.numeric(reality), as.numeric(prediction), beta=beta)
  if(show) {
    print(paste('F', beta, 'Score: ', score, sep=''))
  } else {
    score
  }
}


#
# Grafica de la curva ROC.
#
plot_roc <- function(predictions, reality) {
  result <- rocit(as.numeric(predictions), as.numeric(reality))
  plot(result)
  result
}


#
# Grafica de la matriz de confusión.
#
plot_cm <- function(predictions, reality) {
  plot_confusion_matrix(
    confusion_matrix(targets=reality, prediction=predictions)
  )
}


#
# Imprime la matriz de confusión.
#
plot_text_cm <- function(predictions, reality) {
  table(predictions, reality, dnn = c("Reality", "Prediction"))
}

#
# Calcula el mejor punto de corte.
#
best_roc_threshold <- function(predictions, reality) {
  df <- data.frame(
    prediction= as.numeric(predictions),
    reality=as.numeric(reality)
  )
  cp <- cutpointr(
    df, 
    prediction, 
    reality,
    method = maximize_metric, 
    metric = sum_sens_spec
  )
  plot(cp)
  summary(cp)
}


clustering_metrics <- function(datA_esc, kmax=10, f="kmeans") {
  sil = array()
  sse = array()
  
  datA_dist <- dist(
    datA_esc, 
    method = "euclidean", 
    diag = FALSE, 
    upper = FALSE,
    p = 2
  )
  
  for(i in  2:kmax) {
    #centroide: tipico kmeans
    if (strcmp(f,"kmeans")==TRUE) {
      CL     = kmeans(datA_esc,centers=i,nstart=50,iter.max = kmax)
      sse[i] = CL$tot.withinss 
      CL_sil = silhouette(CL$cluster, datA_dist)
      sil[i] = summary(CL_sil)$avg.width
    }
    
    #medoide: ojo porque este metodo tarda muchisimo
    if (strcmp(f,"pam")==TRUE){ 
      CL     = pam(x=datA_esc, k=i, diss = F, metric = "euclidean")
      sse[i] = CL$objective[1] 
      sil[i] = CL$silinfo$avg.width
    }
  }
  return(data.frame(sse,sil))
}

plot_sil_sse <- function(metrics, kmax) {
  par(mfrow=c(2,1))
  plot(
    2:kmax, 
    metrics$sil[2:kmax],
    col=1,
    type="b", 
    pch = 19, 
    frame = FALSE, 
    xlab="Number of clusters K",
    ylab="sil"
  )
  plot(
    2:kmax,
    metrics$sse[2:kmax],
    type="b",
    pch = 19,
    frame = FALSE,
    xlab="Number of clusters K",
    ylab="sse"
  )
  par(mfrow=c(1,1))
  grid()
}


#
# Grafica las métricas sil y sse para cada valor de k jasta kmax.
#
clustering_metrics_plot <- function(data, kmax=10, f="kmeans") {
  metrics <- clustering_metrics(data, kmax, f)
  plot_sil_sse(metrics, kmax)
}
