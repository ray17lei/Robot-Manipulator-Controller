function [sys,x0,str,ts] = spacemodel(t,x,u,flag)

switch flag,
case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
case 1,
    sys=mdlDerivatives(t,x,u);
case 3,
    sys=mdlOutputs(t,x,u);
case {2,4,9}
    sys=[];
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;

sizes.NumOutputs     = 6;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [0 0];

function sys=mdlOutputs(t,x,u)
% qd1=2*sin(0.2*pi*t);
% qd2=cos(0.2*pi*t);
% d_qd1=2*0.2*pi*cos(0.2*pi*t);
% d_qd2=-0.2*pi*sin(0.2*pi*t);
% dd_qd1=-2*0.2*0.2*pi*pi*sin(0.2*pi*t);
% dd_qd2=-0.2*0.2*pi*pi*cos(0.2*pi*t);
qd1=2*sin(0.2*pi*t);
qd2=cos(0.2*pi*t);
d_qd1=2*0.2*pi*cos(0.2*pi*t);
d_qd2=-0.2*pi*sin(0.2*pi*t);
dd_qd1=-2*0.2*0.2*pi*pi*sin(0.2*pi*t);
dd_qd2=-0.2*0.2*pi*pi*cos(0.2*pi*t);
sys(1)=qd1;
sys(2)=qd2;
sys(3)=d_qd1;
sys(4)=d_qd2;
sys(5)=dd_qd1;
sys(6)=dd_qd2;