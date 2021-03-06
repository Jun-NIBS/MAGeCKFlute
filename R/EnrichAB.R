#' Enrichment analysis for Positive and Negative selection genes
#'
#' Do enrichment analysis for selected genes, in which positive selection and negative selection
#' are termed as GroupA and GroupB
#'
#' @docType methods
#' @name EnrichAB
#' @rdname EnrichAB
#'
#' @param data A data frame containing columns "diff", with rownames of Entrez IDs.
#' @param pvalue Pvalue cutoff.
#' @param enrich_method One of "ORT"(Over-Representing Test), "GSEA"(Gene Set Enrichment Analysis), and "HGT"(HyperGemetric test).
#' @param organism A character, specifying organism, such as "hsa"("Human") and "mmu"("Mouse").
#' @param pathway_limit A two-length vector (default: c(3, 50)), specifying the min and
#' max size of pathways for enrichent analysis.
#' @param adjust One of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", and "none".
#' @param filename Suffix of output file name.
#' @param out.dir Path to save plot to (combined with filename).
#' @param gsea Boolean, specifying if do GSEA for GroupA and GroupB genes. Default gsea = FALSE.
#' @param width As in ggsave.
#' @param height As in ggsave.
#' @param ... Other available parameters in ggsave.
#'
#' @return A list containing enrichment results for each group genes. This list contains items four
#' items, \code{keggA}, \code{keggB}, \code{bpA}, \code{bpB}. Four items are all list object, containing
#' subitems of \code{gridPlot} and \code{enrichRes}. \code{gridPlot} is a ggplot object, and
#' \code{enrichRes} is a enrichResult instance
#'
#' @author Binbin Wang
#'
#' @seealso \code{\link{EnrichSquare}}
#'
#'
# @examples
#' data(MLE_Data)
#' # Read beta score from gene summary table in MAGeCK MLE results
# dd = ReadBeta(MLE_Data, organism="hsa")
#
# \dontrun{
#   data=ScatterView(dd, ctrlname = "D7_R1", treatname = "PLX7_R1")$data
#   #BP and KEGG enrichment analysis
#   enrich_result = EnrichAB(data, pvalue=0.05, organism="hsa")
#   print(enrich_result$keggA$gridPlot)
#   print(enrich_result$bpA$gridPlot)
# }
#'
#' @import clusterProfiler

