function new_veh = control_loop(veh, p, t_step, control_model)
% new_veh = control_loop(veh, p, t_step, control_model) 
% 
% veh           = vehicle
% p             = ego node number
% t_step        = time step in main_traffic_sim.m [s]
% control_model = control loop model
 
    if control_model==1
        % 'set_speed' and 'speed' update following vehicles
        for p2=1:(p-1) % nodes 1 to p-1
            if veh.other_nodes_speed_x(p2,1)== 1 % flag that new speed exist
                veh.set_speed_x = veh.other_nodes_speed_x(p2,2); % set_speed from VERY simple algorithm
                break;
            end    
        end
    end
    
    
    % define more advanced models below
    
    %if control_model==2
    %end
    
    
    % set speed, limit to max acceleration
    if abs((veh.set_speed_x - veh.speed_x)) < veh.max_acc*t_step
        veh.speed_x = veh.set_speed_x;            
    else
        if veh.set_speed_x < veh.speed_x        
            veh.speed_x=veh.speed_x-veh.max_acc*t_step*(1+(rand-0.5)*0.05);            
        else
            veh.speed_x=veh.speed_x+veh.max_acc*t_step*(1+(rand-0.5)*0.05);
        end
    end
    
    new_veh=veh;