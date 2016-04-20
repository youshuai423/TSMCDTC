function [sys,x0,str,ts] = Invert(t,x,u,flag)

global s_table;
global invout;

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
    invout = [0 0 0 0 0 0];
    % switchtable
    s_table = [
    2 3 4 5 6 1;
    7 0 7 0 7 0;
    4 5 6 1 2 3;
    1 2 3 4 5 6; 
    0 7 0 7 0 7
    5 6 1 2 3 4;
    ];

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 6;
sizes.NumInputs      = 4;
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
global invout;

sys = invout;

function sys=mdlGetTimeOfNextVarHit(t,x,u)
global invout;
global s_table

ts = u(1);
sector_inv = u(2);
dlamda = u(3);
dT = u(4);

index1 = 3*dlamda - dT + 2;
index2 = sector_inv;
vector = s_table(index1,index2);

switch(vector)
    case 1,
        invout = [1 0 0 1 0 1];
    case 2,
        invout = [1 0 1 0 0 1];
    case 3,
        invout = [0 1 1 0 0 1];
    case 4,
        invout = [0 1 1 0 1 0];
    case 5,
        invout = [0 1 0 1 1 0];
    case 6,
        invout = [1 0 0 1 1 0];
    case 7,
        invout = [1 0 1 0 1 0];
    otherwise,
        invout = [0 1 0 1 0 1];
end

sys = t + ts;


function sys=mdlTerminate(t,x,u)

sys = [];
