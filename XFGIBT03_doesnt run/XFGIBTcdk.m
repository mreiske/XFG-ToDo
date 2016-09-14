function [Smat,ADmat,pmat] = XFGIBTcdk(s0, r, t, n);

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
dt=t/n;
Smat=zeros(n+1,n+1);        % Stock price at nodes
Smat(1,1)=s0;
ADmat=zeros(n+1,n+1);       % Arrow-Debreu prices
ADmat(1,1)=1;
pmat=zeros(n,n);            % Transition probabilites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load simulated data for calculating of option prices (optionprice.m) 
global simdata;
%simdata = load('C:ProgrammeMDTechXploRedataxfgXFGIBTmcsimulation20.dat');

K = 100;
C = optionprice(K,s0,r,(1/dt),dt,1);           % Call option price
sigma = blsimpv(K,s0,r,1,C);                   % Computes BS implied volatility  
%sigma = 0.066858;           % Only for S = 100, K = 100, r = 0.03, T = 1, Call = 4.3651, n = 20 
%sigma = 0.095179;           % Only for S = 100, K = 100, r = 0.03, T = 1, Call = 4.3651, n = 50
infl = exp(r*dt);
for i=1:n;
    %infl = 1.03
	%******   Step 1 : Find central nodes of stock tree (EQ 5) *************************
	if mod(i,2)==0;       %(i+1) is odd
        mi=(i/2+1);
		Smat(mi,i+1)=s0;    %center point price set to spot
        if (s0 < infl*Smat(mi-1,i)|| s0>infl*Smat(mi,i))
            Smat(mi, i+1) = infl*(Smat(mi-1,i)+Smat(mi,i))/2;
        end
		lnode=mi;
        llnode=mi;
    else                    % (i+1) is even 
		%let us find the upper node first (EQN 8)
		mi=round((i+1)/2);
		Call_Put_Flag=1;    % 1 for call/0 for put
		S=Smat(mi,i);       % S_n^i
        
		C=optionprice(S,s0,r,i,dt,Call_Put_Flag);
		rho_u=0;
		if (mi+1)<=i;
           rho_u = sum(ADmat(mi+1:i,i).*(infl*Smat(mi+1:i,i)-S));
        end
        Su = S*(infl*C+ADmat(mi,i)*S-rho_u)/(ADmat(mi,i)*S*infl-infl*C+rho_u); % EQ 1.14
         %Smat(mi,i+1) = S*(infl*C+ADmat(mi,i)*S-rho_u)/(ADmat(mi,i)*S*infl-infl*C+rho_u) % EQ 1.14
        Sl=S^2/Su;        % S_{n+1}^i = S^2/S_{n+1}^{i+1}
         %Smat(mi-1,i+1)=S^2/Smat(mi+1,i+1)        % S_{n+1}^i = S^2/S_{n+1}^{i+1}
%%%%%%% Compensation %%%%%%%%
        %if ((mi==1)&& (Su<infl*S || Sl>infl*S))
        %    disp('IBTdk: Sorry that in the condition of interest rate being higher than volatility, this method cannot give definite output and will terminate automatically')
        %    disp('Please type another interest rate')
        %    r=input('r=');
        %end    
        if ((mi>1) && (Su<infl*S || Sl<infl*S)) % Condition (1.17)
            Su = sqrt(S^3/Smat(mi-1,i));
            Sl = S^2/Su;
        end   
       if (mi<i) && (mi>1);
        if (Su>infl*Smat(mi+1,i)||Sl<infl*Smat(mi-1,i));
            Su = sqrt(S^3/Smat(mi-1,i));
            Sl = S^2/Su;
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
		%sigma=sig-(S-s0)*skew;      % implied volatility
        C=optionprice(S, s0,r,i,dt,Call_Put_Flag);
		rho_u=0;
		%for k=1:j-1,
		%	tmpsum=tmpsum+ADmat(k,i)*(exp(r*dt)*Smat(k,i)-Smat(j,i));
		%end
        if j<=i
            rho_u = sum(ADmat(j:i,i).*(infl*Smat(j:i,i)-S));
        end
		F=S*infl;
		Su = (Smat(j-1,i+1)*(C*infl-rho_u)-ADmat(j-1,i)*S*(F-Smat(j-1,i+1)))/(C*infl-rho_u-ADmat(j-1,i)*(F-Smat(j-1,i+1)));
        %%%% Compensation %%%%%%%
        if j<=i
           if (Su > infl*Smat(j,i) || Su< infl*S); 
               %Su = Smat(j-1,i)* Smat(j-1,i+1)/Smat(j-2,i);
               Su = Smat(j,i)* Smat(j-1,i+1)/Smat(j-1,i);
           end
           if (Su > infl*Smat(j,i) || Su< infl*S); 
               Su = infl*(Smat(j,i)+S)/2;
           end
        else
        %if (j==i && (Su > S*exp(2*sigma*sqrt(dt))|| Su< infl*S));
            if Su > S*exp(2*sigma*sqrt(dt))|| Su< infl*S;        
                Su = S*Smat(j-1,i+1)/Smat(j-2,i);
            end
         end   
         Smat(j,i+1) = Su; 
	end
	
	%******   Step 3 : Find lower nodes of stock tree (EQ 9) *************************
	for j=(llnode-1):-1:1
		Call_Put_Flag=0;
		S=Smat(j,i);                % S_n^i
		P=optionprice(S,s0,r,i,dt,Call_Put_Flag);
		rho_l=0;
		if j>1
            rho_l = sum(ADmat(1:j-1,i).*(S-infl*Smat(1:j-1,i)));    
        end
		F=S*infl;
		%tmpnumer=Smat(j-1,i+1)*(exp(r*dt)*Pp-tmpsum)+ADmat(j-1,i)*Smat(j-1,i)*(F-Smat(j-1,i+1));
        %tmpdenom=exp(r*dt)*Pp-tmpsum+ADmat(j-1,i)*(F-Smat(j-1,i+1));
		Sl=(Smat(j+1,i+1)*(P*infl-rho_l)+ADmat(j,i)*S*(F-Smat(j+1,i+1)))/(P*infl-rho_l+ADmat(j,i)*(F-Smat(j+1,i+1)));
        %%%%%% Compensation %%%%%%%%%
        if (j>1)
            if (Sl < infl* Smat(j-1,i) || Sl > infl * S);
                Sl = Smat(j-1,i)*Smat(j+1,i+1)/S;
            end
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
    %for k=1:i
     %   pp(k,i) = (infl * Smat(k,i)-Smat(k,i+1))/(Smat(k+1,i+1)-Smat(k,i+1))
    %end    
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

%'arrow debreu price tree n'
%disp(ADmat);

%******   Step 4 : Find nodes of implied volatility tree *************************
%LVmat=zeros(n,n);
%for i=1:n,
%	LVmat(1:i,i)=log(Smat(2:i+1,i+1)./Smat(1:i,i+1)).*(pmat(1:i,i).*(1-pmat(1:i,i))).^0.5;%
%end
%'local volatility tree n'
%disp((LVmat))


