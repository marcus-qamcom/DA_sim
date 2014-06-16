close all
clear all
clc

N=100000;
% given per results in value on CDF curve:
% http://en.wikipedia.org/wiki/Rayleigh_distribution

% sigma is called the scale parameter
% average value u = sigma*sqrt(pi/2) = 1.253*sigma.
% CDF: F(x)=1-e^(-x^2/2sigma^2)

%% Test model
sigma = 1.0;
per_ref=0.03;

cdf_val=sqrt(-2*sigma^2*log(1-per_ref))*ones(N,1);
r = 1*sigma * sqrt(-2 * log(rand(N,1))); % generating Rayleigh-distributed variates
cdf_val(1)
r_dB=20*log10(r);

per=(N-sum(r>cdf_val))/N;
avg=mean(r)/sigma; % should result in approx. 1.253
disp(['mean/sigma (~1.253): ' num2str(avg)])
disp(['per:' num2str(per_ref) ' per_estimate:' num2str(per)])


%% Plot cumulative distribution function - CDF
figure
x=0:0.1:10;
F=1 - exp(-x.^2/(2*sigma^2));
plot(x,F)
xlabel('x')
legend('sigma=1.0')
title('Cumulative Distribution Function')


%% Plot probability density function - PDF

f=x./sigma^2.*exp(-x.^2/(2*sigma^2));
figure
plot(x,f)
xlabel('x')
legend('sigma=1.0')
title('Probability Density Function')


%% median vs average
s=0:0.1:10; % vector of sigma
median=sqrt(s*log(2))
average=sqrt(s*pi/2)

figure
plot(s,median,'b',s,average,'r')
xlabel('sigma')
ylabel('val')
legend('median','average')

