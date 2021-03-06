\name{buildCustomIncidenceMatrix}
\alias{buildCustomIncidenceMatrix}
\title{
  	This function builds an incidence matrix for custom gene sets.
}
\description{
		This function builds an incidence matrix for custom gene sets.
}
\usage{
buildCustomIncidenceMatrix(geneSetFrame, geneNames, databaseGeneFormat, expressionSetGeneFormat,geneSetNames)
}
\arguments{
  \item{geneSetFrame}{
		a \code{dataframe} where rows are gene sets and columns are genes.
}
  \item{geneNames}{
		a \code{vector} of all the genes in the geneSetFrame \code{dataframe}
}
  \item{databaseGeneFormat}{
  a character string specifying the type of identifier for a gene in a database (KEGG, reactome, MsigDB) gene set.
  The default value is NULL. (ex. SYMBOL, ENTREZID, REFSEQ, ENSEMBL)
}
  \item{expressionSetGeneFormat}{
  a character string specifying the type of identifier for a gene in your expression data set.
  The default value is NULL. (ex. SYMBOL, ENTREZID, REFSEQ, ENSEMBL)
}
  \item{geneSetNames}{
  	a \code{vector} of the name of the custom gene sets. 
}
}
\details{
	This function creates an incidence matrix from a dataframe where the rows are the names of gene sets and the columns are genes.
}
\value{
	A matrix object with 0 and 1 entries where 1 denotes membership of a gene in a custom gene set, 0 denotes non-membership.  
}
\author{
	Jessica Mar
}
\references{
Mar, J., C. Wells, and J. Quackenbush, Identifying the Gene Expression Modules that Represent the Drivers of Kauffman's Attractor Landscape. to appear, 2010.
}

\keyword{methods}
