% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Methods-plot.R
\name{plot_qc}
\alias{plot_qc}
\title{Plot quality control from a MetabolomcisSet object}
\usage{
plot_qc(object, mean = "qc_mean", sd = "sd_mean", cv = "cv_mean",
  log = TRUE)
}
\arguments{
\item{object}{A \code{\link{MetabolomicsSet-class}} object.}

\item{mean}{A character string indicating the feature_data column of qc means.}

\item{sd}{A character string indicating the feature_data column of qc standard deviation.}

\item{cv}{A character string indicating the feature_data column of qc coefficient of variance.}

\item{log}{A logic variable whether to log-transfer mean or sd.}
}
\description{
This function takes a MetabolomicsSet object and makes scatter plots using quality control samples
}
\author{
Chenghao Zhu
}
