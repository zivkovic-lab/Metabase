% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Class-mSet.R, R/Methods-assessor.R
\docType{methods}
\name{conc_table}
\alias{conc_table}
\alias{conc_table,mSet-method}
\title{Construct or assess a conc_table object}
\usage{
conc_table(object)

\S4method{conc_table}{mSet}(object)
}
\arguments{
\item{object}{To construct a conc_table object, this is a numeric matrix of
the concentration table from a quantitative experiment. Samples should be in
columns and features in rows. The data should also have sample IDs as column
names and feature IDs as row names. To assess the conc_table slot from a
mSet object, this is a mSet object.}
}
\value{
An \code{\link{conc_table-class}} object.
}
\description{
This is the method to either access the concentration table slot from a
\code{\link{mSet-class}} object, or construct a
\code{\link{conc_table-class}} object from a matrix. When use it as an
assessing method, a \code{\link{conc_table-class}} object
is returned. When use it as a construction method, a matrix is required.
}
\seealso{
\code{\link{conc_table-class}}
}
\author{
Chenghao Zhu
}
