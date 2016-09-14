% -----------------------------------------------------------------
% Library        smoother
% -----------------------------------------------------------------
% See_also       regxci regxcb regest regxbwsel lpregxest regxestp 
% -----------------------------------------------------------------
% Macro          regxest
% -----------------------------------------------------------------
%  Keywords      kernel smoothing, kernel regression, 
%                Nadaraya-Watson estimator, nonparametric regression
% -----------------------------------------------------------------
% Description    computes the Nadaraya-Watson estimator for 
%                univariate regression. 
% -----------------------------------------------------------------
% Notes          This function does an exact computation, i.e.,
%                requires O(n^2) operations for estimating the 
%                regression function on all observations. For
%                exploratory purposes, the quantlet "regest" is
%                recommended, which uses the faster WARPing method.
% -----------------------------------------------------------------
% Reference      Haerdle, W. (1990). Applied Nonparametric Regression.
%		 Econometric Society Monographs, No. 19. Cambridge
%		 University Press.
% -----------------------------------------------------------------
% Usage        mh = regxest(x {,h {,K} {,v} })
%  Input
%    Parameter  x  
%    Definition   n x 2 matrix, the data. The first column contains the
%                 independent and the second column the
%                 dependent variable.
%    Parameter  h 
%    Definition   optional scalar, bandwidth. If not given, 20% of the
%                 range of x[,1] is used as default.
%    Parameter  K  
%    Definition   optional string, kernel function on [-1,1] or Gaussian
%                 kernel "gau". If not given, the Quartic kernel
%                 "qua" is used as default.
%    Parameter  v  
%    Definition   optional m x 1 vector, values of the independent variable on 
%                 which to compute the regression. If not given, 
%                 the (sorted) x is used as default.
%  Output
%    Parameter  mh  
%    Definition   n x 2 or m x 2 matrix, the first column represents the 
%                 sorted first column of x or the sorted v and the 
%                 second column contains the regression estimate  
%                 on the values of the first column.
% -----------------------------------------------------------------

function[mh]=regxest(x,h,K)
[n,m]=size(x);
  if m ~= 2
    disp('regxest: data matrix must contain 2 columns');
    disp('Please input the data matrix again');
    dat = input('x=');
  end
;
eh = exist('h');
  if (eh == 0)
    %h=(max(x(:,1))-min(x(:,1)))/5;
    h = 2.42*std(x(:,1))*n^(-0.2);
  end
eK = exist('K');
  if (eK == 0)
    K=1;        %quartic kernel
  else
      if K == 0 || K >4
        disp('Type of the kernel must be "1", "2", "3" or "4"');
        disp('The quartic kernel will be used');
        K = 1;
      end  
  end
;
  tmp=sortrows(x)
  x=tmp(:,1);
  y=tmp(:,2);
  %if (exist(v)==0)
  %  v=x
  % else
  %  v=sort(v)
  % endif
;
% require nw (Nadaraya-Watson) function / toolbox
    for i = 1:n  
        s(i,1)= nw(x(i),x,y,h,K)./nw(x(i),x,ones(n,1),h,K);
    end
    %for i = 1:n  % Gaussian kernel
     %   s(i,1)= nw(x(i),x,y,5*h,K)./nw(x(i),x,ones(n,1),5*h,K)
    %end
    mh=[x s];