# ---------------------------------------------------------------------
# Book:         XFG
# ---------------------------------------------------------------------
# See also:    DGdecompS VarDGdecomp
# ---------------------------------------------------------------------
# Quantlet:    VaRDGdecompG
# ---------------------------------------------------------------------
# Description: VaRDGdecompG computes the first and second derivatives 
#              with respect to the new risk factors.
# ---------------------------------------------------------------------
# Usage:       r = VaRDGdecompG(l)
# ---------------------------------------------------------------------
# Input:       
# Parameter   l
# Definition  a list with (at least) the following components: 
# 
#             Delta - (m x 1) 'old' first derivatives
# 
#             Gamma - (m x m) 'old' second derivatives
# 
#             B     - (m x m) square root of the covariance matrix,
#                             BB' = Sigma
# ---------------------------------------------------------------------
# Output:      
# Parameter   r
# Definition  a list containing the additional components:
# 
#             delta  - (m x 1) 'new' first derivatives
# 
#             lambda - (m x m) diagonal of the 'new' second derivatives
# ---------------------------------------------------------------------
# Example:
#           Delta  = c(1,2,3)
#   		Gamma  = matrix(1,3,3) + diag(rep(9,3))
#   		B      = diag(rep(1,3))
#   		l      = list()
#           l$Delta = Delta
#           l$Gamma = Gamma
#           l$B     = B
#   		VaRDGdecompG(l)
# ---------------------------------------------------------------------
# Result:      
#           $Delta
#           [1] 1 2 3
#
#           $Gamma
#                [,1] [,2] [,3]
#           [1,]   10    1    1
#           [2,]    1   10    1
#           [3,]    1    1   10
#
#           $B
#                 [,1] [,2] [,3]
#           [1,]    1    0    0
#           [2,]    0    1    0
#           [3,]    0    0    1
#
#           $lambda
#           [1] 12  9  9
#
#           $delta
#                      [,1]
#           [1,] -3.4641016
#           [2,]  1.1716499
#           [3,] -0.7919827
# ---------------------------------------------------------------------
# Keywords:    eigenvalue decomposition, diagonalization
# ---------------------------------------------------------------------
# Reference:   Jaschke, S. (2001). The Cornish-Fisher-Expansion in
#              the Context of Delta-Gamma-Normal Approximations.
# ---------------------------------------------------------------------
# Author:      Awdesch Melzer 20130530
# ---------------------------------------------------------------------
 
VaRDGdecompG = function(l){		 
  e = eigen(t(l$B) %*% l$Gamma %*% l$B)
  r = l
  lambda = e$values
  if (length(r$lambda)==0){
    r$lambda = lambda
  }else{
    r$lambda = lambda
  }
  delta = t((t(l$Delta) %*% l$B) %*% e$vectors)
  if (length(r$delta)==0){	
    r$delta  = delta
  }else{
    r$delta
  } 
return(r)
}
