generate.ortho.modes = function(X, Y, 
                                M = 1,
                                method = "simpls",
                                verbose = TRUE)
  # Generate orthogonal modes that are driven by some response variables.
  #
  #   Z = generate.ortho.modes(X, Y, 
  #                            M = 1,
  #                            method = "simpls",
  #                            verbose = TRUE )
  #
  # Inputs: 
  #   - X is N-by-P predictor variables
  #   - Y is N-by-K response variables
  #   - M is number of components to use in the PLS regression
  #
  # Output: Z is a list that contains modes and scores.
  #
  # Optional arguments:
  #   - method is the PLS regression method. See pls::plsr command.
  #   - verbose is a flag to output more information.
  #
  # Author: Avan Suinesiaputra - 2016
{
  require(pls)
  
  stopifnot( nrow(X)==nrow(Y) )
  
  # get dimensions
  N = nrow(X)
  P = ncol(X)
  K = ncol(Y)
  
  stopifnot( M<=P )
  
  # compute mean
  mean.X = colMeans(X)
  
  # initial B0
  X0 = X - matrix(rep(mean.X,N), nrow=N, byrow=TRUE)
  
  # store BETAS and SCORES
  BETA = matrix(data=0, nrow=P, ncol=K)
  SCORE = matrix(data=0, nrow=N, ncol=K)
  
  # initial Xi
  Xi = X0;
  
  # iterate
  for( i in c(1:K) )
  {
    if( verbose ) { message(sprintf("Processing mode %d", i)) }
    
    # estimate PLS regression coefficients
    PLS = plsr(Y[,i] ~ Xi, M, method=method)
    
    # get the beta vector, exclude the intercept
    BETA[,i] = coef(PLS)
    
    # normalise BETA
    BETA[,i] = BETA[,i] / norm(BETA[,i], type="2")
    
    # calculate the projection, which we call it as SCORE
    # Note that this projection is not the same as Y prediction, because the BETA
    # has been normalised. And this SCORE is only used for visualizing back the
    # mode of shape variations
    SCORE[,i] = X %*% BETA[,i]
    
    if( verbose ) { message("Removing contribution") }
    
    # remove the contribution of the current Y from the Xi
    X1 = matrix(data=0, nrow=nrow(X0), ncol=ncol(X0))
    for( j in c(1:i) )
    {
      X1 = X1 + ( (X0 %*% BETA[,j]) %*% t(BETA[,j]) )
    }
    
    # update the current Xi
    Xi = X0 - X1;
    
  }
  
  # producing output
  list(
    modes = BETA,
    scores = SCORE
  )
  
}
