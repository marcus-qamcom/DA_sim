function sim_description(N_veh,platoon,T,distance, speed, Hz,PER_model,age_limit,algo, Tx_algo, ch_file, sc,cdf_val)
% sim_description(N_veh,platoon,T,distance, speed, Hz,PER_model,age_limit,algo, Tx_algo, ch_file, sc,cdf_val)
%
% Saves information about simulation in a text file.

filename = 'sim_info.dat';
fid = fopen(filename, 'wt');

fprintf(fid, '%s \n', ['No. of. vehicles:   ' num2str(N_veh)]);
PP=zeros(N_veh,1);
for v=1:N_veh
    PP(v)=platoon(v).N_node;
end

fprintf(fid, '%s \n', ['Platoon setup:      ' num2str(PP')]);

fprintf(fid, '%s \n', ['Simulation time [s]:' num2str(max(T))]);
fprintf(fid, '%s \n', ['Time step [s]:          ' num2str(T(2)-T(1))]);

%fprintf(fid, '%s \n', ['Distance [m]:       ' num2str(distance)]);
%fprintf(fid, '%s \n', ['Speed [m/s]:        ' num2str(speed)]);

fprintf(fid, '%s \n', ['Message freq. [Hz]: ' num2str(Hz)]);

if PER_model == 1
fprintf(fid, '%s \n', ['PER model:          Perfect channel']);
end
if PER_model == 2
fprintf(fid, '%s \n', ['PER model:          Simple PER']);
end
if PER_model == 3
fprintf(fid, '%s \n', ['PER model:          Table']);
fprintf(fid, '%s \n', ['PER model file:     ' ch_file]);
end

fprintf(fid, '%s \n', ['Age limit [s]:      ' num2str(age_limit)]);

if algo==0
fprintf(fid, '%s \n', ['Multi-hop:           None']);
end
if algo==1
fprintf(fid, '%s \n', ['Multi-hop:           Single hop. Repeat each msg once.']);
end
if algo==2
fprintf(fid, '%s \n', ['Multi-hop:           Single hop. Repeat msg once from nodes ahead.']);
end
if algo==3
fprintf(fid, '%s \n', ['Multi-hop:           Single hop. Repeat msg once from nodes ahead. Half power.']);
end

if Tx_algo==1
fprintf(fid, '%s \n', ['Tx algorithm:        Transmit with first node.']);
end
if Tx_algo==2
fprintf(fid, '%s \n', ['Tx algorithm:        Transmit with random node.']);
end
if Tx_algo==3
fprintf(fid, '%s \n', ['Tx algorithm:        Transmit with every second node.']);
end
if Tx_algo==4
fprintf(fid, '%s \n', ['Tx algorithm:        Transmit with all nodes (allowed acc to std.?).']);
end


% congestion control
fprintf(fid, '%s \n', ['Send messages/node/s:' sprintf('% g',round(sc*100)/100)]);
fprintf(fid, '%s \n', ['Tot. send messages/s:   ' sprintf('%g',round(sum(sc)*100)/100) ]);

%fprintf(fid, '%s \n', ['CDF prob. [-]:      ' num2str(cdf_val)]);
fprintf(fid, '%s \n', ['CDF probability [-]:     ' sprintf('% g',round(cdf_val*1000)/1000)]);

fclose(fid);