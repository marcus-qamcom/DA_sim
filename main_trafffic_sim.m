close all
clear all
clc

% (this m-file can be converted to a function and called by an external script 
% varying inputs for monte carlo simulations).

%% Time
sim_time=200;               % Total simulation time in seconds. (Should be less than 'timeout'? - no...)
sim_time_step=0.01;         % Time step in seconds
T=0:sim_time_step:sim_time; % time vector
timeout = 0; %1000;         % max allowed age of data

% intial settings
distance=10;                % Distance between vehicles [m] (change to time?)
speed=10;                   % inital speed [m/s]
Hz=5;                      % Message update frequency in Hz: 
PER_model=3;                % 1 = perfect
                            % 2 = simple per
                            % 3 = tabluar per

age_limit = 0.2;
algo=0; % Algorithm: 
        % 0 = no algorithm
        % 1 = single hop. Repeat each msg once
        % 2 = single hop. Repeat msg from nodes ahead
        % 3 = single hop. Repeat msg from nodes ahead. Half power.
        % 4 = Ask for repeated message if data age above some limit ver A.
        % 5 = Ask for repeated message if data age above some limit ver B.
        %     Half power.

% For vehicles with more than one node:
Tx_algo=1; % 1 => Transmits with first node
           % 2 => Transmit with random node
           % 3 => Transmit with every second node, simply uses half data
           % rate
           % 4 => Transmit with all nodes (Not allowed acc to std.)
           % 5 => Tx algorithm... to be implemented...           
           

%% Platoon/vehicles
N_veh=4;   % No of vehicles. MAXVALUE =7 (limited by ColorVec)
% A platoon = row of vehicles, no take over possible
% A vehicle is represented by a spatial point
% platoon=zeros(N_veh,1); 
N_node=2; % No of nodes per vehicle
ch_ind=1;

%% PER model...
if PER_model == 1 || PER_model == 2
    for n=1:N_veh
        platoon(n)=vehicle(n, distance, 3, Hz, N_veh, N_node, timeout, ch_ind, Tx_algo);
        ch_ind=ch_ind+N_node;
    end
    ch=0;
    ch_file='';
end


% % 4 vehicles 8 nodes
% if PER_model == 3
%     platoon(1)=vehicle(1, distance, 3, Hz, N_veh, 2, timeout, ch_ind, Tx_algo);
%     ch_ind=ch_ind+2;
%     platoon(2)=vehicle(2, distance, 3, Hz, N_veh, 2, timeout, ch_ind, Tx_algo);
%     ch_ind=ch_ind+2;
%     platoon(3)=vehicle(3, distance, 3, Hz, N_veh, 2, timeout, ch_ind, Tx_algo);
%     ch_ind=ch_ind+2;
%     platoon(4)=vehicle(4, distance, 3, Hz, N_veh, 2, timeout, ch_ind, Tx_algo);
%     ch_ind=ch_ind+2;
%     
%     
%     % Read channel data
%     ch_file='8nodes_4veh.txt';
%     %ch_file='8nodes_4veh_left_side_blind.txt'; 
%     ch = dlmread(['Channel_properties/' ch_file ], '\t', 1, 0);
% end

% SARTRE
% 4 vehicles 5 nodes
if PER_model == 3
    platoon(1)=vehicle(1, distance, 3, Hz, N_veh, 2, timeout, ch_ind, Tx_algo);
    ch_ind=ch_ind+2;
    platoon(2)=vehicle(2, distance, 3, Hz, N_veh, 1, timeout, ch_ind, Tx_algo);
    ch_ind=ch_ind+1;
    platoon(3)=vehicle(3, distance, 3, Hz, N_veh, 1, timeout, ch_ind, Tx_algo);
    ch_ind=ch_ind+1;
    platoon(4)=vehicle(4, distance, 3, Hz, N_veh, 1, timeout, ch_ind, Tx_algo);
    ch_ind=ch_ind+1;
    
    
    % Read channel data
    ch_file='5nodes_4veh_SARTRE_straight_All_speeds.txt';
    ch = dlmread(['Channel_properties/' ch_file ], '\t', 1, 0);
end

%% Simulation
% h1=figure;
% hold on
% xlabel('Distance')
% ylabel('Time')
t=0;
for ts=1:length(T)
    platoon = communication_update(platoon, t, Hz, Tx_algo);
    %radar_update(platoon) % ego vehicle radar, not implemented
    platoon=position_update(platoon,t, sim_time_step, PER_model,algo,ch,age_limit);
    res_speed(ts,:)=[platoon(:).speed_x];
    res_coord(ts,:)=[platoon(:).coordinate_x];
    for p=1:N_veh
        res_timestamp(ts,:,p)=platoon(p).data_age;
    end
    
%    graph_update(h1, platoon,t)
    t=t+sim_time_step % increase time [sec.]
   
    
end

%hold off



%% plot result: Speed and coordinates
% figure
% plot(T,res_speed-res_speed(:,1)*ones(1,N_veh))
% hold on
% xlabel('Time')
% ylabel('Speed')
% %legend([1:N_veh], 'Location', 'NorthEast')
% hold off

% figure
% plot(T,res_coord-res_coord(:,1)*ones(1,N_veh))
% hold on
% xlabel('Time')
% ylabel('Position')
% %legend([1:N_veh], 'Location', 'NorthEast')
% hold off

%% send count, congestion control
for p=1:N_veh
    sc(p)=platoon(p).send_energy;
end
sc=sc/sim_time;


cdf_val=sub_plot(N_veh,T,res_timestamp,timeout,age_limit)
sim_description(N_veh,platoon,T,distance, speed, Hz,PER_model,age_limit,algo, Tx_algo, ch_file,sc,cdf_val)


%% Plot send count, congestion control
figure
stem(sc)
hold on
xlabel('Node [-]')
ylabel('Messages/s [Hz]')
title(['Tx energy per node per second. (Total: ' sprintf('%g',round(sum(sc)*100)/100) ')'])
hold off
