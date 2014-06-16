function RES = graph_update(h1, platoon,t)
% RES = graph_update(h1, platoon,t)
%
% h1      = figure handle
% platoon = vehicle platoon
% t       = absolute time [s]

figure(h1)

N=length(platoon);

for p=1:N
    scatter(platoon(p).coordinate_x,t,8,[p/N (N-p)/N 0],'filled')
end
%axis([-100 300 0 t])
    