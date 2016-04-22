function [sys,x0,str,ts] = RectEnum(t,x,u,flag)

global Uca Ucb Ucc;
global idsum;

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
    Uca = 0; Ucb = 0; Ucc = 0;

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
sizes.NumInputs      = 14;
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
global Uca Ucb Ucc;
global Ud;

L = 3e-4;
C = 100e-6;

% Input definition
Ureca = u(1);
Urecb = u(2);
Urecc = u(3);
Uca = u(4);
Ucb = u(5);
Ucc = u(6);
Sa = u(7);
Sb = u(8);
Sc = u(9);
iak = u(10);
ibk = u(11);
ick = u(12);
idk = u(13);
ts = u(14);

temp = Ureca * Sa + Urecb * Sb + Urecc * Sc + L / ts * (Sa * iak + Sb * ibk + Sc * ick) - 2 * L / ts * idk;
temp = temp + L * C / ts^2 * (Sa * Uca + Sb * Ucb + Sc * Ucc);
Ud = temp / (1 + L * C / ts^2);

sys = t + ts;
  


function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);