function [sys,x0,str,ts] = switchstate(t,x,u,flag)

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;

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
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs = 3;
sizes.NumInputs = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [0 0];



function sys=mdlDerivatives(t,x,u)

sys = [];


function sys=mdlUpdate(t,x,u)

sys = [];


function sys=mdlOutputs(t,x,u)
table_vector = [  % 异步电机模型电压矢量方向和设计时不同
    2 3 4 5 6 1;
    7 0 7 0 7 0;
    4 5 6 1 2 3;
    1 2 3 4 5 6; 
    0 7 0 7 0 7
    5 6 1 2 3 4;
    ];
index1 = 3*u(1) - u(2) + 2;
index2 = u(3);
vector = table_vector(index1,index2);
switch(vector)
    case 1,
        sys = [1  0  0 ];
    case 2,
        sys = [1  1  0 ];
    case 3,
        sys = [0  1  0 ];
    case 4,
        sys = [0  1  1 ];
    case 5,
        sys = [0  0  1 ];
    case 6,
        sys = [1  0  1 ];
    case 7,
        sys = [1  1  1 ];
    otherwise,
        sys = [0  0  0 ];
end


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 0.1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

