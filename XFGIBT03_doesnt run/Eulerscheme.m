function x = Eulerscheme(lev,dt,mu,x0)

%% CODE

%dt=.25;
%lev = 20;
%x0=100.0;
%mu=0;

r=randn(lev+1,1);
t = zeros(lev,1);
x = zeros(lev+1,1);

%the numerical solution with the Euler scheme
t(1) = dt;
x(1)= x0;
for i=2:lev+1
  t(i-1)=(i-1)*dt;
  iv = (-0.2./(log(x(i-1)/x0).^2+1))+0.3;  
  x(i)=x(i-1)+(1+mu)*dt+x(i-1)*iv*sqrt(dt)*r(i);
end  
x = x(2:end);

%% PLOT

%t_2 = lev*dt;
plot(t,x); hold all;
%plot(t_2,x)

title('Exact Solution and Euler Numerical Solution')
xlabel('time t')
ylabel('X(t)')
legend('Exact','Numerical')