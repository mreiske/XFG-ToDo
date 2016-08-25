# ---------------------------------------------------------------------
# Book:        XFG
# ---------------------------------------------------------------------
# See also:    VaRcumulantsDG
# ---------------------------------------------------------------------
# Quantlet:    VaRcumulantDG
# ---------------------------------------------------------------------
# Description: VaRcumulantDG computes the n-th cumulant for the class 
#              of quadratic forms of Gaussian vectors.
# ---------------------------------------------------------------------
# Usage:       c = VaRcumulantDG(n,l)
# ---------------------------------------------------------------------
# Input:       
# Parameter    n
# Definition   scalar, order of the required cumulant# n=1 is the mean
# Parameter    l
# Definition   a list defining the distribution# contains at least the
#              components:
# 
#              theta - the constant term
# 
#              delta - the linear term
# 
#              lambda - the diagonal of the quadratic term 
# ---------------------------------------------------------------------
# Output:      
# Parameter    c
# Definition   scalar, the n-th cumulant
# ---------------------------------------------------------------------
# Notes:       This function requires the eigenvalue decomposition that
#              diagonalizes the quadratic term. VaRcumulantsDG computes
#              the first n cumulants without need for the initial 
#              diagonalization. 
# ---------------------------------------------------------------------
# Example:
#   		theta      = 0
#   		delta      = c(1)
#   		lambda     = c(1)
#   		par        = list()
#           par$delta  = delta
#           par$lambda = lambda
#           par$theta  = theta
#   		VaRcumulantDG(3,par)
# ---------------------------------------------------------------------
# Result:
# 		Contents of c
# 		[1,]        4 
# ---------------------------------------------------------------------
# Keywords:   cumulant, Delta-Gamma-models
# ---------------------------------------------------------------------
# Reference:  Jaschke, S. (2001). The Cornish-Fisher-Expansion in
#             the Context of Delta-Gamma-Normal Approximations.
# ---------------------------------------------------------------------
# Link:       http://www.jaschke-net.de/papers/CoFi.pdf Cornish-Fisher-Expansion
# ---------------------------------------------------------------------
# Author:     Awdesch Melzer 20130601
# ---------------------------------------------------------------------

VaRcumulantDG = function(n, l){
  if ( n == 1 ) {
    c = l$theta + 0.5*sum(l$lambda)              
    
  }else if( n == 2 ){
    c = 0.5 *sum(l$lambda^2 + 2*l$delta^2)       
  }else{
    c = 0.5 * factorial(n-1)* sum(l$lambda^n + n*l$delta^2 * l$lambda^(n-2))
  }
  return(c)
}