function platoon = communication_update(platoon, t, Hz, Tx_algo)
% platoon = communication_update(platoon, t, Hz, Tx_algo)
%
% Sets flag when a vehicle has send it's status information.
%
% platoon = vehicle platoon
% t       = absolute time [s]
% Hz      = Message update freqency [Hz]
% Tx_algo = Tx algorithm


% For vehicles with more than one node:
%  Tx_algo = 1 => Transmits with first node
           % 2 => Transmit with random node
           % 3 => Transmit with every second node, simply use s half data
           % rate
           % 4 => Transmit with all nodes (allowed acc to std.?)
           % 5 => Tx algorithm... to be implemented...

N=length(platoon);

for n=1:N
    platoon(n).send_flag(:)=0; % no messages send
end




if Tx_algo == 1
    for n=1:N
        diff_t=t-platoon(n).t_last_msg;
        if diff_t>1/Hz
            platoon(n).t_last_msg=t;
            % inform that info is send out to platoon:
            platoon(n).send_flag(1)=1; % msg send
            platoon(n).send_energy=platoon(n).send_energy+1;
        end
    end
end


if Tx_algo == 2 % Transmit with random node
    for n=1:N
        n_node=floor(rand*platoon(n).N_node+1);
        diff_t=t-platoon(n).t_last_msg;
        if diff_t>platoon(n).veh_rep_freq;
            platoon(n).t_last_msg=t;
            % inform that info is send out to platoon:
            platoon(n).send_flag(n_node)=1; % msg send
            platoon(n).send_energy=platoon(n).send_energy+1;
        end
    end
end


if Tx_algo == 3 % Transmit with every second node
    
    for n=1:N
        diff_t=t-platoon(n).t_last_msg;
        if diff_t>platoon(n).veh_rep_freq
            
            last_node=platoon(n).send_node;
            if last_node+1<=platoon(n).N_node
                n_node=last_node+1;
            else
                n_node=1;
            end
            
            platoon(n).t_last_msg=t;
            
            % inform that info is send out to platoon:
            platoon(n).send_flag(n_node)=1; % msg send
            platoon(n).send_node=n_node;
            platoon(n).send_energy=platoon(n).send_energy+1;
        end
    end
end


if Tx_algo == 4 % Transmit with all nodes (allowed acc to std.?)
    
    for n=1:N
        diff_t=t-platoon(n).t_last_msg;
        if diff_t>platoon(n).veh_rep_freq
            for n_node=1:platoon(n).N_node
                
                % inform that info is send out to platoon:
                platoon(n).send_flag(n_node)=1; % msg send
                platoon(n).send_energy=platoon(n).send_energy+1;
            end
            
            platoon(n).t_last_msg=t;
        end
    end
end