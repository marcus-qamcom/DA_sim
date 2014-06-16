clc
% Test function: 
% channel_ok(platoon, p_tx, p_rx, PER_model, scale_power, ch)

% First veh first node transmits:
platoon(1).send_flag(1)=1;

N_Sampl=5000;
cc_cnt = 0;



for cc=1:N_Sampl
    cc_cnt = cc_cnt + channel_ok(platoon, 4, 5, 3, 1, ch,1);
end
tot_per = (N_Sampl-cc_cnt)/N_Sampl