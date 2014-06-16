function platoon = position_update(platoon, t, t_step, PER_model, algo, ch, age_limit)
% platoon = position_update(platoon, t, t_step, PER_model, algo, ch, age_limit)
%
% Control leading vehicle. +
% Collect information about vehicles in front. Following vehicles +
% Data age: Timestamp. All vehicles +
% Multi-hop algorithms
%
% platoon   = vehicle platoon
% t         = absolute time [s]
% t_step    = time step [s]
% PER_model = PER model
% algo      = multi-hop algorithm
% ch        = wireless channel
% age_limit = data age limit for algo 4


N=length(platoon);


%% LEADING VEHICLE
% leading vehicle follows some external directions
% - read file could be used to specify route
% - random route could be used as well
% - If data age is going to be investigated - comment this.
if t>=1 %after 1 sec. decrease speed to 10m/s
  %  platoon(1).set_speed_x =10;
end

if t>=3 %after 3 sec. increase speed to 30m/s
  %  platoon(1).set_speed_x =30;
end

%if t>=0.5 %after 7 sec. decrease speed to 0m/s
  %  platoon(1).set_speed_x =0;
%end



%% Collect information about vehicles in front. Following vehicles
for p_rx=2:N % for each receiveing node
   % Node checks if any node before has reported its position, set speed etc.:
    for p_tx=1:p_rx-1
        if channel_ok(platoon, p_tx, p_rx, PER_model,1, ch,0)
            platoon(p_rx).other_nodes_speed_x(p_tx,1)=1;
            platoon(p_rx).other_nodes_speed_x(p_tx,2)=platoon(p_tx).speed_x;
            platoon(p_rx).other_nodes_speed_x(p_tx,3)=t;
            platoon(p_rx).other_nodes_speed_x(p_tx,4)=platoon(p_tx).coordinate_x;
            %disp(['msg to from ' num2str(p) ' ' num2str(p2) ' ' num2str(platoon(p).other_nodes_speed_x(p2,2))])
        end
    end
end



