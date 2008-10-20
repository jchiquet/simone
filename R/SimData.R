## __________________________________________________________
##
## SimConnectivity
##
## INPUT
##	Q : scalar : number of classes
##	lambda : intra-class connectivity
##	epsilon : inter-class connectivity
##	dustbin : should a theoretic dustbin class be added ?
##
## OUTPUT :
##	Connectivity matrix pi
## __________________________________________________________
##
SimConnectivity <- function (Q, lambda, epsilon, dustbin=FALSE) {

  if (dustbin) {
    size = Q + 1
    my.names <- c(1:Q, "D")
  } else {
    size = Q
    my.names <- c(1:Q)
  }
  
  pi <- matrix( epsilon, nrow=size, ncol=size)
  diag(pi) <- lambda
  
  if (dustbin==TRUE) {
    pi[size, ] <- pi[ , size] <- 0
  }
  
  rownames(pi) <- colnames(pi) <- my.names 
  
  return(pi)
}

## __________________________________________________________
##
## SimK
##
## INPUT : 
##	A : adjacency matrix
##
## OUTPUT :
##	a symmetric precision matrix
##
## Simulate a precision matrix from an adjacency matrix
## __________________________________________________________
##
SimPrecMat <- function (A, eps=.01) {
  p <- nrow(A)
  
  ## K = Sigma^{-1}
  K <- matrix(0,p,p)

  ## indexes of non-null values in the upper part of the matrix
  IndSup <- which( abs(A * upper.tri(A))>0 )

  ## Fill the upper part of the matrix with correlated variables
  K[IndSup] <- 1 * (-1) ^ rbinom(length(IndSup), 1, 0.5)
  
  ## Symmetrize matrix
  K <- Symmetrize(K)
  
  ## Fill the diagonal with "heavy" values, ensuring inversability
  K <- K + diag( rowSums(abs(K))+eps )
  
  ## Normalize to have diag(K) = ones
  K <- diag(sqrt(diag(K)^-1)) %*% K %*% t(diag( sqrt(diag(K)^-1)))

  return(K)
}

## __________________________________________________________
##
## SimGaussianVector
##
## INPUT :
## 	n : the size of the sample
##	means : a vector of mean values
##	Sigma : the p x p covariance matrix
## OUTPUT :
##	n x p matrix
##
## Simulate a n-sample of a multivariate gaussian random vector
## __________________________________________________________
##
SimGaussianVector <- function (n, Sigma, means=rep(0,dim(Sigma)[1])) {

  p <- nrow(Sigma)
  
  ## t(C) %*% C = Sigma
  C <- chol(Sigma)
  
  ## Simulate a n-sample of a Gaussian randm vector Y, such that
  ## Y = mu + C' * Z, where Z is an i.i.d. p-sample of a N(0,1)
  Y <- means %*% t(rep(1,n)) + t(C) %*% matrix(rnorm(n*p),p,n)
  
  return(t(Y))
}

## __________________________________________________________
##
## SimDataAffiliation
##
##     lambda    : intra-class connectivity
##     epsilon   : inter-class connectivity
##     alpha : prior class proportions (*)
##     dust.prop : dustbin class proportion (*)
##     (*) class proportions are internally  normalised to sum to 1
##     p : number of nodes (e.g. genes) in the graph (e.g. regulation network)
##     n : sample size
##     l.bound, ubound : scalar bounds on precision matrix edge weights
##
## OUTPUT : list :
##	cl.theo : theoretic node classification vector
##	K.theo : theoretic precision matrix
##	Sigma.theo : theoretic covariance matrix
##	data : sample data (n x p))
##
## Simulate a graph represented by its precision matrix such as nodes
## are clustered into highly connected groups. Simulate the
## corresponding a size-n sample using a gaussian graphical model.
## _________________________________________________________
##

SimDataAffiliation <- function (p, n, proba.in, proba.out, alpha, proba.dust=0) {
  
  ## create connectivity matrix PI
  Q <- length(alpha) # number of classes
  pi  <- SimConnectivity(Q, proba.in, proba.out, dustbin = (proba.dust>0))
  
  ## add the dustbin classe and normalize the proportions
  if (proba.dust>0) {
    alpha <- matrix(c(alpha*abs(sum(alpha)-proba.dust), proba.dust))
  } else {
    alpha <- matrix(alpha)
  }
  alpha <- alpha/sum(alpha)
  rownames(alpha) <- rownames(pi)
  
  ## simulate node class belonging
  Z <- t(rmultinom(p, 1, alpha))
  if (!is.null(rownames(alpha))) {
    colnames(Z) <- rownames(alpha)
  }
  cl.theo <- apply(Z,1,which.max)

  ## simulate a symmetric adjacency matrix
  A <- matrix(0,p,p)
  for (i in 2:p) {
    for (j in 1:(i-1)) {
      A[i,j] <- rbinom(1, 1, pi[cl.theo[i], cl.theo[j]])
      A[j,i] <- A[i,j]
    }
  }
  
  ## simulate inverse covariance matrix
  K.theo <- SimPrecMat(A)
  ## Remove dustbin nodes generated by simulation
  if (!("D" %in% levels(cl.theo))) {
    levels(cl.theo) <- c(levels(cl.theo), "D")
  }
  deg <- CalcDegrees(K.theo)
  cl.theo[deg<=.Machine$double.xmin] <- "D"
  cl.theo <- factor(cl.theo)
  
  ## simulate covariance matrix
  Sigma.theo  <- cov2cor(solve(K.theo))

  ## simulate data matrix
  data  <- SimGaussianVector(n, Sigma.theo)

  # node names
  rownames(K.theo) <- colnames(K.theo)  <- rownames(Sigma.theo) <- 
    colnames(Sigma.theo)  <- colnames(data) <- as.character(1:p)
  
  return(list(data    	 = data,
              K.theo 	 = K.theo,
              Sigma.theo = Sigma.theo,
              cl.theo	 = cl.theo))
}

## __________________________________________________________
##
## Symmetrize
##
## Fill the lower part of a square matrix according to its
## upper part, thus making this matrix symmetric
## __________________________________________________________
##
Symmetrize <- function (X) {

  n <- dim(X)[1]
  for (j in 1:n) X[j:n, j] <- X[j, j:n]

  return(X)
}

## __________________________________________________________
##
## CalcDegrees
##
## INPUT : 
##	K : precision matrix
## OUTPUT :
##	vector of node degrees
## __________________________________________________________
##
CalcDegrees <- function (K) {

  K <- as.matrix(K)
  diag(K) <- 0

  return(colSums(abs(K)))
}