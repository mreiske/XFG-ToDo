%Reference paper "How to grow a smiling tree" Barle & Cakici

%clear all;
% ******        Enter Input parameters ********
%r=0.03; %annualized risk free rate
%T=5; %no of years
%S=100; %current price
%v=0.1; %annual volatility
%skew=0.0005; % linear increase in implied vol percentage point for decrease in strike
%N=5; %time steps
%****************************************
function [Smat,ADmat,pmat] = XFGIBTcbc(s0, r, t, n);
%s0=para(1);             % Stock price
%r=para(2);              % Riskless interest rate	
%t=para(3);			    % Time to expiration
%n=para(4);              % Number of intervals 

if s0<=0
  disp('IBTdk: Price of Underlying Asset should be positive! Please input again')
  s0=input('s0=');
end
if (r<0 || r>1)
  disp('IBTdk: Interest rate need to be between 0 and 1! Please input again')
    sig=input('r=');
end
if t<=0
  disp('IBTdk: Time to expiration should be positive! Please input again')
   t=input('t=');
end
if n<1
  disp('IBTdk: Number of steps should be at least equal to 1! Please input again')
  n=input('n=');
end
dividend=0; %assume no dividend
%ExerciseType='e'; %consider only european exercise

dt=t/n;
Smat=zeros(n+1,n+1);        % Stock price at nodes
Smat(1,1)=s0;
ADmat=zeros(n+1,n+1);       % Arrow-Debreu prices
ADmat(1,1)=1;
pmat=zeros(n,n);            % Transition probabilites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load simulated data for calculating of option prices (optionprice.m) 
%simdata = load('C:Dokumente und EinstellungenAlena MysickovaEigene DateienStatistikXFGDataXFGIBTmcsimulation20.txt');
global simdata;
K = 100;
C = optionprice(K,s0,r,(1/dt),dt,1);           % Call option price
sigma = blsimpv(K,s0,r,1,C)                    % ImplVola in XploRe
%sigma = 0.066858;           % Only for S = 100, K = 100, r = 0.03, T = 1, Call = 4.3651, n = 20 
%sigma = 0.095179;           % Only for S = 100, K = 100, r = 0.03, T = 1, Call = 4.3651, n = 50
infl = exp(r*dt);
for i=1:n;
    %infl = 1.05
	%******   Step 1 : Find central nodes of stock tree (EQ 5) *************************
	if mod(i,2)==0;       %(i+1) is odd
        mi=(i/2+1);
		Smat(mi,i+1)=s0*exp(r*dt*i);    %center point price set to spot
        if (Smat(mi,i+1) < infl*Smat(mi-1,i)|| Smat(mi,i+1)>infl*Smat(mi,i))
            Smat(mi, i+1) = infl*(Smat(mi-1,i)+Smat(mi,i))/2;
        end
		lnode=mi;
        llnode=mi;
    else                    % (i+1) is even 
		%let us find the lower node first (EQN 8)
		mi=round((i+1)/2);
		Call_Put_Flag=1;    % 1 for call/0 for put
		S=Smat(mi,i);       % S_n^i
        F =infl*S;           % F_n^i    
        C=optionprice(F,s0,r,i,dt,Call_Put_Flag);
		rho_u=0;
		if (mi+1)<=i;
           rho_u = sum(ADmat(mi+1:i,i).*(infl*Smat(mi+1:i,i)-F));
        end
        Sl = F*(ADmat(mi,i)*F-infl*C+rho_u)/(ADmat(mi,i)*F+infl*C-rho_u);
        Su=F^2/Sl;        % S_{n+1}^i = S^2/S_{n+1}^{i+1}
    %%%%%%% Compensation %%%%%%%%
        if (Su < F || Sl>F)
            Su = sqrt(F^3/Smat(mi-1,i));
            Sl = F^2/Su;
        end    
        if (mi<i) && (mi>1);
            if (Su>infl*Smat(mi+1,i)||Sl<infl*Smat(mi-1,i));
                Su = sqrt(F^3/Smat(mi-1,i));
                Sl = F^2/Su;
            end
            if (Su>infl*Smat(mi+1,i)||Su<infl*S);
                Su = infl*(S+Smat(mi+1,i))/2;
            end
            if (Sl > infl*S||Sl<infl*Smat(mi-1,i));
                Sl = infl*(S+Smat(mi-1,i))/2;
            end
         end
       Smat(mi+1,i+1) = Su;
       Smat(mi,i+1) = Sl;
        lnode=mi+1;
        llnode=mi;	
    end%if

	%******   Step 2 : Find upper nodes of stock tree (EQ 1.12) *************************
	for j=(lnode+1):1:(i+1);
		Call_Put_Flag=1;            % Call price
		S=Smat(j-1,i);                % S_n^i, i=j-1, i^1 = j
        F = infl*S;                   % F_n^i   
		C=optionprice(F,s0,r,i,dt,Call_Put_Flag);
		rho_u=0;
		%for k=1:j-1,
		%	tmpsum=tmpsum+ADmat(k,i)*(exp(r*dt)*Smat(k,i)-Smat(j,i));
		%end
        if j<=i
            rho_u = sum(ADmat(j:i,i).*(infl*Smat(j:i,i)-F));
        end
        dc = C*infl-rho_u;
		Su = (Smat(j-1,i+1)*(dc)-ADmat(j-1,i)*F*(F-Smat(j-1,i+1)))/(dc-ADmat(j-1,i)*(F-Smat(j-1,i+1)));
        %%%% Compensation %%%%%%%
        if j<=i
           if (Su > infl*Smat(j,i) || Su< infl*S); 
               Su = infl*(Smat(j,i)+S)/2;
           end
        else
            if Su > S*exp(2*sigma*sqrt(dt))|| Su< F;
                Su = S*Smat(j-1,i+1)/Smat(j-2,i);
            end
        end    
       Smat(j,i+1) = Su; 
	end
	
	%******   Step 3 : Find lower nodes of stock tree (EQ 9) *************************
	for j=(llnode-1):-1:1
		Call_Put_Flag=0;
		S=Smat(j,i);                % S_n^i
        F=S*infl;                   % F_n^i
		P=optionprice(F,s0,r,i,dt,Call_Put_Flag);
		if j>1
            rho_l = sum(ADmat(1:j-1,i).*(F-infl*Smat(1:j-1,i)));    
        else
            rho_l=0;
        end
		dc = infl*P-rho_l;
        Sl = (ADmat(j,i)*F*(Smat(j+1,i+1)-F)-dc*Smat(j+1,i+1))/(ADmat(j,i)*(Smat(j+1,i+1)-F)-dc);
		%Sl2=(Smat(j+1,i+1)*(dc)-ADmat(j,i)*F*(Smat(j+1,i+1)-F))/(dc-ADmat(j,i)*(Smat(j+1,i+1)-F))
        %%%%%% Compensation %%%%%%%%%
        if (j>1)
            if (Sl < infl* Smat(j-1,i) || Sl > infl * S);
                Sl = infl* (Smat(j-1,i)+S)/2;
            end
        else
            if(Sl>infl*S || Sl< S*exp(-2*sigma*sqrt(dt)));
                Sl = S* Smat(j+1,i+1)/Smat(j+1,i);
            end
        end
        Smat(j,i+1) = Sl;
	end
	
	%******   Step 4 : Find nodes of probability and Arrow Debreu tree *************************
	pmat(1,1) = (infl*Smat(1,1)-Smat(1,2))/(Smat(2,2)-Smat(1,2));
    if i > 1
       pmat(1:i,i)= (infl.*Smat(1:i,i)-Smat(1:i,i+1))./(Smat(2:i+1,i+1)-Smat(1:i,i+1));
    end
    %%%%%%% Arrow-Debreu Prices %%%%%
    ADmat(1,i+1)=ADmat(1,i)*(1-pmat(1,i))./infl;    % lambda_{n+1}^{0}
    if i>1
        ADmat(2:i,i+1) = (ADmat(2:i,i).*(1-pmat(2:i,i))+ADmat(1:i-1,i).*pmat(1:i-1,i))./infl;
    end
    ADmat(i+1,i+1)=ADmat(i,i)*pmat(i,i)./infl;  % lambda_{n+1}^{n+1}
end

%'implied stock tree n'
%disp(Smat);

%'transition probability tree n'
%disp(pmat);
%disp(pp);

%'arrow debreu price tree n'
%disp(ADmat);
