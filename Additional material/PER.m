close all
clear all
clc

N=1000000;
% given per results in value on CDF curve:
% http://en.wikipedia.org/wiki/Rayleigh_distribution

% sigma is called the scale parameter
% average value u = sigma*sqrt(pi/2) = 1.253*sigma.
% CDF: F(x)=1-e^(-x^2/2simga^2)

sigma = 1.5; 
per=0.01

cdf_val=sqrt(-2*sigma^2*log(1-per))*ones(N,1);
r = 1*sigma * sqrt(-2 * log(rand(N,1))); % generating Rayleigh-distributed variates

per=(N-sum(r>cdf_val))/N

avg=mean(r)/sigma % should result in approx. 1.253