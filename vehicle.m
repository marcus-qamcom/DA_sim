function data = vehicle(my_pos, distance, my_type, Hz, N_veh, N_node, timeout, ch_ind, Tx_algo)
% data = vehicle(my_pos, distance, my_type, Hz, N_veh, N_node, timeout, ch_ind, Tx_algo)
%
% Defines vehicle, returns object.
%
% my_pos       = position in platoon, this is also my ID.
% distance     = distance between vehicles in platoon [m]
% my_type      = 1,2,3: car, truck or loaded truck
% Hz           = message frequency [Hz]
% N_veh        = number of vehicles in platoon
% N_node       = number of nodes this vehicle
% timeout      = max delay in data age
% ch_ind       = index in channel matrix
% Tx_algo      = transmitting algorithm
%
% Function sets vehicle properties:
% coordinate_x  = position in x-direction [m]
% speed_x       = speed in x-direction [m/s]
% set_speed_x   = set point speed in x-direction [m/s]
% set_coord_x   = set point coordinate in x-direction [m]
% delay         = time delay [s]
% max_acc       = max acceleration or retardation [m/s^2]
% t_last_msg    = time of last transmitted message [s].
% send_flag     = 0 or 1, 1 = this node has transmitted its status. Vector.
% data_age      = list of timestams when info. from other nodes were rec.
% send_energy   = accumulated energy from send messages (for congestion control...)
% ch_index      = index in ch matrix containing per data
% N_node        = number of nodes in veh
% node_rep_freq = repetition frequency of messages from node. 
%                 Depends on Tx_algo and Hz.

data = struct('coordinate_x', [], 'speed_x', [], 'delay', [], 'max_acc', [], 't_last_msg', [], ...
    'send_flag', [],'set_coord_x', [],'set_speed_x', [], 'data_age', [], 'send_energy', [], 'ch_index', [], ...
    'N_node', [], 'veh_rep_freq', [], 'send_node', []);


data.coordinate_x=-(my_pos-1)*distance;
data.speed_x=20; % m/s ~ 70km/h

% delay and acceleration different depending of typ of vehicle:
if my_type == 1 % car
    data.delay=0.5; % sec. % delay not implemented yet
    data.max_acc=8; % acceleration m/s^2, 9.82 is maximum.
end
if my_type == 2 % truck
    data.delay=0.7;   % sec. % delay not implemented yet
    data.max_acc=6; % acceleration m/s^2
end
if my_type == 3 % loaded truck
    data.delay=1.0;   % sec. % delay not implemented yet
    data.max_acc=4; % acceleration m/s^2
end
% when this node send its last message and a flag notifying other nodes
data.N_node=N_node;




data.veh_rep_freq = 1/Hz;
% if Tx_algo == 1
%     data.node_rep_freq = 1/Hz;
% end
% if Tx_algo == 2 % Transmit with random node
%     data.node_rep_freq = 1/Hz;
% end
% if Tx_algo == 3 % Transmit with every second node
%     data.node_rep_freq = 1/(Hz/data.N_node);
% end
% if Tx_algo == 4 % Transmit with all nodes (allowed acc to std.?)
%     data.node_rep_freq = 1/Hz;
% end




% data.t_last_msg =zeros(N_node,1);
data.t_last_msg = -data.veh_rep_freq *rand;; 
data.send_node=1;

data.ch_index=zeros(N_node,1);
for n_node =1: N_node
    data.ch_index(n_node)= ch_ind + n_node-1;
end

data.send_flag = zeros(N_node,1); % No message send

data.other_nodes_speed_x = zeros(N_veh,4); % keep track of other nodes. [flag speed timestap coordinate]

data.set_coord_x = data.coordinate_x; % this information is yet used in the control loop
data.set_speed_x = data.speed_x; % initailly set speed is equal to actual speed

data.data_age = ones(N_veh,1)*timeout; 
data.send_energy = 0;




% Vehicle dynamics: should enter value max_ret, as retardation normally is higher than acceleration.

