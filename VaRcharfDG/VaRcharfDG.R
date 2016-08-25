# ---------------------------------------------------------------------
# Book:        XFG
# ---------------------------------------------------------------------
# See also:    VaRcharfDGF2
# ---------------------------------------------------------------------
# Quantlet:    VaRcharfDG
# ---------------------------------------------------------------------
# Description: VaRcharfDG computes the characteristic function for the
#              class of quadratic forms of Gaussian vectors.
# ---------------------------------------------------------------------
# Usage:       r = VaRcharfDG(t,par)
# ---------------------------------------------------------------------
# Input:
# Parameter   t
# Definition  the complex argument to the cgf
# Parameter   par
# Definition  a list defining the distribution# contains at least the
#             following components: 
# 
#              theta - the constant term
# 
#              delta - the linear term
# 
#              lambda - the diagonal of the quadratic term
# ---------------------------------------------------------------------
# Output:
# Parameter   r
# Definition  the value of the cgf at t
# ---------------------------------------------------------------------
# Example:    
#		XFGVaRcharfDGtest = function(par,n,xlim){
#		  compl = function (re, im){ # Complex array generation
#               if(missing(re)){
#                   stop("compl: no composed object for real part")
#               }
#               if(missing(im)){
#                   im = 0*(re<=Inf)
#               }
#               if(nrow(matrix(re))!=nrow(matrix(im))){
#                   stop("compl: dim(re)<>dim(im)")
#               }
#               z = list()
#               z$re = re
#               z$im = im
#               return(z)
#          }
#
#		  dt = (xlim[2]-xlim[1])/(n-1)
#		  t  = xlim[1] + (0:(n-1))*dt
#		  r  = VaRcharfDG(compl(t,t*0),par)    
#		  z1 = cbind(t,r$re)
#		  z2 = cbind(t,r$im)
#		  plot(z1, type="l", col="blue3", lwd=2, ylab="Y",xlab="X",ylim=c(min(r$re,r$im),max(r$re,r$im)))
#		  lines(z2,col="red3", lwd=2)
#		  title("Characteristic function")
#		}
#
#	     theta = 0
#        delta = c(0)
#        lambda = c(1.4142)
#        par        = list()
#        par$theta  = theta
#        par$delta  = delta
#        par$lambda = lambda
#		XFGVaRcharfDGtest(par,300,c(-40,40))
# ---------------------------------------------------------------------
# Result:      Plots the real (blue line) and the imaginary part (red line)
#	           of the characteristic function for a distribution,
#              which is close to a chi^2 distribution with one degree of
#	           freedom.
# ---------------------------------------------------------------------
# Keywords:    characteristic function, Delta-Gamma-models
# ---------------------------------------------------------------------
# Reference:   Jaschke, S. (2001). The Cornish-Fisher-Expansion in
#              the Context of Delta-Gamma-Normal Approximations
# ---------------------------------------------------------------------
# Link:        http://www.jaschke-net.de/papers/CoFi.pdf Cornish-Fisher-Expansion
# ---------------------------------------------------------------------
# Author:      Awdesch Melzer 20130531
# ---------------------------------------------------------------------
 
############################ SUBROUTINES ################################
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
  cdiv = function(x, y) { # Complex division
       w    = y$re^2 + y$im^2
       re   = (x$re*y$re + x$im*y$im) / w  
       im   = (x$im*y$re - x$re*y$im) / w  
       z    = list()
       z$re = re
  	   z$im = im  
       return(z)
  }  
  cln = function(x){ # Complex natural logarithm
       re   = log(x$re^2+x$im^2) / 2
       im   = atan2(x$im, x$re)
       z    = list()
       z$re = re
       z$im = im  
       return(z)
  }
  csub = function(x, y){# Complex subtraction two arrays of complex numbers
       re   = x$re - y$re  
       im   = x$im - y$im
       z    = list()
       z$re = re
       z$im = im  
       return(z)
  }

  
  VaRcgfDG = function(t,par){ # cumulant generating function (cgf) for the 
                              # class of quadratic forms of Gaussian vectors.
  s = compl(par$theta*t$re, par$theta*t$im)

  i = 1
  m = length(par$lambda)
  while (i <= m){
    # 1-lambda*t:
    omlt = compl(1 - par$lambda[i] * t$re,  -par$lambda[i] * t$im)
    tmp  = cmul(t,t)
    tmp  = cdiv(tmp,omlt)
    tmp  = compl(par$delta[i]^2 * tmp$re, par$delta[i]^2 * tmp$im)
    tmp  = csub(tmp,cln(omlt))
    s    = compl(s$re + 0.5*tmp$re, s$im + 0.5*tmp$im)   
    i    = i+1
  }
  return(s)
}

cexp = function(x){ # Complex exponential
       re = exp(x$re) * cos(x$im) 
       im = exp(x$re) * sin(x$im) 
       z    = list()
       z$re = re
       z$im = im  
       return(z)
}

############################ Main Program ############################ 
VaRcharfDG = function(t,par){
  t = compl(-t$im,t$re)                 # 1i*t
  r = cexp(VaRcgfDG(t,par))
}

