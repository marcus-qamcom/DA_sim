function data = channel_ok(platoon, p_tx, p_rx, PER_model, scale_power, ch, forced_trans)
% channel_ok(platoon, p_tx, p_rx, PER_model, scale_power, ch, forced_trans)
% 
% Check if a message is send by node p_tx anf if that message could be
% received by node p_rx. 
% 'forced_trans' foces all nodes to transmitt.
%
% platoon = vehicle platoon
% p_tx = sending veh
% p_rx = receiving veh
% PER_model = PER model
% scale_power
% ch = channel prop from file
% forced_trans = 1 if algorithms are used such as single hop etc.

data=0; % no message

for n_tx =1:platoon(p_tx).N_node % For all radio nodes at tx veh

    if (platoon(p_tx).send_flag(n_tx)==1) || (forced_trans == 1)
        
        

        if PER_model == 1 % first PER model
            data=1;       % all messages received
        end

        
        
        if PER_model == 2 % second PER model
            % distance between nodes raise PER. another 10% per node:
            per=scale_power * abs(platoon(p_tx).coordinate_x - platoon(p_rx).coordinate_x)/100; 
            if 1.0*rand> per % if message reaches reciving node
                data=1;   % message received
            end
        end

        
        
        if PER_model == 3 % third per model.
                      % Set PER between nodes. E.g. based on meas data
            
            for n_rx =1:platoon(p_rx).N_node % For all nodes at rx veh
                %disp([num2str(p_tx) ' ' num2str(n_tx) ' ' num2str(p_rx) ' ' num2str(n_rx)])
                per=ch(platoon(p_tx).ch_index(n_tx),platoon(p_rx).ch_index(n_rx))/100;

%                 % given per results in value on CDF curve:
%                 % http://en.wikipedia.org/wiki/Rayleigh_distribution
%                 
                 sigma = 1; % This variable can be used to change environment. But how do we do this
                            % Exactly?
                            
                 cdf_val=sqrt(-2*sigma^2*log(1-per));
                 r = sigma * sqrt(-2 * log(rand)); % generating Rayleigh-distributed variates
                 
                 if r> scale_power*cdf_val  % if message reaches reciving node
                     data=1;   % message received
                 end
                %if 1.0*rand> per % if message reaches reciving node
                %    data=1;   % message received
                %end

                %disp([num2str(p_tx) ' ' num2str(n_tx) ' ' num2str(p_rx) ' ' num2str(n_rx) ' ' num2str(per) ' ' num2str(rr) ' ' num2str(data)])
            end
        end
        
        
        
    end
end