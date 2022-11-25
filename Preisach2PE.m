function [P,electric_field]=Preisach2PE(point1,point2,P,electric_field)
global Ee;
global status;
global dQ;
dx_points=length(Ee);
neglect_node_length=2;%2 is to neglect the value between the reversable line
E_start_index=find_nearest(Ee,point1);
E_end_index=find_nearest(Ee,point2);

if point1<point2
    if Ee(E_start_index(2))~=point1
        P(end+1)=P(end)+sum((1-status(E_start_index(2),E_start_index(2)-neglect_node_length:-1:1)).*dQ(E_start_index(2),E_start_index(2)-neglect_node_length:-1:1))*(Ee(E_start_index(2))-point1)/(Ee(E_start_index(2))-Ee(E_start_index(1)));
        electric_field(end+1)=Ee(E_start_index(2));
    end
    for i=E_start_index(2)+1:1:E_end_index(1)
        P(end+1)=P(end)+sum((1-status(i,i-neglect_node_length:-1:1)).*dQ(i,i-neglect_node_length:-1:1));
        status(i,i:-1:1)=1;
%         lastE=Ee(i);
        electric_field(end+1)=Ee(i);
    end
    if point2~=Ee(E_end_index(1))
        P(end+1)=P(end)+sum((1-status(E_end_index(2),E_end_index(2)-neglect_node_length:-1:1)).*dQ(E_end_index(2),E_end_index(2)-neglect_node_length:-1:1))*(point2-Ee(E_end_index(1)))/(Ee(E_end_index(2))-Ee(E_end_index(1)));
        electric_field(end+1)=point2;
    end
else
    if point1~=Ee(E_start_index(1))
        P(end+1)=P(end)+sum((-1-status(E_start_index(2)+neglect_node_length:1:dx_points,E_start_index(2))).*dQ(E_start_index(2)+neglect_node_length:1:dx_points,E_start_index(2)))*(point1-Ee(E_start_index(1)))/(Ee(E_start_index(2))-Ee(E_start_index(1)));
        electric_field(end+1)=Ee(E_start_index(1));
    end
    for i=E_start_index(1)-1:-1:E_end_index(2)+1
        P(end+1)=P(end)+sum((-1-status(i+1+neglect_node_length:1:dx_points,i+1 )).*dQ(i+1+neglect_node_length:1:dx_points,i+1));
        status(i+1:1:dx_points,i+1)=-1;
%         lastE=Ee(i);
        electric_field(end+1)=Ee(i);
    end
    if Ee(E_end_index(2))~=point2
        P(end+1)=P(end)+sum((-1-status(E_end_index(2)+neglect_node_length:1:dx_points,E_end_index(2))).*dQ(E_end_index(2)+neglect_node_length:1:dx_points,E_end_index(2)))*(Ee(E_end_index(2))-point2)/(Ee(E_end_index(2))-Ee(E_end_index(1)));
        electric_field(end+1)=point2;
    end
end