# Enrichment for GroupA and GroupB genes
EnrichAB <- function(data, pvalue = 0.25, enrich_method = "ORT",
                     organism = "hsa", pathway_limit = c(3, 50), adjust = "BH",
                     filename = NULL, out.dir = ".", gsea = FALSE, width = 6.5, height = 4, ...){

  requireNamespace("clusterProfiler", quietly=TRUE) || stop("Need clusterProfiler package")
  message(Sys.time(), " # Enrichment analysis of GroupA and GroupB genes ...")
  gg = data
  ##===================enrichment for GroupA==============================
  idx1 = gg$group=="up"
  genes = rownames(gg)[idx1]
  geneList = gg$diff[idx1]
  names(geneList) = genes
  universe = rownames(gg)

  #====GO_KEGG_enrichment=====
  keggA = enrichment_analysis(geneList = geneList, universe = universe,
                            method = enrich_method, type = "KEGG",
                            organism = organism, pvalueCutoff = pvalue,
                            plotTitle = "KEGG: GroupA", color = "#e41a1c",
                            pAdjustMethod = adjust, limit = pathway_limit)
  bpA=enrichment_analysis(geneList = geneList, universe = universe,
                          method = "ORT", type = "BP", organism = organism,
                          pvalueCutoff = pvalue, plotTitle = "BP: GroupA",
                          color = "#e41a1c", pAdjustMethod = adjust, limit = pathway_limit)
  if(gsea){
    requireNamespace("clusterProfiler", quietly=TRUE) || stop("need clusterProfiler package")
    gseA = enrichment_analysis(geneList = gg$diff, method = "GSEA",
                             type = "KEGG", organism=organism,
                             pvalueCutoff = pvalue, plotTitle="GSEA: GroupA",
                             color = "#e41a1c", pAdjustMethod = adjust, limit = pathway_limit)
  }
  ##=============Enrichment for GroupB========================================
  idx2 = gg$group=="down"
  genes = rownames(gg)[idx2]
  geneList = -gg$diff[idx2]
  names(geneList) = genes
  #====GO_KEGG_enrichment=====
  keggB=enrichment_analysis(geneList = geneList, universe = universe,
                            method = enrich_method, type = "KEGG",
                            organism = organism, pvalueCutoff = pvalue,
                            plotTitle = "KEGG: GroupB", color = "#377eb8",
                            pAdjustMethod = adjust, limit = pathway_limit)
  bpB = enrichment_analysis(geneList = geneList, universe = universe,
                            method = "ORT",type = "BP",organism = organism,
                            pvalueCutoff = pvalue, plotTitle = "BP: GroupB",
                            color="#377eb8", pAdjustMethod = adjust, limit = pathway_limit)
  if(gsea){
    gseB=enrichment_analysis(geneList = gg$diff, method = "GSEA",
                             type = "KEGG", organism=organism,
                             pvalueCutoff = pvalue, plotTitle="GSEA: GroupB",
                             color="#377eb8", pAdjustMethod = adjust, limit = pathway_limit)
  }
  ##================output results=============================================
  if(!is.null(filename)){
    ####===========GSEA results===================================
    if(gsea){
      p1=ggplot()
      p1=p1+geom_text(aes(x=0,y=0,label="No enriched terms"),size=6)
      p1=p1+theme_void()

      dir.create(file.path(out.dir,"GSEA_results"), showWarnings=FALSE)
      ##=========GroupA GSEA plot=================================
      if(!is.null(gseA$enrichRes) && nrow(gseA$enrichRes@result)>0){
        for(term in gseA$enrichRes@result$ID[nrow(gseA$enrichRes@result):1]){
          png(file.path(out.dir,paste0("GSEA_results/GroupA_gse_",
                                       term, "_", filename,".png")),
              units = "in", width=6.5, height=4, res=300)
          p1 = gseaplot(gseA$enrichRes, term)$runningScore
          dev.off()
        }
        p1 <- p1+xlab("Ranked list of genes")+ylab("Enrichment score")
        p1 <- p1+labs(title=as.character(gseA$enrichRes@result$Description[1]))
        p1 <- p1+theme(axis.text.x=element_text(size=6, face="plain",
                                                colour='black'))
        p1 <- p1+theme(axis.text.y=element_text(size=6, face="plain",
                                                colour='black'))
        p1=p1+theme(plot.title = element_text(hjust = 0.5,size=10,
                                              face="plain", colour='black'))
        p1 <- p1+theme(panel.grid.minor=element_blank(),
                       panel.background=element_blank())
        write.table(gseA$enrichRes@result,
              file.path(out.dir,
                  paste0("GSEA_results/GroupA_gse_",filename,".txt")),
              sep="\t", row.names = FALSE,col.names = TRUE,quote= FALSE)
      }
      gseA$gseaplot = p1
      ##=========GroupB GSEA plot==================================
      if(!is.null(gseB$enrichRes) && nrow(gseB$enrichRes@result)>0){
        for(term in gseB$enrichRes@result$ID[nrow(gseB$enrichRes@result):1]){
          png(file.path(out.dir,paste0("GSEA_results/GroupB_gse_",
                                       term, "_", filename,".png")),
              units = "in", width=6.5, height=4, res=300)
          p1 = gseaplot(gseB$enrichRes, term)$runningScore
          dev.off()
        }
        p1 <- p1+xlab("Ranked list of genes")+ylab("Enrichment score")
        p1 <- p1+labs(title=as.character(gseB$enrichRes@result$Description[1]))
        p1 <- p1+theme(axis.text.x=element_text(size=6, face="plain",
                                                colour='black'))
        p1 <- p1+theme(axis.text.y=element_text(size=6, face="plain",
                                                colour='black'))
        p1=p1+theme(plot.title = element_text(hjust = 0.5,size=10,
                                              face="plain", colour='black'))
        p1 <- p1+theme(panel.grid.minor=element_blank(),
                       panel.background=element_blank())
        write.table(gseB$enrichRes@result,
                    file.path(out.dir,paste0("GSEA_results/GroupB_gse_",
                                             filename,".txt")),
                    sep="\t", row.names = FALSE,col.names = TRUE,quote=FALSE)
      }
      gseB$gseaplot = p1
    }
    ##=========Save GroupA enrichment results===========================
    if(!is.null(keggA$enrichRes)){
      write.table(keggA$enrichRes@result,
                  file.path(out.dir,paste0("GroupA_kegg_",filename,".txt")),
                  sep="\t", row.names = FALSE,col.names = TRUE,quote=FALSE)
      ggsave(keggA$gridPlot,
             filename=file.path(out.dir,paste0("GroupA_kegg_",
                                               filename,".png")),
             units = "in", width=6.5, height=4)
    }
    if(!is.null(bpA$enrichRes)){
      write.table(bpA$enrichRes@result,
                  file.path(out.dir,paste0("GroupA_bp_",filename,".txt")),
                  sep="\t", row.names = FALSE,col.names = TRUE,quote=FALSE)
      ggsave(bpA$gridPlot,
             filename=file.path(out.dir,paste0("GroupA_bp_",filename,".png")),
             units = "in", width=6.5, height=4)
    }
    ##=========Save GroupB enrichment results===========================
    if(!is.null(keggB$enrichRes)){
      write.table(keggB$enrichRes@result,
                  file.path(out.dir,paste0("GroupB_kegg_",filename,".txt")),
                  sep="\t", row.names = FALSE,col.names = TRUE,quote=FALSE)
      ggsave(keggB$gridPlot,
             filename=file.path(out.dir,paste0("GroupB_kegg_",filename,".png")),
             units = "in", width=6.5, height=4)
    }
    if(!is.null(bpB$enrichRes)){
      write.table(bpB$enrichRes@result,
                  file.path(out.dir,paste0("GroupB_bp_",filename,".txt")),
                  sep="\t", row.names = FALSE, col.names = TRUE, quote=FALSE)
      ggsave(bpB$gridPlot,
             filename=file.path(out.dir,paste0("GroupB_bp_",filename,".png")),
             units = "in", width=6.5, height=4)
    }
  }
  ##=========Return results=====================================
  if(gsea){
    return(list(keggA=keggA, bpA=bpA, gseA=gseA,
                keggB=keggB, bpB=bpB, gseB=gseB))
  }else{
    return(list(keggA=keggA, bpA=bpA, keggB=keggB, bpB=bpB))
  }
}

