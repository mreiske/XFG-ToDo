# ---------------------------------------------------------------------
# XFG:         VaR
# ---------------------------------------------------------------------
# See also:    VaRcharfDGF2, VaRcdfDG
# ---------------------------------------------------------------------
# Quantlet:    VaRcorrfDGF2
# ---------------------------------------------------------------------
# Description: computes the cumulative distribution function (CDF) of
#              an approximated normal distribution for the class of
#              quadratic forms of Gaussian vectors.
# ---------------------------------------------------------------------
# Usage:       r = VaRcorrfDGF2(x,l)
# ---------------------------------------------------------------------
# Input:       
# Parameter   x
# Definition  the argument to the CDF
# Parameter   l
# Definition  a list defining the distribution; contains at least the
#             components:
#  
#             theta - the constant
#  
#             delta - the linear term
#  
#             lambda - the diagonal of the quadratic term
# ---------------------------------------------------------------------
# Output:      
# Parameter   r
# Definition  the value of the approximated normal CDF at x
# ---------------------------------------------------------------------
# Notes:       This is an auxiliary function to the quantlet VaRcdfDG.
# ---------------------------------------------------------------------
# Example:    
#  	     theta  = 0
#        delta  = c(1)
#  	     lambda = c(1)
#	     par    = list(theta=theta,delta=delta,lambda=lambda)
#	     VaRcorrfDGF2(c(-1,0,1),par)
# ---------------------------------------------------------------------
# Result:      
# 		Contents of r
#          [,1]
#     [1,] 0.1103357
#     [2,] 0.3415457
#     [3,] 0.6584543
# ---------------------------------------------------------------------
# Keywords:     normal approximation, Delta-Gamma-models
# ---------------------------------------------------------------------
# Author:       Awdesch Melzer 20130604
# ---------------------------------------------------------------------

VaRcorrfDGF2 = function(x,l){ # cdf of normal approximation
  mu = l$theta + 0.5*sum(l$lambda)
  s2 = sum(l$delta^2 + 0.5*l$lambda^2)
  r  = pnorm((x-mu)/sqrt(s2))
return(r)
}

#################### TEST ######################

         theta  = 0
         delta  = c(1)
         lambda = c(1)
         par    = list(theta=theta,delta=delta,lambda=lambda)
         VaRcorrfDGF2(c(-1,0,1),par)


