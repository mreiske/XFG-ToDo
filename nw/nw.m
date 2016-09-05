function sker=nw(x, vecX, vecY, h, K)   %Nadaraya-Watson Estimator
    vx   = size(x);
    vY   = size(vecY);
    vX   = size(vecX);
    vh   = size((vecX-x)/h');

    sker = 1/h*kernel((vecX-x)./h,K)'*vecY;