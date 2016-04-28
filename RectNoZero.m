function [sys,x0,str,ts] = RectNoZero(t,x,u,flag)

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
sizes.NumOutputs     = 10;
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
global s_rec T_rec;
global recstage;
global S;

if recstage == 1
    sys = [s_rec(1, :), T_rec(1), S(1, :)];
    if T_rec(2) == 0
        recstage = 1;
    else
        recstage = 2;
    end
elseif recstage == 2
    sys = [s_rec(2, :), T_rec(2), S(2, :)];
    recstage = 1;
else
    sys = [s_rec(1, :), u(1), S(1, :)];
    recstage = 1;
end

function sys=mdlGetTimeOfNextVarHit(t,x,u)
global vec_rec;
global s_rec T_rec;
global recstage;
global S;

% ��ȡ����ֵ
ts = u(1);
mrec = u(2);
sector_rec = u(3);
Ureca = u(4);
Urecb = u(5);
Urecc = u(6);

if recstage == 1
    switch (sector_rec)  % �������������׶�ռ�ձȺͿ���״̬
        case 1
            Da = -mrec * Urecb / Ureca;
            Db = -mrec * Urecc / Ureca;
            s_rec = [vec_rec(1, :); vec_rec(2, :)];
            S = [1 -1 0; 1 0 -1;];
        
        case 2
            Da = -mrec * Urecb / Urecc;
            Db = -mrec * Ureca / Urecc;
            s_rec = [vec_rec(3, :); vec_rec(2, :)];
            S = [0 1 -1; 1 0 -1];
        
        case 3
            Da = -mrec * Urecc / Urecb;
            Db = -mrec * Ureca / Urecb;
            s_rec = [vec_rec(3, :); vec_rec(4, :)];
            S = [0 1 -1; -1 1 0];
        
        case 4
            Da = -mrec * Urecc / Ureca;
            Db = -mrec * Urecb / Ureca;
            s_rec = [vec_rec(5, :); vec_rec(4, :)];
            S = [-1 0 1; -1 1 0];        
        
        case 5
            Da = -mrec * Ureca / Urecc;
            Db = -mrec * Urecb / Urecc;
            s_rec = [vec_rec(5, :); vec_rec(6, :)];
            S = [-1 0 1; 0 -1 1];
        
        case 6
            Da = -mrec * Ureca / Urecb;
            Db = -mrec * Urecc / Urecb;
            s_rec = [vec_rec(1, :); vec_rec(6, :)];
            S = [1 -1 0; 0 -1 1];
        
        otherwise
            Da = 0;
            Db = 0;
            s_rec = [vec_rec(1, :); vec_rec(2, :)];
            S = [1 0 0; 1 0 0];
    end
    
    T_rec = ts * [Da, Db];  % ������ʸ��ʱ��
    T_rec = roundn(T_rec, 8);
    
    if T_rec(1) ~= 0
        recstage = 1;
        sys = t + T_rec(1);
    else
        recstage = 2;
        sys = t + T_rec(2);
    end
   
elseif recstage == 2
    sys = t + T_rec(2);
end
if (isnan(sys))
    sys = t + 1e-4;
end

function sys=mdlTerminate(t,x,u)

sys = [];

function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);