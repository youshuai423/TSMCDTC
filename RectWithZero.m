function [sys,x0,str,ts] = RectWithZero(t,x,u,flag)

global vec_rec;
global s_rec T_rec;
global recstage;
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
    s_rec = [];
    T_rec = [];
    recstage = 1;

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
sizes.NumInputs      = 5;
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
global s_rec T_rec;
global recstage;

if recstage == 1
    sys = s_rec(1, :);
    if T_rec(2) == 0
        if T_rec(3) == 0
            recstage = 1;
        else
            recstage = 3;
        end
    else
        recstage = 2;
    end
elseif recstage == 2
    sys = s_rec(2, :);
    if T_rec(3) == 0
        recstage =1;
    else
        recstage = 3;
    end
else
    sys = s_rec(3, :);
    recstage = 1;
end

function sys=mdlGetTimeOfNextVarHit(t,x,u)
global vec_rec;
global s_rec T_rec;
global recstage;

% 读取输入值
ts = u(1);
sector_rec = u(2);
Ureca = u(3);
Urecb = u(4);
Urecc = u(5);

Ui = 380 * sqrt(2);
mrec = 1;

if recstage == 1
    switch (sector_rec)  % 计算整流两个阶段占空比和开关状态
        case 1
            Da = -mrec * Urecb / Ui;
            Db = -mrec * Urecc / Ui;
            s_rec = [vec_rec(1, :); vec_rec(2, :); vec_rec(7, :)];
        
        case 2
            Da = mrec * Ureca / Ui;
            Db = mrec * Urecb / Ui;
            s_rec = [vec_rec(2, :); vec_rec(3, :); vec_rec(7, :)];
        
        case 3
            Da = -mrec * Urecc / Ui;
            Db = -mrec * Ureca / Ui;
            s_rec = [vec_rec(3, :); vec_rec(4, :); vec_rec(7, :)];
        
        case 4
            Da = mrec * Urecb / Ui;
            Db = mrec * Urecc / Ui;
            s_rec = [vec_rec(4, :); vec_rec(5, :); vec_rec(7, :)];
        
        case 5
            Da = -mrec * Ureca / Ui;
            Db = -mrec * Urecb / Ui;
            s_rec = [vec_rec(5, :); vec_rec(6, :); vec_rec(7, :)];
        
        case 6
            Da = mrec * Urecc / Ui;
            Db = mrec * Ureca / Ui;
            s_rec = [vec_rec(6, :); vec_rec(1, :); vec_rec(7, :)];
        
        otherwise
            Da = 0;
            Db = 0;
            s_rec = [vec_rec(1, :); vec_rec(2, :); vec_rec(7, :)];
    end
    
    T_rec = ts * [Da, Db, 1-Da-Db];  % 计算各矢量时间
    T_rec = roundn(T_rec, 6);
    
    if T_rec(1) ~= 0
        recstage = 1;
        sys = t + T_rec(1);
    else
        recstage = 2;
        sys = t + T_rec(2);
    end
   
elseif recstage == 2
    sys = t + T_rec(2);
else
    sys = t + T_rec(3);
end
if (isnan(sys))
    sys = t + 1e-4;
end

function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);