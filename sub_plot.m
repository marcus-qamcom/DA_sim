function cdf_val = sub_plot(N_veh,T,res_timestamp,timeout,age_limit)
% cdf_val = sub_plot(N_veh,T,res_timestamp,timeout,age_limit)
%
% Plot function
%
% N_veh         = Number of vehicle in Platoon
% T             = Time vector
% res_timestamp = data age timestamps
% timeout       = ...
% age_limit     = Age limit in plots.


%% General plot settings
ColorVec={'r' 'g' 'b' 'c' 'm' 'y' 'k'};
p_act=N_veh; % We select the last node as viewpoint of our plots
C={}; % legend
cc=0;
for p=1:N_veh
    if p_act ~= p
        cc=cc+1;
        C{cc}=[num2str(p) ' to ' num2str(p_act)];
    end
end

C{cc+1}= 'Age limit';

%% plot timestamp, res_timestamp(ts,p,p_act);
for ts=2:length(T)
    for p=1:N_veh
        if p_act ~= p
            if res_timestamp(ts,p,p_act)~= timeout
                tmp_timestamp(ts,p)=T(ts)-res_timestamp(ts,p,p_act);
            else 
                tmp_timestamp(ts,p)=ones(size(res_timestamp(ts,p,p_act)))*5;
            end
            tmp_timestamp2(ts,p)=T(ts)-res_timestamp(ts,p,p_act);
        end
    end
end

figure
subplot(2,1,1); hold on
for p=1:N_veh
    if p_act ~= p
        subplot(2,1,1); plot(T,tmp_timestamp(:,p),ColorVec{p})
    end
end
subplot(2,1,1); plot(T,ones(length(tmp_timestamp),1)*age_limit,'r--')
subplot(2,1,1); legend(C,'Location','NorthEast')
subplot(2,1,1); xlabel('T [sec.]')
subplot(2,1,1); ylabel('Data age [s]')
subplot(2,1,1); title(['Communication to veh. no.: ' num2str(p_act) ])
subplot(2,1,1); axis([0 max(T) 0 1])
subplot(2,1,1); hold off

%% CDF:s
tmp_timestamp2(tmp_timestamp2>=1.1) = 1.1; % replace in time stamp >1.1 sec with infinite (here 1.1 sec.)

cdf=sort(tmp_timestamp2);





subplot(2,1,2); hold on
for p=1:N_veh
    if p_act ~= p
        subplot(2,1,2); plot(cdf(:,p),linspace(0,1,length(tmp_timestamp2)),ColorVec{p})  
        if length( find(cdf(:,p) > age_limit, 1))>0
            cdf_val(p)=find(cdf(:,p) > age_limit, 1)/length(T);
        else
           cdf_val(p)=100;
        end
    end
end

subplot(2,1,2); plot([age_limit age_limit],[0 1],'r--')
subplot(2,1,2); xlabel('Data age [s]')
subplot(2,1,2); ylabel('Probability [-]')
subplot(2,1,2); xlim([0 1]) 
subplot(2,1,2); ylim([0 1]) 
subplot(2,1,2); legend(C,'Location','SouthEast')
subplot(2,1,2); hold off


hFig = figure(1);
set(hFig, 'Position', [100 100 500 600])


%% Histogram
figure
%hist(flipdim(tmp_timestamp2,2))
hist(tmp_timestamp2)
hold on
h=findobj(gca,'Type','patch');
for p=1:N_veh
    if p_act ~= p
        set(h(p),'FaceColor',ColorVec{N_veh-p},'EdgeColor','k')
        %set(h(p),'FaceColor',ColorVec{p},'EdgeColor','k')
    end
end

xlabel('Data age [s]')
ylabel('Frequency [-]')
xlim([0 1]) 
ylim('auto') 
legend(C)
hold off

 