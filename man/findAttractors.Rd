\name{findAttractors}
\alias{findAttractors}
\title{
Infers the set of cell-lineage specific gene expression modules using GSEAlm and KEGG.
}
\description{
The function infers a set of KEGG pathways that correspond to the cell-lineage specific gene 
expression modules, as determined using GSEA. These pathways represent those that show the greatest 
discrimination between the different cell types or tissues in the expression data set supplied. 
}
\usage{
findAttractors(myEset, cellTypeTag, min.pwaysize = 5, annotation = "illuminaHumanv2.db", database="KEGG", analysis="microarray", databaseGeneFormat=NULL, expressionSetGeneFormat=NULL, ...)
}

\arguments{
  \item{myEset}{
		\code{ExpressionSet} object.
}
  \item{cellTypeTag}{
		character string of the variable name which stores the cell-lineages or experimental groups of interest for the samples in the data set 
		(this string should be one of the column names of \code{pData(myEset))}.  		
}
  \item{min.pwaysize}{
		\code{integer} specifying the minimum size of the KEGG or reactome pathways to consider in the analysis.  
}
  \item{annotation}{
		character string specifying the annotation package that corresponds to the chip platform or organism (for RNAseq data) the data was generated from. 
}
  \item{database}{
  a character string specifiying what pathway database you would like to use.  
}
  \item{analysis}{
  a character string specifying what type of experiment you performed, microarray or RNAseq.  
}
  \item{databaseGeneFormat}{
  a character string specifying the type of identifier for a gene in a database (KEGG, REACTOME, MsigDB) gene set.
  The default value is NULL. (ex. SYMBOL, ENTREZID, REFSEQ, ENSEMBL)
}
  \item{expressionSetGeneFormat}{
  a character string specifying the type of identifier for a gene in your expression data set.
  The default value is NULL. (ex. SYMBOL, ENTREZID, REFSEQ, ENSEMBL)
}
  \item{\dots}{
		additional arguments.
}
}
\details{
		This function subsets the expression data so that only those genes with annotations in KEGG or reactome are used for the downstream 
		gene set enrichment analysis. This subset is stored in the eSet slot of the AttractoModuleSet output object. \cr
		
		The GSEAlm algorithm finds the KEGG or reactome pathway modules which discriminate between the celltypes or experimental groups of interest. 
		It also ranks the results of the GSEAlm step by significance of these pathway modules, as stored in \code{rankedPathways}. \cr
		
		The output object of the \code{findAttractors} function also contains the incidence matrix that was built for the KEGG or reactome pathways, stored in 
		the slot \code{incidenceMatrix} and the character string denoting which column of the sample data represents the cell type or 
		experimental groups of interest, as stored in the slot \code{cellTypeTag}. 
		
}
\value{
		An \code{AttractorModuleSet} object. 
}
\references{
Jiang, Z. and R. Gentleman, Extensions to gene set enrichment. Bioinformatics, 2007. 23(3): p. 306-313.
Kanehisa, M. and S. Goto, KEGG: Kyoto Encyclopedia of Genes and Genomes. . Nucleic Acids Res., 2000. 28: p. 27-30.
Mar, J., C. Wells, and J. Quackenbush, Identifying the Gene Expression Modules that Represent the Drivers of Kauffman's Attractor Landscape. to appear, 2010.
}
\author{
		Jessica Mar
}
\examples{
data(subset.loring.eset)
attractor.states <- findAttractors(subset.loring.eset, "celltype", annotation="illuminaHumanv1.db",database="KEGG", analysis="microarray",databaseGeneFormat=NULL, expressionSetGeneFormat=NULL)
MSigDBpath <- system.file("extdata","c4.cgn.v5.0.entrez.gmt",package="attract")
attractor.states.cutsom <- findAttractors(subset.loring.eset, "celltype", annotation="illuminaHumanv1.db",database=MSigDBpath, analysis="microarray",databaseGeneFormat="ENTREZID", expressionSetGeneFormat="PROBEID")
}
\keyword{methods}
