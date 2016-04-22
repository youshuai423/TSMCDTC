function [sys,x0,str,ts] = RectEnum(t,x,u,flag)

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;

  case 1,
    sys=mdlDerivatives(t,x,u);

  case 2,
    sys=mdlUpdate(t,x,u);

  case 3,
    sys=mdlOutputs(t,x,u);

  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  case 9,
    sys=mdlTerminate(t,x,u);

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 7;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [-2 0];

function sys=mdlDerivatives(t,x,u)

sys = [];

function sys=mdlUpdate(t,x,u)

sys = [];

function sys=mdlOutputs(t,x,u)

global id;
sys = id;

function sys=mdlGetTimeOfNextVarHit(t,x,u)

global id;

isa = u(1);
isb = u(2);
isc = u(3);
Sa = u(4);
Sb = u(5);
Sc = u(6);
ts = u(7);

id = Sa * isa + Sb * isb + Sc * isc;
sys = t + ts;


function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);