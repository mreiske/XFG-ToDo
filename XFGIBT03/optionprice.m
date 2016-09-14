function[c] = optionprice(K, S, r, level, deltat,task)
    %sdata = load('C:Dokumente und EinstellungenAlena MysickovaEigene DateienStatistikXFGDataXFGIBTmcsimulation20.txt');
    global simdata
    ss = simdata(1+(level-1)*1000:(level)*1000,1);
    if(task==1)
        c = exp(-r*level*deltat)*mean(ss-K+abs(ss-K))/2;
    else
        c = exp(-r*level*deltat)*mean(K-ss+abs(K-ss))/2;
    end
%quantlet used to calculate the option prices
 