function [sys,x0,str,ts] = TSMC(t,x,u,flag)

global stage;  % 整流状态
global vec_rec;  % 整流扇区开关状态
global s_rec;  % stage1 整流开关
global Trec;  % 整流阶段时间, 同时为逆变周期时间

global section;  % 逆变过程区间
global vec_inv;  % 逆变扇区开关状态
global s_inv;  % 逆变开关
global Tinv  % 逆变阶段时间
global section_begin;
global flag_stage3;

global count;
      
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;
    
    stage = 1;
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
    Trec = [];
    
    section = 1;
    vec_inv = [
        1, 0, 0;  % v1
        1, 1, 0;  % v2
        0, 1, 0;  % v3
        0, 1, 1;  % v4
        0, 0, 1;  % v5
        1, 0, 1;  % v6
        0, 0, 0;  % v7
        1, 1, 1;  % v8
        ];
    s_inv = [];
    Tinv = [];
    
    section_begin = 0;
    flag_stage3 = 0;
    
    count = 0;
    
  case 3,
    sys=mdlOutputs(t,x,u);

  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  case {1,2,9},
    sys = [];
        
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end


function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 9;
sizes.NumInputs      = 9;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [-2 0];      % variable sample time


function sys=mdlOutputs(t,x,u)

global s_rec;
global Trec;
global stage;
global section;
global s_inv;
global Tinv;
global lastout;  % 上次输出开关状态
global section_begin;
global flag_stage3;

global count;
count = count + 1;

if stage == 1 && section_begin == 1
    section_begin = 0;
    sys(1:6) = s_rec(1, :);
    stage = 2;
%     flag_stage3 = 0;
elseif stage == 2 && section_begin == 1
    section_begin = 0;
    sys(1:6) = s_rec(2, :);
    stage = 3;
    if Trec(3) == 0
        stage = 1;
    end
%     flag_stage3 = 0;
elseif flag_stage3 == 1
    section_begin = 0;
    sys(1:6) = s_rec(3, :);
    sys(7:9) = s_inv(1, :);
    stage = 1;
else
    sys = lastout;
end

if flag_stage3 ~= 1
    switch section
        case {1,8},
            if section == 1
                section = section + 1;
            else
                section = 1;
            end
            sys(7:9) = s_inv(1,:);
            
        case {2, 7},
            sys(7:9) = s_inv(2,:);
            if Tinv(1) == 0 && section == 7
                section = 1;
            else
                section = section + 1;
            end
        case {3, 6},
            sys(7:9) = s_inv(3,:);
            if Tinv(1) + Tinv(2) == 0 && section == 6
                section = 1;
            else
                section = section + 1;
            end
        case {4, 5}
            sys(7:9) = s_inv(4,:);
            if Tinv(1) + Tinv(2) + Tinv(3) == 0 && section == 5
                section = 1;
            else
                section = section + 1;
            end
    end
end

lastout = sys;


function sys=mdlGetTimeOfNextVarHit(t,x,u)

global stage;
global s_rec;
global Trec;
global vec_rec;

global section;
global s_inv;
global Tinv;
global vec_inv;
global section_begin;
global flag_stage3;

% 读取输入值
ts = u(1);
mc = u(2);
mv = u(3);

Ureca = u(4);
Urecb = u(5);
Urecc = u(6); 
Uinva = u(7);
Uinvb = u(8);
Uinvc = u(9);

%------------------整流部分-------------------
if (stage == 1 && section == 1) % 整流第一阶段
    
    section_begin = 1;
    flag_stage3 = 0;
    
    Sreca = sign1(Ureca); 
    Srecb = sign1(Urecb); 
    Srecc = sign1(Urecc); 

    sector_rec = 0;  % Sector Judge
    if Sreca && (~Srecb) && (~Srecc)  % 100
        sector_rec = 1;
    elseif Sreca && Srecb && (~Srecc)  % 110
        sector_rec = 2;
    elseif (~Sreca) && Srecb && (~Srecc)  % 010
        sector_rec = 3;
    elseif (~Sreca) && Srecb && Srecc  % 011
        sector_rec = 4;
    elseif (~Sreca) && (~Srecb) && Srecc  % 001
        sector_rec = 5;
    elseif Sreca && (~Srecb) && Srecc  % 101
        sector_rec = 6;
    end
    
    switch (sector_rec)  % 计算整流两个阶段占空比和开关状态
        case 1
            Da = -mc * Urecb;
            Db = -mc * Urecc;
            s_rec = [vec_rec(1, :); vec_rec(2, :); vec_rec(7, :)];
        
        case 2
            Da = mc * Ureca;
            Db = mc * Urecb;
            s_rec = [vec_rec(2, :); vec_rec(3, :); vec_rec(7, :)];
        
        case 3
            Da = -mc * Urecc;
            Db = -mc * Ureca;
            s_rec = [vec_rec(3, :); vec_rec(4, :); vec_rec(7, :)];
        
        case 4
            Da = mc * Urecb;
            Db = mc * Urecc;
            s_rec = [vec_rec(4, :); vec_rec(5, :); vec_rec(7, :)];
        
        case 5
            Da = -mc * Ureca;
            Db = -mc * Urecb;
            s_rec = [vec_rec(5, :); vec_rec(6, :); vec_rec(7, :)];
        
        case 6
            Da = mc * Urecc;
            Db = mc * Ureca;
            s_rec = [vec_rec(6, :); vec_rec(1, :); vec_rec(7, :)];
        
        otherwise
            error('out of 6 sector_rec!');
    end
    
    Trec = ts * [Da, Db, 1-Da-Db];
    Trec = roundn(Trec, 7);  % 舍去小数点第5位后数字，防止 sampletime = 0
    
    if Trec(1) ~= 0
        stage = 1;
    else
        stage = 2;
    end
