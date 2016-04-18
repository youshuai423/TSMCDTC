function [sys,x0,str,ts] = sector(t,x,u,flag)

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
sizes.NumOutputs = 1;
sizes.NumInputs  = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];



function sys=mdlDerivatives(t,x,u)

sys = [];


function sys=mdlUpdate(t,x,u)

sys = [];


function sys=mdlOutputs(t,x,u)
k = u(2) / u(1);
if(u(2)>=0 && k<sqrt(3) && k>=0)
    sys = 1;
elseif(u(2)>0 && (k>=sqrt(3) || k<-sqrt(3)))
    sys = 2;
elseif(u(2)>0 && k>=-sqrt(3) && k<0)
    sys = 3;
elseif(u(2)<=0 && k>=0 && k<sqrt(3))
    sys = 4;
elseif(u(2)<0 && (k>=sqrt(3) || k<-sqrt(3)))
    sys = 5;
elseif(u(2)<0 && k<0 && k>=-sqrt(3))
    sys = 6;
else
    sys = 1;
end


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 0.1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

