close all
clear all
clc

%% test random numbers and if consecutive lost samples comes natural
N=10;
res=zeros(N,1);
res2=zeros(N,1);

for i=1:N
    res(i)=randn;
end

% check if values over some treshold value
for i=1:N
    if res(i)>-1.5
        res2(i)=1;
    end 
end
res2

% count consecutive lost samples
first_lost=0;
counted=1;
ii=1
for i=1:N
    if res2(i)==0
        if first_lost==1; % count 
            clp=clp+1;
        else
            first_lost=1;
            counted=0;
            clp=1;
        end
    else
        if counted==0; % 
            res3(ii)=clp;
            ii=ii+1;
            counted=1;
        end
        first_lost=0;
    end
end

PER=(100*sum(res3))/double(N)