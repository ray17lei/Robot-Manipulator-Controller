function [sys,x0,str,ts] = spacemodel(t,x,u,flag)
switch flag,
case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
case 3,
    sys=mdlOutputs(t,x,u);
case {2,4,9}
    sys=[];
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumOutputs=4;
sizes.NumInputs=10;
sizes.DirFeedthrough=1;
sizes.NumSampleTimes=1;
sys=simsizes(sizes);
x0=[];
str=[];
ts=[0 0];

function sys=mdlOutputs(t,x,u)
qd1=u(1);qd2=u(2);
d_qd1=u(3);d_qd2=u(4);
dd_qd1=u(5);dd_qd2=u(6);
q1=u(7);q2=u(8);
d_q1=u(9);d_q2=u(10);

q=[q1;q2];
e1=qd1-q1;
e2=qd2-q2;
d_e1=d_qd1-d_q1;
d_e2=d_qd2-d_q2;
e=[e1;e2];
d_e=[d_e1;d_e2];
Hur=5*eye(2);

r=d_e+Hur*e;

d_qd=[d_qd1;d_qd2];
d_qr=d_qd+Hur*e;
dd_qd=[dd_qd1;dd_qd2];
dd_qr=dd_qd+Hur*d_e;

Kp=20*eye(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1=2.9;p2=0.76;p3=0.87;p4=3.04;p5=0.87;
g=9.8;

D0=[p1+p2+2*p3*cos(u(8)) p2+p3*cos(u(8));
    p2+p3*cos(u(8)) p2];
C0=[-p3*u(10)*sin(u(8)) -p3*(u(9)+u(10))*sin(u(8));
     p3*u(9)*sin(u(8))  0];
G0=[p4*g*cos(u(7))+p5*g*cos(u(7)+u(8));
   p5*g*cos(u(7)+u(8))];

w=D0*dd_qr+C0*d_qr+G0+Kp*r;
sys(1)=w(1);
sys(2)=w(2);
sys(3)=r(1);
sys(4)=r(2);