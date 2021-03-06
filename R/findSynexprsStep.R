#################################################
# Step 3 - find synexpression groups
#################################################

getCustomGenes <- function(vec.geneid, removeGenes=NULL){
    pway.genes <- setdiff(vec.geneid, removeGenes)
    return(pway.genes)
}

getPwayGenes <- function(pathwayIds, myAttractorModuleSet, removeGenes=NULL){

	# grab relevant parts out of the AttractorModuleSet, and remove the genes stored in removeGenes
	incidence.matrix <- myAttractorModuleSet@incidenceMatrix
	incidence.matrix <- incidence.matrix[,!colnames(incidence.matrix) %in% removeGenes]
    pway.genes <- colnames(incidence.matrix)[incidence.matrix[rownames(incidence.matrix) %in% pathwayIds,] == 1] 
    #pway.genes <- setdiff(pway.genes, removeGenes) # pway genes that are not removed
    return(pway.genes)
}
findOnepwaySynexprs <- function(myIDs, myDataSet, cellTypeTag, min.clustersize=5, removeGenes=NULL, ...){
	print(myIDs)
    if (class(myDataSet) == "ExpressionSet") {
        dat.fr <- exprs(myDataSet)
        class.vector <- as.factor(pData(myDataSet)[,colnames(pData(myDataSet)) %in% cellTypeTag])
        pway.genes <- getCustomGenes(myIDs, removeGenes)
        if( length(pway.genes) <= min.clustersize ){
            print("Insufficient number of genes in this pathway after removing flat genes.")
            return(NULL)
        }
    } else {
        dat.fr <- exprs(myDataSet@eSet)
        dat.fr <- dat.fr[!rownames(dat.fr) %in% removeGenes,]
        class.vector <- as.factor(pData(myDataSet@eSet)[,colnames(pData(myDataSet@eSet)) %in% myDataSet@cellTypeTag])
        pway.genes <- getPwayGenes(myIDs, myDataSet, removeGenes)
        if( length(setdiff(pway.genes, removeGenes)) <= min.clustersize ){
            print("Insufficient number of genes in this pathway after removing flat genes.")
            return(NULL)
        }
    }
    exprs.pway <- dat.fr[rownames(dat.fr) %in% pway.genes,]
    
    #require(cluster)
    cor.pway <- cor(t(exprs.pway))
    clust.pway <- agnes(as.dist(1-cor.pway), method="complete")

    nc <- 1
    while( nc > 0 ){ # maybe this should be when nc > 1. Because if nc is 1, then biggestc could become 0 resulting in an error
        m <- min(table(cutree(clust.pway, k=nc)))
        if( m <= min.clustersize ){
            biggestc <- nc-1; nc <- -1
        }
        else{
            nc <- nc + 1
        }
    }

    calc.mssvals <- function(jval, clust.pway, class.vector, exprs.pway){
        pway.clj <- cutree(clust.pway, k=jval)
        return(calcInform(exprs.pway, pway.clj, class.vector))
    }
		
    calc.rssvals <- function(jval, clust.pway, class.vector, exprs.pway){
        pway.clj <- cutree(clust.pway, k=jval)
        return(calcRss(exprs.pway, pway.clj, class.vector))
    }
		
    pway.mss.vals <- apply(cbind(1:biggestc), 1, calc.mssvals, clust.pway, class.vector, exprs.pway)
    pway.rss.vals <- apply(cbind(1:biggestc), 1, calc.rssvals, clust.pway, class.vector, exprs.pway)
    optic <- (1:biggestc)[pway.mss.vals == max(pway.mss.vals)]
		
    pway.optic <- cutree(clust.pway, k=optic)
    names(pway.optic) <- rownames(exprs.pway)
    exprs.synexprs <- NULL ; mg.lst <- list()

    calc.opticexprs <- function(jval, exprs.pway, pway.optic){
        apply(exprs.pway[pway.optic==jval,], 2, mean, na.rm=TRUE)
    }
    exprs.synexprs <- t(apply(cbind(1:optic), 1, calc.opticexprs, exprs.pway, pway.optic)) 	# make sure this has the right dimensions!
		
    calc.opticnames <- function(jval, pway.optic){
        names(pway.optic)[pway.optic == jval]
    }
    mg.lst <- lapply(as.list(1:optic), calc.opticnames, pway.optic)

    pway.out <- new("SynExpressionSet")
    pway.out@groups <- mg.lst
    pway.out@profiles <- exprs.synexprs
    return(pway.out)
}
# myDataSet can be an AttractorModuleSet or an Eset)
# myIDs can be pathway IDs or geneIDs if you have a custom set
findSynexprs <- function(myIDs, myDataSet, cellTypeTag, removeGenes=NULL, min.clustersize=5, ...){

	if( length(myIDs) == 1 || class(myDataSet) == "ExpressionSet") {
		res <- findOnepwaySynexprs(myIDs, myDataSet, cellTypeTag, min.clustersize=min.clustersize, removeGenes=removeGenes)
	}
	else{
		res <- new.env()		
		do.onepway.synexprs <- function(onepway, myDataSet, cellTypeTag, min.clustersize, removeGenes, res){
			out <- findOnepwaySynexprs(onepway, myDataSet, cellTypeTag, min.clustersize=min.clustersize, removeGenes=removeGenes)
			assign(paste("pway", onepway, "synexprs", sep=""), out, res)
		}
		l <- lapply(as.list(myIDs), do.onepway.synexprs, myDataSet, cellTypeTag, min.clustersize, removeGenes, res)
	}
	return(res)
}

calcInform <- function(exprs.dat, cl, class.vector) 
{
    n <- length(class.vector)
    calc.onemss <- function(cluster.index, exprs.dat, cl, class.vector) {
        m <- apply(exprs.dat[cl == cluster.index, ], 2, mean)
        mss <- anova(lm(m ~ class.vector))[[3]][1]
        return(mss)
    }
    avgmss <- mean(apply(cbind(unique(cl)), 1, calc.onemss, exprs.dat, 
        cl, class.vector))
    return(avgmss)
}

calcRss <- function (exprs.dat, cl, class.vector) 
{
    n <- length(class.vector)
    calc.onerss <- function(cluster.index, exprs.dat, cl, class.vector) {
        m <- apply(exprs.dat[cl == cluster.index, ], 2, mean)
        rss <- anova(lm(m ~ class.vector))[[3]][2]
        return(rss)
    }
    avgrss <- mean(apply(cbind(unique(cl)), 1, calc.onerss, exprs.dat, 
        cl, class.vector))
    return(avgrss)
}

calcModfstat <- function (exprs.dat, cl, class.vector) 
{
    n <- length(class.vector)
    calc.onefstat <- function(cluster.index, exprs.dat, cl, class.vector) {
        m <- apply(exprs.dat[cl == cluster.index, ], 2, mean)
        fstat <- anova(lm(m ~ class.vector))[[4]][1]
        return(fstat)
    }
    avgfstat <- mean(apply(cbind(unique(cl)), 1, calc.onefstat, exprs.dat, 
        cl, class.vector))
    return(avgfstat)
}

plotsynexprs <- function(mySynExpressionSet, tickMarks, tickLabels, vertLines, index=1, ...){
	if( is.numeric(index) ){
		plot(mySynExpressionSet@profiles[index,], ylab="Log2(Expression)", axes=FALSE, xlab="Groups", type="l", lwd=4, ...)
		axis(1, at=tickMarks, lab=tickLabels)
		axis(2) ; box() 
		abline(v=vertLines, lwd=3, col="gray")
	}
}

