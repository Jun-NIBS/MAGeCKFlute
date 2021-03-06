% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BatchRemove.R
\docType{methods}
\name{BatchRemove}
\alias{BatchRemove}
\alias{batchremove}
\title{Batch effect removal}
\usage{
BatchRemove(mat, batchMat, log2trans = FALSE, positive = FALSE)
}
\arguments{
\item{mat}{Matrix, or a file path of data.}

\item{batchMat}{Matrix like data object or a file path of batch table, which has at least two columns,
including Samples(matched colname of mat) and Batch. It can have the third column, which should be Covariate.}

\item{log2trans}{Boolean, specifying whether do log2 transition before batch removal.}

\item{positive}{Boolean, specifying whether all values should be positive.}
}
\value{
A list contrains two objects, including \code{data} and \code{p}.
}
\description{
Remove batch effect
}
\examples{
data(MLE_Data)
beta = ReadBeta(MLE_Data, organism="hsa")
samples = c("D7_R1", "D7_R2", "PLX7_R1", "PLX7_R2")
batchMat = data.frame(samples = samples, batch = c("bat1","bat2","bat1","bat2"), cov = c(1,1,2,2))
res = BatchRemove(beta[, samples], batchMat)

}
\seealso{
\code{\link[sva]{ComBat}}
}
\author{
Wubing Zhang
}
