# ---------------------------------------------------------------------
# Book:         XFG
# ---------------------------------------------------------------------
# See also:     VaRDGdecomp
# ---------------------------------------------------------------------
# Quantlet:     DGdecompS
# ---------------------------------------------------------------------
# Description:  DGdecompS computes the square root of a positive semi-definite
#               matrix, using an eigen value decomposition
# ---------------------------------------------------------------------
# Usage         B = DGdecompS(Sigma)
# ---------------------------------------------------------------------
# Input       
# Parameter     Sigma
# Definition  	p x p positive semi-definite matrix containing user-defined
#               data.
# Output      
# Parameter     B
# Definition:   p x p matrix containing the square root of Sigma.
#               Note that the solution is non-unique. B solves the equation: 
#               BB' = Sigma.
# ---------------------------------------------------------------------
# Notes:       	Square roots of matrices can also be computed by the Cholesky
#               decomposition, which only works for positive definite
#             	matrices, but which is faster.
# ---------------------------------------------------------------------
# Example:  
#           Sigma = matrix(1,3,3) + diag(rep(10,3))	
#           B     = DGdecompS(Sigma)
#           B
#           B%*%t(B)
# ---------------------------------------------------------------------
# Result: 
#       Contents of B
#                   [,1]      [,2]     [,3]
#       [1,]  2.24135730 -1.281789 2.081666
#       [2,] -2.23074085 -1.300178 2.081666
#       [3,] -0.01061645  2.581967 2.081666
#		
#       Contents of B%*%t(B)
#            [,1] [,2] [,3]
#       [1,]   11    1    1
#       [2,]    1   11    1
#       [3,]    1    1   11
# ---------------------------------------------------------------------
# Keywords:    	Cholesky decomposition, square root matrix, 
#             	eigen value decomposition
# ---------------------------------------------------------------------
# Author:      	Awdesch Melzer 20130530
# ---------------------------------------------------------------------

DGdecompS = function(Sigma){

  e = eigen(Sigma)
  e$values = 0.5*(abs(e$values) + e$values)   # cancel negative eigenvalues
  B = e$vectors %*% diag(sqrt(e$values))
  if (any(B[,1]<0)){
  	B[,1]=B[,1]*sign(B[,1])
  }
  n = nrow(B)
  BB = B[1:n,n:1]
return(BB)

}