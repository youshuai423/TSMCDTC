function [sys,x0,str,ts] = RectEnum(t,x,u,flag)

global iasum ibsum icsum;
global idsum;

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
    iasum = 0;
    ibsum = 0;
    icsum = 0;
    idsum = 0;

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
sizes.NumInputs      = 10;
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
global Ud;
sys = Ud;

function sys=mdlGetTimeOfNextVarHit(t,x,u)
global iasum ibsum icsum;
global idsum;
global Ud;

L = 3e-4;
C = 100e-6;

% Input definition
Ureca = u(1);
Urecb = u(2);
Urecc = u(3);
Sa = u(4);
Sb = u(5);
Sc = u(6);
iak = u(7);
ibk = u(8);
ick = u(9);
ts = u(10);

temp = Ureca * Sa + Urecb * Sb + Urecc * Sc + L / ts * (Sa * iak + Sb * ibk + Sc * ick) + L / ts * (iasum * Sa +  ibsum * Sb + icsum * Sc - 2 * idsum);
Ud = temp / (1 + L * C / ts);

iasum = iasum + iak * ts;
ibsum = ibsum + ibk * ts;
icsum = icsum + ick * ts;
idsum = disum + id * ts;

sys = t + ts;
  


function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);