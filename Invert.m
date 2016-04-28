function [sys,x0,str,ts] = Invert(t,x,u,flag)

global s_table;
global invout;
global stage;
global id;

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
    stage = 1;
    id = 0;

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
sizes.NumOutputs     = 7;
sizes.NumInputs      = 6;
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
global stage;
global id;

if stage == 1
    sys = [1 0 1 0 1 0 id];
    stage = 2;
elseif stage == 2
    sys = [invout id];
    stage = 3;
else
    sys = [1 0 1 0 1 0 id];
    stage = 1;
end

function sys=mdlGetTimeOfNextVarHit(t,x,u)
global invout;
global s_table;
global stage;
global id;

ts = u(1);
sector_inv = u(2);
dlamda = u(3);
dT = u(4);
isa = u(5);
isb = u(6);

tcom = 1e-6;
index1 = 3*dlamda - dT + 2;
index2 = sector_inv;
vector = s_table(index1,index2);

if stage == 1
    sys = t + 0.5*tcom;
    
elseif stage == 2
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
    id = invout(1) * isa + invout(3) * isb + invout(5) * (-isa - isb);
    sys = t + ts - tcom;
    
else    
    sys = t + 0.5*tcom;
end

if ts <= tcom
    stage = 3;
    id = 0;
    sys = t + ts;
end


function sys=mdlTerminate(t,x,u)

sys = [];  % for test
