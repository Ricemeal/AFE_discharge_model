%% Instruction
% This is the second file in this project for nonlinear simulation.
% please run the script section by section
global Ee;
global lastE;
global status;
global dQ;
global dx_points;
voltage=600;% unit [V]
thickness=11.93;% unit [um]
area=4.5001;% unit [cm2]
load neural_net_of_Praisach.mat
%% initialize the grid
Emax=voltage/thickness;
forc=net;
Ee=-Emax:Emax/200:Emax;% unit [V/um]
dxdy=Emax/200*Emax/200;
dx_points=length(Ee);
status=zeros(dx_points,dx_points);
dQ=zeros(dx_points,dx_points);
%%
for i=1:dx_points
    for j=1:dx_points
        if Ee(i)>=Ee(j)
            %If dQ has been saved, the following 3 lines of script can be commented out
%             nor_temp=sim(forc,[Ee(i);Ee(j)]);
%             temp=mapminmax('reverse',nor_temp,output_ps);
%             dQ(i,j)=temp*dxdy;
            
            if Ee(i)<=0
                status(i,j)=1;
            elseif Ee(j)>=0
                status(i,j)=-1;
            end
        end
    end
end
load dQ;% unit [(C/cm^2)]
%% check the hysteresis simulation of Preisach part: Example I
Q=[0];
if 0==0
    lastE=0;
    for i=[202:401,400:-1:1,2:353,352:-1:201]
        if Ee(i)>lastE
            Q(end+1)=Q(end)+sum((1-status(i,i-2:-1:1)).*dQ(i,i-2:-1:1));
            status(i,i:-1:1)=1;
        elseif Ee(i)<lastE
            Q(end+1)=Q(end)+sum((-1-status(i+2:1:dx_points,i)).*dQ(i+2:1:dx_points,i));
            status(i:1:dx_points,i)=-1;
        end
        lastE=Ee(i);
    end
end
U=[Ee(201:401),Ee(400:-1:1),Ee(2:353),Ee(352:-1:201)];
plot(U,Q)
%% check the hysteresis simulation of Preisach part: Example II
% if it is OK, do the next section.
Q=[0];
lastE=0;
for i=[202:321,320:-1:81,82:401,400:-1:1,2:200]
    if Ee(i)>lastE
        Q(end+1)=Q(end)+sum((1-status(i,i-2:-1:1)).*dQ(i,i-2:-1:1));
        status(i,i:-1:1)=1;
    elseif Ee(i)<lastE
        Q(end+1)=Q(end)+sum((-1-status(i+2:1:dx_points,i)).*dQ(i+2:1:dx_points,i));
        status(i:1:dx_points,i)=-1;
    end
    lastE=Ee(i);
end
U=[Ee(201:321),Ee(320:-1:81),Ee(82:401),Ee(400:-1:1),Ee(2:200)];
plot(U,Q)
%% This is the fitting results of integration of reversable dipole densisity,
% which was calculated in Origin APP.
load E_rev.mat;%unit [V/um]
load P_rev.mat;%unit [uC/cm2]
plot(E_rev,P_rev);
%% Following steps are formal simulation process
% initialize matrix of Preisach dipole state 
status=zeros(dx_points,dx_points);
for i=1:dx_points
    for j=1:dx_points
        if Ee(i)>=Ee(j)
            if Ee(i)<=0
                status(i,j)=1;
            elseif Ee(j)>=0
                status(i,j)=-1;
            end
        end
    end
end
%% Preisach controlled P-E relation
E_set=600/thickness;%voltage should be less than 'voltage';unit [V/um]
negative_E_set=-600/thickness;

P=[0];%unit [C/cm2]
electric_field=[0];%unit [V/um]
lastE=0;
[P,electric_field]=Preisach2PE(0,E_set,P,electric_field);
[P,electric_field]=Preisach2PE(E_set,negative_E_set,P,electric_field);
[P,electric_field]=Preisach2PE(negative_E_set,E_set,P,electric_field);
[P,electric_field]=Preisach2PE(E_set,0,P,electric_field);
plot(electric_field,P);
%% reversable dipoles controlled P-E relation
P_reversal=interp1(E_rev,P_rev,electric_field,'linear');%unit [uC/cm2]
plot(electric_field,P_reversal);
%%
P_total=P*1e6+P_reversal;
plot(electric_field,P_total);
%% 
% Then you can run the discharge_sim.m