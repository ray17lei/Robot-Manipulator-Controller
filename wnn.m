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
global node b c1 c2
%NN and NNII nodes
node=7;

b=100;
c1=[-40 -25 -10 0 10 25 40;
    -40 -25 -10 0 10 25 40];
c2=[-40 -25 -10 0 10 25 40;
    -40 -25 -10 0 10 25 40];
sizes = simsizes;
sizes.NumContStates  = 4*node;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 6;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);
x0=[20*ones(4*node,1)];
str=[];
ts=[0 0];
function sys=mdlDerivatives(t,x,u)
global node b c1 c2
S=500;T=500;
k1=0.0001;k2=0.0001;
w=u(1:2);
r=u(3:4);
ut=u(5:6);

%NNI
h1_1=zeros(node,1);
h1_2=zeros(node,1);
for j=1:1:node
    h1_1(j)=exp(-norm(ut(1)-c1(1,j))^2/(b*b));
    h1_2(j)=exp(-norm(ut(2)-c1(2,j))^2/(b*b));
end
  
%NNII
h2_1=zeros(node,1);
h2_2=zeros(node,1);
for j=1:1:node
     h2_1(j)=exp(-norm(w(1)-c2(1,j))^2/(b*b));
     h2_2(j)=exp(-norm(w(2)-c2(2,j))^2/(b*b));
end

dh1_1=zeros(node,1);
dh1_2=zeros(node,1);
for i=1:1:node
    dh1_1(i)=h1_1(i)*(2*(ut(1)-c1(1,i))/b^2);
    dh1_2(i)=h1_2(i)*(2*(ut(2)-c1(2,i))/b^2);
end

W1=zeros(node,1);
W2=zeros(node,1);
Wi1=zeros(node,1);
Wi2=zeros(node,1);
for i=1:1:node
    W1(i)=x(i);
    W2(i)=x(i+node);
    Wi1(i)=x(i+node*2);
    Wi2(i)=x(i+node*3);
end
d_W1=-S*dh1_1*Wi1'*h2_1*r(1)'-k1*S*norm(r(1))*W1;
d_W2=-S*dh1_2*Wi2'*h2_2*r(2)'-k1*S*norm(r(2))*W2;
d_Wi1=T*h2_1*r(1)'*W1'*dh1_1-k1*T*norm(r(1))*Wi1-k2*T*norm(r(1))*norm(Wi1,'fro')*Wi1;
d_Wi2=T*h2_2*r(2)'*W2'*dh1_2-k1*T*norm(r(2))*Wi2-k2*T*norm(r(2))*norm(Wi2,'fro')*Wi2;

sys(1:node)=d_W1';
sys(node+1:2*node)=d_W2';
sys(2*node+1:3*node)=d_Wi1';
sys(3*node+1:4*node)=d_Wi2';

function sys=mdlOutputs(t,x,u)
global node b c1 c2
w=u(1:2);
  
%NNII
h2_1=zeros(node,1);
h2_2=zeros(node,1);
for j=1:1:node
    h2_1(j)=exp(-norm(w(1)-c2(1,j))^2/(b*b));
    h2_2(j)=exp(-norm(w(2)-c2(2,j))^2/(b*b));
end

Wi1=zeros(node,1);
Wi2=zeros(node,1);
for i=1:1:node
    Wi1(i)=x(i+node*2);
    Wi2(i)=x(i+node*3);
end
sys(1)=Wi1'*h2_1;
sys(2)=Wi2'*h2_2;