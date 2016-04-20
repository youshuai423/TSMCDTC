function [sys,x0,str,ts] = RectEnum(t,x,u,flag)

global vec_rec;
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
    vec_rec = [
        1, 0, 0, 1, 0, 0;  % v1
        1, 0, 0, 0, 0, 1;  % v2
        0, 0, 1, 0, 0, 1;  % v3
        0, 1, 1, 0, 0, 0;  % v4
        0, 1, 0, 0, 1, 0;  % v5
        0, 0, 0, 1, 1, 0;  % v6
        1, 1, 0, 0, 0, 0;  % v0
        ];

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
sizes.NumOutputs     = 6;
sizes.NumInputs      = 9;
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

function sys=mdlGetTimeOfNextVarHit(t,x,u)
global vec_rec;
global s_rec T_rec;
global recstage;

% Input definition
Ureca = u(1);
Urecb = u(2);
Urecc = u(3);
Sa = u(4);
Sb = u(5);
Sc = u(6);
iak = u(7);
ibk = u(8);
ts = u(9);

% Compute id(k)
ick = -iak - ibk;



function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);