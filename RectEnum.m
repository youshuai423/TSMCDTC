function [sys,x0,str,ts] = RectEnum(t,x,u,flag)
global Sout;

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
    Sout = [1 0 0 1 0 0;
         1 0 0 0 0 1;
         0 0 1 0 0 1;
         0 0 0 1 1 0;
         0 1 1 0 0 0;
         0 1 0 0 1 0];

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
sizes.NumOutputs     = 7;
sizes.NumInputs      = 8;
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
global Sout;
global index;
global max;
sys = [Sout(index, :), max];

function sys=mdlGetTimeOfNextVarHit(t,x,u)

global index;
global max;

S = [1  -1   0;
     1   0  -1;
     0   1  -1;
     0  -1   1;
    -1   1   0;
    -1   0   1];
L = 3e-4;
C = 100e-6;

% Input definition
Ureca = u(1);
Urecb = u(2);
Urecc = -Ureca - Urecb;
Uca = u(3);
Ucb = u(4);
Ucc = -Uca - Ucb;
iak = u(5);
ibk = u(6);
ick = -iak - ibk;
idk = u(7);
ts = u(8);
Ud = zeros(6, 1);

for i = 1 : 6
temp = Ureca * S(i,1) + Urecb * S(i,2) + Urecc * S(i,3) + L / ts * (S(i,1) * iak + S(i,2) * ibk + S(i,3) * ick) - 2 * L / ts * idk;
temp = temp + L * C / ts^2 * (S(i,1) * Uca + S(i,2) * Ucb + S(i,3) * Ucc);
Ud(i) = temp / (1 + L * C / ts^2);
end

max = 0;
index = 1;
for i = 2 : 6
    if Ud(i) > max
        max = Ud(i);
        index = i;
    end
end

sys = t + ts;
  


function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);