%% Instruction
% This is the first file in this project for nonlinear simulation.
% please run the script section by section
voltage=600;% unit [V]
thickness=11.93;% unit [um]
area=4.5001;% unit [cm2]
%% import xyz data
% xyz.txt was calculated by a homemade Pyhton file. It's the Praisach density matrix of the testing sample
% The origin dada comes from aixACCT
% The unit of x(E), y(Er) and z(rou) in the xyz.txt was [V], [V] and [-uC/cm2/V2]
% So, do the following steps:
% Ex=E/thickness; %unit [V/um]
% Ey=Er/thickness; %unit [V/um]
% rou=-rou*1e-6*thickness*thickness; %unit [(C/cm^2)/(V/um)^2]
% 'thickness' is the thickness of the testing sample 

% Or one can load packed files, Ex_Ey_rou.mat, which has been handled by author.
load Ex_Ey_rou.mat
input = [Ex,Ey]';
output=rou';
%% neural network simulation: Part I
% prepration
input_train=input;
output_train=output;

% [input_n,input_ps]=mapminmax(input_train,0,1);
[output_n,output_ps]=mapminmax(output_train,0,1);
% input_n_test=mapminmax('apply',input_test,input_ps);
%% neural network simulation: Part II
% You may repeat this step again and again to obtain the satisfactory simulation.
% The result is subjective, choose the sutiable one.
net = newff(input_train,output_n,18);
% net work parameters
net.trainParam.epochs=1000;
net.trainParam.lr=0.002;
net.trainParam.goal=1e-4;
net.trainParam.mu_max=1e50;

net=train(net,input_train,output_n);
%% neural network simulation: Part III
% check the simulated result
% You can also load 'neural_net_of_Praisach.mat' file for example
% load neural_net_of_Praisach.mat
vol=voltage/thickness;
x=-vol:vol/100:vol;
y=-vol:vol/100:vol;
xx=[];
yy=[];
a=size(x);
for i=1:1:a(2)
    for j=1:1:a(2)
        if x(i)>=y(j)
            xx(end+1)=x(i);
            yy(end+1)=y(j);
        end
    end
end
sim_test_n=sim(net,[xx;yy]);
sim_test=mapminmax('reverse',sim_test_n,output_ps);
[X2,Y2] = meshgrid(x,y);%unit [V/um]
Z2=griddata(xx',yy',sim_test',X2,Y2);%unit [(C/cm^2)/(V/um)^2]
figure(1)
contourf(X2,Y2,Z2,8)
colormap(summer)
xlabel('Ex')
ylabel('Ey')
%% 
% Then you can run the forc2hys.m for final test