%S-function for continuous state equation
function [sys,x0,str,ts]=s_function(t,x,u,flag)

switch flag,
%Initialization
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
case 1,
    sys=mdlDerivatives(t,x,u);
%Outputs
  case 3,
    sys=mdlOutputs(t,x,u);
%Unhandled flags
  case {2, 4, 9 }
    sys = [];
%Unexpected flags
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

%mdlInitializeSizes
function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 4;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 4;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 0;

sys=simsizes(sizes);
x0=[0;0;0;0];%[q1,q2,dq1,dq2]
str=[];
ts=[];

function sys=mdlDerivatives(t,x,u)
p1=3.37;
p2=0.733;
p3=1.1;
p4=2.85;
p5=2.85;
g=9.8;

D0=[p1+p2+2*p3*cos(x(2)) p2+p3*cos(x(2));
    p2+p3*cos(x(2)) p2];
C0=[-p3*x(4)*sin(x(2)) -p3*(x(3)+x(4))*sin(x(2));
     p3*x(3)*sin(x(2))  0];
G0=[p4*g*cos(x(1))+p5*g*cos(x(1)+x(2));
   p5*g*cos(x(1)+x(2))];

tol=u;
dq=[x(3);x(4)];
S=inv(D0)*(tol-C0*dq-G0);

sys(1)=x(3);
sys(2)=x(4);
sys(3)=S(1);
sys(4)=S(2);
function sys=mdlOutputs(t,x,u)
%X=(q1,q2,dq1,dq2)
sys(1)=x(1);
sys(2)=x(2);
sys(3)=x(3);
sys(4)=x(4);