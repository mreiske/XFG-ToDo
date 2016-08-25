# ---------------------------------------------------------------------
# Book         XFG
# ---------------------------------------------------------------------
# See also:    -
# ---------------------------------------------------------------------
# Quantlet:    StandardNormalCharf
# ---------------------------------------------------------------------
# Description: StandardNormalCharf computes the characteristic function  
#              of a one-dimensional normally distributed random variable.
# ---------------------------------------------------------------------
# Usage:       r = StandardNormalCharf(t,l)
# ---------------------------------------------------------------------
# Input:       
# Parameter   t
# Definition   	scalar, complex number indicating the point at which the
#		characteristic function should be calculated
# Parameter   l
# Definition  	list, containing l$mu (the expectation) and l$sigma 
#		(the standard deviation) of the Standard Normal Distribution
# ---------------------------------------------------------------------
# Output:      
# Parameter   r
# Definition  	scalar, complex number representing the value of the 
#		characteristic function at t
# ---------------------------------------------------------------------
# Example:
#        mu = 0
#        sigma = 1
#        l = list(mu=mu,sigma=sigma)
#        t = compl(1,1)
#        StandardNormalCharf(t,l)
# ---------------------------------------------------------------------
# Result:	Contents of r$re
# 		[1,]   0.5403
# 		Contents of r$im
# 		[1,] -0.84147
# ---------------------------------------------------------------------
# Keywords:    	normal, normal distribution, characteristic function
# ---------------------------------------------------------------------
# Author:      	Awdesch Melzer 20130604
# ---------------------------------------------------------------------

#################### SUBROUTINES ####################

compl = function (re, im){ # Complex array generation
       if(missing(re)){
  	       stop("compl: no composed object for real part")
       }
       if(missing(im)){
  	       im = 0*(re<=Inf)
       }
       if(nrow(matrix(re))!=nrow(matrix(im))){
  	       stop("compl: dim(re)<>dim(im)")
       }
       z = list()
       z$re = re
       z$im = im
       return(z)
  }
  cmul = function(x, y){ # Complex multiplication
       re   = x$re*y$re - x$im*y$im  
       im   = x$re*y$im + x$im*y$re
       z    = list()
       z$re = re
       z$im = im  
       return(z)
  }
  cexp = function(x){ # Complex exponential
       re = exp(x$re) * cos(x$im) 
       im = exp(x$re) * sin(x$im) 
       z    = list()
       z$re = re
       z$im = im  
       return(z)
  }

#################### MAIN FUNCTION ####################

StandardNormalCharf = function(t,l){
  s2  = l$sigma^2
  tmp = compl(-0.5*s2*t$re,-0.5*s2*t$im + l$mu)
  r   = cexp(cmul(tmp,t))
  return(r)
}

