# ---------------------------------------------------------------------
# Book:        XFG
# ---------------------------------------------------------------------
# See also:    VaRcumulantDG
# ---------------------------------------------------------------------
# Quantlet:    VaRcumulantsDG
# ---------------------------------------------------------------------
# Description: VaRcumulantsDG compute the first n cumulants for the class 
#              of quadratic forms of Gaussian vectors.
# ---------------------------------------------------------------------
# Usage:       r = VaRcumulantsDG(n,l)
# ---------------------------------------------------------------------
# Input:       
# Parameter    n
# Definition   scalar, highest order of cumulants to be computed
# Parameter    l
# Definition   a list defining the distribution# contains at least the
#              following components:
# 
#              theta - the constant term
# 
#	           Delta - the linear term (the first derivative)
# 
# 	           Gamma - the quadratic term (the Hessian matrix)
# 
#              Sigma - the covariance matrix
# ---------------------------------------------------------------------
# Output:      
# Parameter    r
# Definition   n x 1 vector of the first n cumulants
# ---------------------------------------------------------------------
# Notes:       This function does not need the initial diagonalization.
#              If the diagonalization has been done already, use 
#              VaRcumulantDG, which is faster.
# ---------------------------------------------------------------------
# Example:     
#           theta = 0
#           Delta = c(1)
#           Gamma = diag(rep(1,1))
#           Sigma = diag(rep(1,1))
#           par   = list()
#           par$theta = theta
#           par$Delta = Delta
#           par$Gamma = Gamma
#           par$Sigma = Sigma
#           VaRcumulantsDG(4,par)
# ---------------------------------------------------------------------
# Result:
# 		Contents of r
# 		[1,]      0.5 
# 		[2,]      1.5 
# 		[3,]        4 
# 		[4,]       15 
# ---------------------------------------------------------------------
# Keywords:    cumulant, Delta-Gamma-models
# ---------------------------------------------------------------------
# Reference:   Jaschke, S. (2001). The Cornish-Fisher-Expansion in
#              the Context of Delta-Gamma-Normal Approximations.
# ---------------------------------------------------------------------
# Link:        http://www.jaschke-net.de/papers/CoFi.pdf Cornish-Fisher-Expansion
# ---------------------------------------------------------------------
# Author:      Awdesch Melzer 20130601
# ---------------------------------------------------------------------

VaRcumulantsDG = function(n, l){
  # Uses just matrix multiplication, a more sophisticated implementation
  # would use a Hessenberg decomposition for higher n.
  r    = matrix(1,n,1)
  GS   = l$Gamma %*% l$Sigma
  r[1] = l$theta + 0.5 * sum(diag(GS)) 
  if ( n >= 2 ){
    GSk  = GS %*% GS             
    SD   = l$Sigma %*% l$Delta
    r[2] = 0.5 * ( sum(diag(GSk)) + 2*sum(SD * l$Delta) ) 
  }
  if ( n >= 3 ){
    GSkm2D = l$Delta
    k = 3
    while ( k <= n ){
      GSk   = GSk %*% GS
      GSkm2D= GS  %*% GSkm2D  # (GS)^(k-2) Delta
      r[k]  = 0.5 * factorial(k-1) * ( sum(diag(GSk)) + k*sum(SD * GSkm2D))
      k     = k+1
    }
  }
  return(r)
}