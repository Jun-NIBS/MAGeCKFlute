% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EnrichSquare.R
\docType{methods}
\name{EnrichSquare}
\alias{EnrichSquare}
\title{Enrichment analysis for selected treatment related genes}
\usage{
EnrichSquare(beta, pvalue = 0.05, enrich_method = "ORT", organism = "hsa",
  pathway_limit = c(3, 50), adjust = "BH", filename = NULL,
  out.dir = ".", width = 6.5, height = 4, ...)
}
\arguments{
\item{beta}{Data frame, with rownames of Entrez IDs, which contains columns of 'group' and 'diff'.}

\item{pvalue}{Pvalue cutoff.}

\item{enrich_method}{One of "ORT"(Over-Representing Test), "DAVID", "GOstats", and "HGT"(HyperGemetric test).}

\item{organism}{A character, specifying organism, such as "hsa" or "Human"(default), and "mmu" or "Mouse"}

\item{pathway_limit}{A two-length vector (default: c(3, 50)), specifying the min and
max size of pathways for enrichent analysis.}

\item{adjust}{One of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none".}

\item{filename}{Suffix of output file name. NULL(default) means no output.}

\item{out.dir}{Path to save plot to (combined with filename).}

\item{width}{As in ggsave.}

\item{height}{As in ggsave.}

\item{...}{Other available parameters in ggsave.}
}
\value{
A list containing enrichment results for each group genes. This list contains several elements:
\item{kegg1}{a list record enriched KEGG pathways for Group1 genes in 9-Square}
\item{kegg2}{a list record enriched KEGG pathways for Group2 genes in 9-Square}
\item{kegg3}{a list record enriched KEGG pathways for Group3 genes in 9-Square}
\item{kegg4}{a list record enriched KEGG pathways for Group4 genes in 9-Square}
\item{kegg13}{a list record enriched KEGG pathways for Group1&Group3 genes in 9-Square}
\item{kegg14}{a list record enriched KEGG pathways for Group1&Group4 genes in 9-Square}
\item{kegg23}{a list record enriched KEGG pathways for Group2&Group3 genes in 9-Square}
\item{kegg24}{a list record enriched KEGG pathways for Group2&Group4 genes in 9-Square}
\item{bp1}{a list record enriched GO BP terms for Group1 genes in 9-Square}
\item{bp2}{a list record enriched GO BP terms for Group2 genes in 9-Square}
\item{bp3}{a list record enriched GO BP terms for Group3 genes in 9-Square}
\item{bp4}{a list record enriched GO BP terms for Group4 genes in 9-Square}
\item{bp13}{a list record enriched GO BP terms for Group1&Group3 genes in 9-Square}
\item{bp14}{a list record enriched GO BP terms for Group1&Group4 genes in 9-Square}
\item{bp23}{a list record enriched GO BP terms for Group2&Group3 genes in 9-Square}
\item{bp24}{a list record enriched GO BP terms for Group2&Group4 genes in 9-Square}

Each item in the returned list has two sub items:
\item{gridPlot}{an object created by \code{ggplot}, which can be assigned and further customized.}
\item{enrichRes}{a enrichResult instance.}
}
\description{
Do enrichment analysis for selected treatment related genes in 9-squares
}
\examples{
\dontrun{
 data(MLE_Data)
 # Read beta score from gene summary table in MAGeCK MLE results
 dd = ReadBeta(MLE_Data, organism="hsa")
 p = SquareView(dd, ctrlname = "D7_R1", treatname = "PLX7_R1")
 E1 = EnrichSquare(p$data, organism="hsa")
 print(E1$kegg1$gridPlot)
}
}
\seealso{
\code{\link{SquareView}}

\code{\link{EnrichSquare}}
}
\author{
Wubing Zhang
}
