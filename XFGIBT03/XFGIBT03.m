%%%simdata = load('C:Dokumente und EinstellungenAlena MysickovaEigene DateienStatistikXFGDataXFGIBTmcsimulation50.txt');
  %%%simdata = load('C:DokumentyStatistikXFGDataxfgibtmcsimulation20.txt');
  %simd = load('C:ProgrammeMDTechXploRedataxfgXFGIBTmcsimulation20.dat');
  %global simdata;  
%//Monte-Carlo simulation samples for S_{t}, t=i/4 year, i=1,...20,
%//each S_{t} has 1000 samples included in IBTmcsimulation20.dat   
  r=0.03            %interest rate
  S=100             %current stock price
  lev=40            %the number of time steps
  expiration=5          %time to expiration(year)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simdata = zeros(lev,1000);
for j=1:1000
     simdata(:,j) = Eulerscheme(lev,(expiration/lev),r,S);
end
simdata = reshape(simdata',(lev*1000),1);
global simdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct the IBT using Derman and Kani method
  [St,AD,p]=XFGIBTcdk(S,r,expiration,lev);
  datdk=[St(:,end) (AD(:,end)*exp(r*expiration))];
  in = find(datdk(:,2)>0.0005);
  %datdk=datdk(in,:);
  bandwidth=20;
% get the SPD estimation from the IBT
  mhdk=IBTsdisplot(datdk, bandwidth);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct the IBT using Barle and Cakici method
  [St2,AD2,p2]=XFGIBTcbc(S,r,expiration,lev);
  datbc=[St2(:,end) (AD2(:,end)*exp(r*expiration))];
  in2 = find(datbc(:,2)>0.0005);
  %datbc=datbc(in2,:);
  bandwidth=20;
% get the SPD estimation from the IBT
  mhbc=IBTsdisplot(datbc, bandwidth);
  %slast=simdata(1+49000:50000,:)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the SPD estimation from the Monte-Carle simulation samples
slast=simdata(1+19000:20000,:);
qua = @(u) 15/16.*((1-u.^2).^2).*(abs(u)<=1);
%[fh, xi] = ksdensity(slast, 'width', h, 'kernel', qua)%, 'support', [85
%175]);                 %fh and xi identical with fh2 and xi2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% compute bounds uniform confidence bands with prespecified  
%%% confidence level for univariate density estimation see dencb.xpl    
  [n,m] = size(slast);
  mx= min(slast);
  rx= max(slast)-min(slast);
  h = 20;
  cK=5/7;           % just for quartic kernel
  c2=1.5;           % just for quartic kernel
  alpha = 0.05;
  s = (slast-mx)./rx;
  h = h./rx;
  [fh2, xi2] = ksdensity(s, 'width', h, 'kernel', qua);
  rr = sqrt(-2*log(h));
  dn = rr + 0.5*log( c2/(2*(pi^2)) )/rr;
  calpha = -log(-log(1-alpha)/2);
%  
  mrg = (calpha/rr + dn) .* sqrt(cK.*fh2/(n*h));
  xi2 = (rx.*xi2 + mx);
  clo = ((fh2 - mrg)/rx);
  cup = ((fh2 + mrg)/rx);
  fh2  = (fh2/rx);
 
plot(mhdk(:,1),mhdk(:,2),'-.b','LineWidth',3);
hold on
plot(mhbc(:,1),mhbc(:,2),'--k','LineWidth',3);
%%plot(xi,fh,'-r','LineWidth',2);
plot(xi2,fh2,'-r','LineWidth',3);
plot(xi2,clo,':r','LineWidth',2);
plot(xi2,cup, ':r','LineWidth',2);
title('Estimated State Price Density');
xlabel('Stock Price');
ylabel('Probability');
set(gca,'YTick',0:0.005:0.1);
set(gca,'YLim',[0 0.03]);
set(gca,'XLim',[40 180]);
%legend('Derman & Kani', 'Barle & Cakici')%, 'MC simulation', '95% confidence bands');
hold off