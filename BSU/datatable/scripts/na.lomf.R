na.lomf <- function(x) {
    
    na.lomf.0 <- function(x) {
        non.na.idx <- intersect(which(!is.na(x)),which(x>0))
        if (is.na(x[1L]) || x[1L]==0) {
            non.na.idx <- c(1L, non.na.idx)
        }
        rep.int(x[non.na.idx], diff(c(non.na.idx, length(x) + 1L)))
    }
    
    dim.len <- length(dim(x))
    
    if (dim.len == 0L) {
        na.lomf.0(x)
    } else {
        apply(x, dim.len, na.lomf.0)
    }
}

na.lomf_L <- function(x) {
    
    non.na.idx <- intersect(which(!is.na(x)),which(x[length(x)-1]>0))
    if (is.na(x[length(x)]) || x[length(x)]==0) {
        XX<-c(x[1:length(x)-1], rep.int(x[length(x)-1], 1))
    } else {
        XX<-x
    }
    
}