%% Data age: Timestamp. All vehicles
for p_rx=1:N % for each receiving node
  % Time stamp: Node checks if any other node has reported its position, set speed etc.:
    for p_tx=1:N
        if p_tx ~= p_rx
            if channel_ok(platoon, p_tx, p_rx, PER_model,1,ch,0)
                platoon(p_rx).data_age(p_tx)=t;
                
                
                % repetition of messages
                   
                
                if algo==1 % single hop   
                    % repeat received message once
                    platoon(p_rx).send_energy=platoon(p_rx).send_energy+1; % p_rx sends
                    for p_rx_2nd=1:N % loop receiving nodes, except:
                        if p_rx_2nd ~= p_tx % sending node not interested
                            if p_rx_2nd ~= p_rx % neither my node is interested
                                                                
                                if channel_ok(platoon, p_rx, p_rx_2nd, PER_model,1,ch,1) % from repeating node to other node 
                                                                        
                                    platoon(p_rx_2nd).data_age(p_tx)=t-platoon(p_rx).veh_rep_freq;
                                    %disp([ num2str(p_rx_2nd) ' ' num2str(p_tx) ' ' num2str(t)])
                                end
                            end
                        end
                    end
                end
                  
                
                if algo==2 % single hop 2: repeate messages from vehicles in front
                    % repeat received message once
                    if p_rx>p_tx %rec node is after transmitting node 
                        platoon(p_rx).send_energy=platoon(p_rx).send_energy+1;
                        for p_rx_2nd=1:N % send to all nodes, except:
                            if p_rx_2nd ~= p_tx % sending node not interested
                                if p_rx_2nd ~= p_rx % neither my node is interested
                                    if channel_ok(platoon, p_rx, p_rx_2nd, PER_model,1,ch,1) % from my node to other node 
                                        platoon(p_rx_2nd).data_age(p_tx)=t-platoon(p_rx).veh_rep_freq;
                                    end
                                end
                            end
                        end     
                    end
                end
                    
                    
                if algo==3 % single hop 3: repeate messages from vehicles in front but with half power
                    % repeat received message once
                    if p_rx>p_tx %my_node is after transmitting node 
                        platoon(p_rx).send_energy=platoon(p_rx).send_energy+1/2;
                        for p_rx_2nd=1:N % send to all nodes, except:
                            if p_rx_2nd ~= p_tx % sending node not interested
                                if p_rx_2nd ~= p_rx % neither my node is interested
                                    if channel_ok(platoon, p_rx, p_rx_2nd, PER_model,2,ch,1) % from my node to other node 
                                        platoon(p_rx_2nd).data_age(p_tx)=t-platoon(p_rx).veh_rep_freq;
                                    end
                                end
                            end
                        end     
                    end
                end
       
                
                
            else
                % Two reasons causes code end up here:
                % 1) channel was not ok
                % 2) no message was sent
                
                % Check if data age above some treshold:
                if algo==4 
                    
                    if t-platoon(p_rx).data_age(p_tx)>age_limit
                        if p_rx==7 % we plot only node 7...
                            disp([num2str(p_tx) ' to ' num2str(p_rx) ' age ' num2str(t-platoon(p_rx).data_age(p_tx)) ' T ' num2str(t) ])
                        end
                        % now receiving node should send a message to all nodes
                        % requiring p_tx to resend
                        platoon(p_rx).send_energy=platoon(p_rx).send_energy+1; % p_rx sends a request for info about p_tx
                        t2=t+0.01; % add 10 ms
                        disp(['T: ' num2str(t2) ' Request from ' num2str(p_rx) ' send.'])
                        t2=t2+0.01; % add 10 ms
                        for p_rx_2nd=1:N % all except p_rx listen.
                            if p_rx_2nd ~= p_rx
                                if channel_ok(platoon, p_rx, p_rx_2nd, PER_model,1,ch,1) 
                                    disp(['     Reception by: ' num2str(p_rx_2nd)])
                                                            
                                    platoon(p_rx_2nd).send_energy=platoon(p_rx_2nd).send_energy+1; % nodes p_rx call for help repeat information about p_tx              
                                    for p_rx_3rd=1:N 
                                        if p_rx_3rd ~= p_rx_2nd 
                                            if channel_ok(platoon, p_rx_2nd, p_rx_3rd, PER_model,1,ch,1) % from repeating node to other node 
                                                disp(['         ' num2str(p_rx_3rd) ' received message from ' num2str(p_rx_2nd)])
                                                % Now p_rx_2nd sends
                                                % message to p_rx_3rd
                                                % containing information 
                                                % about p_tx
                        
                                                if platoon(p_rx_2nd).data_age(p_tx) > platoon(p_rx_3rd).data_age(p_tx)
                                                    disp(['         data age ' num2str(t-platoon(p_rx_3rd).data_age(p_tx)) ' changed to ' num2str(t2-platoon(p_rx_2nd).data_age(p_tx))])
                                                    platoon(p_rx_3rd).data_age(p_tx) = platoon(p_rx_2nd).data_age(p_tx);
                                                end
                                            end
                                        end
                                    end
                        
                                    
                                end
                            end 
                        end
                    end
                end
                
                
                
                
                
                if algo==5 
                    
                    if t-platoon(p_rx).data_age(p_tx)>age_limit
                        if p_rx==7 % we plot only node 7...
                            disp([num2str(p_tx) ' to ' num2str(p_rx) ' age ' num2str(t-platoon(p_rx).data_age(p_tx)) ' T ' num2str(t) ])
                        end
                        % now receiving node should send a message to all nodes
                        % requiring p_tx to resend
                        platoon(p_rx).send_energy=platoon(p_rx).send_energy+0.5; % p_rx sends a request for info about p_tx
                        t2=t+0.01; % add 10 ms
                        disp(['T: ' num2str(t2) ' Request from ' num2str(p_rx) ' send.'])
                        t2=t2+0.01; % add 10 ms
                        for p_rx_2nd=1:N % all except p_rx listen.
                            if p_rx_2nd ~= p_rx
                                if channel_ok(platoon, p_rx, p_rx_2nd, PER_model,2,ch,1) 
                                    disp(['     Reception by: ' num2str(p_rx_2nd)])
                                                            
                                    platoon(p_rx_2nd).send_energy=platoon(p_rx_2nd).send_energy+0.5; % nodes p_rx call for help repeat information about p_tx              
                                    for p_rx_3rd=1:N 
                                        if p_rx_3rd ~= p_rx_2nd 
                                            if channel_ok(platoon, p_rx_2nd, p_rx_3rd, PER_model,2,ch,1) % from repeating node to other node 
                                                disp(['         ' num2str(p_rx_3rd) ' received message from ' num2str(p_rx_2nd)])
                                                % Now p_rx_2nd sends
                                                % message to p_rx_3rd
                                                % containing information 
                                                % about p_tx
                        
                                                if platoon(p_rx_2nd).data_age(p_tx) > platoon(p_rx_3rd).data_age(p_tx)
                                                    disp(['         data age ' num2str(t-platoon(p_rx_3rd).data_age(p_tx)) ' changed to ' num2str(t2-platoon(p_rx_2nd).data_age(p_tx))])
                                                    platoon(p_rx_3rd).data_age(p_tx) = platoon(p_rx_2nd).data_age(p_tx);
                                                end
                                            end
                                        end
                                    end
                        
                                    
                                end
                            end 
                        end
                    end
                end
                
                
                
            end
        end
    end
end

for p_rx=1:N 
    % control loop
    platoon(p_rx) = control_loop(platoon(p_rx),p_rx,t_step,1);
end




% position update, all vehicles
for p_rx=1:N 
    platoon(p_rx).coordinate_x =platoon(p_rx).coordinate_x + platoon(p_rx).speed_x*t_step;
end    
end
