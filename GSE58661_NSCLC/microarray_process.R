#######
# Data description and download: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE58661
#######
setwd("/srv/gevaertlab/data/Hong/microarray/GSE58661_NSCLC/raw")

#######
# Make chip definition file (CDF)
# GPL15048_HuRSTA_2a520709.CDF is downloaded together with CEL files, It can also be found in https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GPL15048
#######
library(makecdfenv)
make.cdf.package("GPL15048_HuRSTA_2a520709.CDF", species = "homo_sapiens")

#! This step is executed in command line
#! R CMD INSTALL gpl15048hursta2a520709cdf 

#######
# Read in CEL files
#######
library(affy)
eset<-ReadAffy(cdfname="gpl15048hursta2a520709cdf")
eset.rma<-rma(eset)
expression<-exprs(eset.rma)

#######
# Annotate probes
#######
probeID<-as.data.frame(rownames(expression))
names(probeID)<-"ID"

GPL15048<-read.table("/srv/gevaertlab/data/Hong/microarray/GSE58661_NSCLC/GPL15048/GPL15048_family.soft.ID.expr",sep="\t",head=T)
GPL15048.IDs<-GPL15048[,1:4]
library(dplyr)
probeID.anno<-left_join(x=probeID,y=GPL15048.IDs,by="ID")

#######
# Get expression for genes
#######
expression.anno<-cbind(probeID.anno,expression)
expression.anno[expression.anno == ""] <- NA
expression.anno<-expression.anno[!is.na(expression.anno$GeneSymbol),]
genes<-as.matrix(sort(unique(expression.anno$GeneSymbol)))

expression.gene<-NULL
for(i in 1:nrow(genes))
{
expression.gene<-rbind(expression.gene,c(genes[i],colMeans(expression.anno[(expression.anno$GeneSymbol==genes[i]),5:ncol(expression.anno)])))
}

colnames(expression.gene)[1]<-"gene"
write.table(expression.gene,file="../expression.gene.txt",quote = F, row.names = F, sep="\t")


#######
# Get expression for genes, alternative approach
#######
GPL15048.subset<-GPL15048[, c("ID","GeneSymbol",(read.table(text=colnames(expression.gene)[2:ncol(expression.gene)],as.is=T,sep="_"))$V1)]

GPL15048.subset[GPL15048.subset == ""] <- NA
GPL15048.subset<-GPL15048.subset[!is.na(GPL15048.subset$GeneSymbol),]
genes<-as.matrix(sort(unique(GPL15048.subset$GeneSymbol)))

expression.gene.alt<-NULL
for(i in 1:nrow(genes))
{
  expression.gene.alt<-rbind(expression.gene.alt,c(genes[i],colMeans(GPL15048.subset[(GPL15048.subset$GeneSymbol==genes[i]),3:ncol(GPL15048.subset)])))
}

colnames(expression.gene.alt)[1]<-"gene"