end

if stage == 2 && section == 1
    section_begin = 1;
    flag_stage3 = 0;
    if Trec(2) == 0
        stage = 3; 
        flag_stage3 = 1;
    end
%     if Trec(3) == 0
%         stage = 1;
%     end
end

if stage == 3 && section == 1
    flag_stage3 = 1;
end

%------------------逆变部分-------------------
if section == 1 && flag_stage3 ~= 1

    Sinva = sign1(Uinva); 
    Sinvb = sign1(Uinvb); 
    Sinvc = sign1(Uinvc); 

    sector_inv = 0;  % Sector Judge
    if Sinva && (~Sinvb) && (~Sinvc)  % 100
        sector_inv = 1;
    elseif Sinva && Sinvb && (~Sinvc)  % 110
        sector_inv = 2;
    elseif (~Sinva) && Sinvb && (~Sinvc)  % 010
        sector_inv = 3;
    elseif (~Sinva) && Sinvb && Sinvc  % 011
        sector_inv = 4;
    elseif (~Sinva) && (~Sinvb) && Sinvc  % 001
        sector_inv = 5;
    elseif Sinva && (~Sinvb) && Sinvc  % 101
        sector_inv = 6;
    end

    switch sector_inv  % 计算各区间的输出时间和占空比
        case 1,
            s_inv = [vec_inv(7,:); vec_inv(1,:); vec_inv(2,:); vec_inv(8,:)];
            Dm = -mv * Uinvb;
            Dn = -mv * Uinvc;
            D0 = 1 - Dm - Dn;
            Tinv = Trec(stage) * [D0/4, Dm/2, Dn/2, D0/4];
        case 2,
            s_inv = [vec_inv(7,:); vec_inv(3,:); vec_inv(2,:); vec_inv(8,:)];
            Dm = mv * Uinva;
            Dn = mv * Uinvb;
            D0 = 1 - Dm - Dn;
            Tinv = Trec(stage) * [D0/4, Dn/2, Dm/2, D0/4];
        case 3,
            s_inv = [vec_inv(7,:); vec_inv(3,:); vec_inv(4,:); vec_inv(8,:)];
            Dm = -mv * Uinvc;
            Dn = -mv * Uinva;
            D0 = 1 - Dm - Dn;
            Tinv = Trec(stage) * [D0/4, Dm/2, Dn/2, D0/4];
        case 4,
            s_inv = [vec_inv(7,:); vec_inv(5,:); vec_inv(4,:); vec_inv(8,:)];
            Dm = mv * Uinvb;
            Dn = mv * Uinvc;
            D0 = 1 - Dm - Dn;
            Tinv = Trec(stage) * [D0/4, Dn/2, Dm/2, D0/4];
        case 5,
            s_inv = [vec_inv(7,:); vec_inv(5,:); vec_inv(6,:); vec_inv(8,:)];
            Dm = -mv * Uinva;
            Dn = -mv * Uinvb;
            D0 = 1 - Dm - Dn;
            Tinv = Trec(stage) * [D0/4, Dm/2, Dn/2, D0/4];
        case 6,
            s_inv = [vec_inv(7,:); vec_inv(1,:); vec_inv(6,:); vec_inv(8,:)];
            Dm = mv * Uinvc;
            Dn = mv * Uinva;
            D0 = 1 - Dm - Dn;
            Tinv = Trec(stage) * [D0/4, Dn/2, Dm/2, D0/4];
    end
    Tinv = roundn(Tinv,8);  % 舍去小数点8位后位数，防止sampletime = 0
end

if flag_stage3 ~= 1
    if section == 1
        if Tinv(1) ~= 0
            sys = t + Tinv(1);
        else
            section = 2;
        end
    end
    
    if section == 2
        if Tinv(2) ~= 0
            sys = t + Tinv(2);
        else
            section = 3;
        end
    end
    
    if section == 3
        if Tinv(3) ~= 0
            sys = t + Tinv(3);
        else
            section = 4;
        end
    end
    
    if section == 4
        if Tinv(4) ~= 0
            sys = t + Tinv(4);
        else
            section = 5;
        end
    end
    
    if section == 5
        if Tinv(4) ~= 0
            sys = t + Tinv(4);
        elseif Tinv(3) ~= 0
            section = 6;
        elseif Tinv(2) ~= 0
            section = 7;
        elseif Tinv(1) ~= 0
            section = 8;
        else
            section = 1;
        end
    end
    
    if section == 6
        if Tinv(3) ~= 0
            sys = t + Tinv(3);
        elseif Tinv(2) ~= 0
            section = 7;
        elseif Tinv(1) ~= 0
            section = 8;
        else
            section = 1;
        end
    end
    
    if section == 7
        if Tinv(2) ~= 0
            sys = t + Tinv(2);
        elseif Tinv(1) ~= 0
            section = 8;
        else
            section = 1;
        end
    end
    
    if section == 8
        sys = t + Tinv(1);
    end
    
    if section > 8
        error('out of range!')
    end
else
    section_begin = 1;
    sys = t + Trec(3);
end

function [output] = sign1(num)
if num >= 0
    output = 1;
else
    output = 0;
end


function [output] = roundn(input,digit)
temp = input * 10^(digit);
output = round(temp) / 10^(digit);
