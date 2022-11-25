%% Instruction
% This is the third file in this project for discharge simulation.
% please run the script section by section
global Ee;
global status;
global dQ;
thickness=11.93;%um
area=4.5001;%cm2
voltage=600;% unit [V]

%Preisach part
load neural_net_of_Praisach.mat
load dQ;% unit [(C/cm^2)] and the matrix unit [V/um]
Emax=voltage/thickness;
Ee=-Emax:Emax/200:Emax;% unit [V/um]
dx_points=length(Ee);

%Reversal part
load E_rev.mat;%unit [V/um]
load P_rev.mat;%unit [uC/cm2]
% plot(E_rev,P_rev);

%% initialize the status grid
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
P_all_history_for_Preisach=[];
E_all_history=[];
%% set parameters of capacitor
% You can change these parameters to any size.
voltage_set=600;%unit [V]
thickness_set=11.93;%um
area_set=4.5001;%cm2
E_set=voltage_set/thickness_set;
if E_set>voltage/thickness
    disp('Error, voltage/thickness too large!');
end
%% calculate P-E relation, E from 0 to E_set, and then
%  calculate the simulated charging current, default RC.
isRC=true;
P=[0];%unit [C/cm2]
electric_field=[0];%unit [V/um]
lastE=0;
[P,electric_field]=Preisach2PE(0,E_set,P,electric_field);
%plot(electric_field,P);
P_reversal=interp1(E_rev,P_rev,electric_field,'linear','extrap');%unit [uC/cm2]
% plot(electric_field,P_reversal);
Q_temp=P_reversal*1e-6*area_set+P*area_set;
U_temp=electric_field*thickness_set;
% plot(U_temp,Q_temp)
if isRC
    big_resistance=1e3;
    Urc=[0];
    Qrc=[0];
    dQrc=[voltage_set/big_resistance];
    trc=[0];
    delta_t=1.5e-6;
    for i=1:1000
       trc(end+1)= i*delta_t;
       Qrc(end+1)= Qrc(end)+ dQrc(end)*delta_t;
       Urc(end+1)= interp1(Q_temp,U_temp,Qrc(end),'linear','extrap');
       dQrc(end+1)= (voltage_set-Urc(end))/big_resistance;
    end
    plot(trc,dQrc);
%     plot(Urc,Qrc);
    hold on;
    E_all_history=electric_field;
    P_all_history_for_Preisach=P;
end
status_before_discharge=status;
P_before_discharge=P_all_history_for_Preisach(end);
E_before_discharge=E_all_history(end);
%% calculate P-E relation, E from E_set to -E_set ,
%then calculate the simulated discharging current, default RLC.else RC
status=status_before_discharge;
P_all_history_for_Preisach(end)=P_before_discharge;
E_all_history(end)=E_before_discharge;
isRLC=true;
if isRLC
    resistance=0.088;
    inductance=38.9e-9;
    delta_t=5e-9;
    
    U_RLC=voltage_set;
    dQ_RLC=0;
    t_RLC=0;
    d2Q_RLC=-U_RLC(end)/inductance;
    
    current_sign=0;
    for segment=1:12
        status_ini=status;
        P=P_all_history_for_Preisach(end);                   %unit [C/cm2]
        lastE=E_all_history(end);
        electric_field=lastE;       %unit [V/um]
        [P,electric_field]=Preisach2PE(lastE,-lastE,P,electric_field);
        %plot(electric_field,P);
        P_reversal=interp1(E_rev,P_rev,electric_field,'linear','extrap');%unit [uC/cm2]
        % plot(electric_field,P_reversal);
        Q_temp=P_reversal*1e-6*area_set+P*area_set;%unit [C]
        U_temp=electric_field*thickness_set;%unit [V]
        Q_RLC=interp1(U_temp,Q_temp,U_RLC(end),'linear','extrap');
        while true
            current=dQ_RLC(end)+d2Q_RLC(end)*delta_t;
            if current_sign==0
                current_sign=sign(current);
            elseif current_sign*sign(current)<0%current reverse occurs
                temp_delta_t=-dQ_RLC(end)/d2Q_RLC(end);
                t_RLC(end+1)=t_RLC(end)+temp_delta_t;
                dQ_RLC(end+1)=0;
                Q_RLC(end+1)=Q_RLC(end);
                U_RLC(end+1)= interp1(Q_temp,U_temp,Q_RLC(end),'linear','extrap');
                d2Q_RLC(end+1)=(-U_RLC(end)-resistance*dQ_RLC(end))/inductance;
                current_sign=-current_sign;
                status=status_ini;
                [P_all_history_for_Preisach,E_all_history]=Preisach2PE(E_all_history(end),U_RLC(end)/thickness_set,P_all_history_for_Preisach,E_all_history);
                break
            end
            t_RLC(end+1)=t_RLC(end)+delta_t;
            dQ_RLC(end+1)=current;
            Q_RLC(end+1)=Q_RLC(end)+dQ_RLC(end)*delta_t;
            U_RLC(end+1)= interp1(Q_temp,U_temp,Q_RLC(end),'linear','extrap');
            d2Q_RLC(end+1)=(-U_RLC(end)-resistance*dQ_RLC(end))/inductance;
        end
    end
    plot(t_RLC,dQ_RLC);
%     plot(Urc,Qrc);
    hold on;
else
    P=P_all_history_for_Preisach(end);  %unit [C/cm2]
    lastE=E_all_history(end);
    electric_field=lastE;       %unit [V/um]
    [P,electric_field]=Preisach2PE(lastE,0,P,electric_field);
    P_all_history_for_Preisach=[P_all_history_for_Preisach,P];
    E_all_history=[E_all_history,electric_field];
    %plot(electric_field,P);
    P_reversal=interp1(E_rev,P_rev,electric_field,'linear','extrap');%unit [uC/cm2]
    % plot(electric_field,P_reversal);
    Q_temp=P_reversal*1e-6*area_set+P*area_set;%unit [C]
    U_temp=electric_field*thickness_set;%unit [V]
    
    R_in_rc=1e3;
    Urc=voltage_set;
    Qrc=interp1(U_temp,Q_temp,Urc(end),'linear','extrap');
    dQrc=[voltage_set/R_in_rc];
    trc=[0];
    delta_t=1.5e-6;
    for i=1:1000
        trc(end+1)= i*delta_t;
        Qrc(end+1)= Qrc(end)- dQrc(end)*delta_t;
        
        Urc(end+1)= interp1(Q_temp,U_temp,Qrc(end),'linear','extrap');
        dQrc(end+1)= Urc(end)/R_in_rc;
    end
    plot(trc,dQrc);
%     plot(Urc,Qrc);
    hold on;
end
%% plot PE loop
P_all_history_reversal=interp1(E_rev,P_rev,E_all_history,'linear','extrap');%unit [uC/cm2]
P_all_history_total=P_all_history_reversal+P_all_history_for_Preisach/1e-6;%unit [uC/cm2]
plot( E_all_history,P_all_history_total)