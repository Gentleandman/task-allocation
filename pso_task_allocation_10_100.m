clear
clc
% 导入数据
t0 = clock;
load('XYZ_data10.mat')
n=size(X_AUV,2);   %空间维数
AUV_num=1:n;
P_best=1:n;
B=zeros(10,100);                                                           %target与AUV之间的距离
for target_num=1:10
    for AUV_num=1:100
        B(target_num,AUV_num)=...
        sqrt((X_Target(target_num)-X_AUV(AUV_num))^2+...
             (Y_Target(target_num)-Y_AUV(AUV_num))^2+...
             (Z_Target(target_num)-Z_AUV(AUV_num))^2);
    end
end
pn=5000;                          % 例子数目
nc=1;
nc_max=100;                   % 最大迭代次数        
wmax=0.96;                     % 惯性权重  
wmin=0.4;
w=0.8;
c1=0.5;                       % 自我学习因子  
c2=15;                       % 群体学习因子
x=zeros(pn,n);
for i=1:pn
    x(i,:)=x(i,:)+randperm(n);
end
v = zeros(pn,n);                % 初始速度
for i=1:pn
    v(i,:)=round(rand(1,n)'*n); %round取整
end
remg=inf(1,pn);
remx=inf(pn,n);
nums=0;
stop=0;

while (nc<nc_max)&&(stop==0)
    glen=length(pn,n,B,x);%记录种群中每个粒子的适应度
    [len_b,best_index]=min(glen);%找出种群中适应度最低的粒子
    gb=x(best_index,:);%粒子的路线放置于gb
    len_best(1)=inf;
    len_best(nc+1)=min(len_b,len_best(nc));%每一次迭代的最优放进来
    if len_best(nc+1)==len_b
        g_best=gb;
        nums=1;
    else
        nums=nums+1;
    end
    if nums>=20
        stop=1;
    end
    remg=[remg;glen];
    [remg,remg_index]=min(remg);
    remx(find(remg_index==2),:)=x(find(remg_index==2),:);
    
    w=wmax-(wmax-wmin)*nc/nc_max;
    t1=change(remx,x);
    t1=choose(t1,c1);
    t2=change(repmat(g_best,[pn,1]),x);
    t2=choose(t2,c2);
    v=choose(v,w);
    x=path_change(x,v);
    x=path_change(x,t1);
    x=path_change(x,t2);
    nc=nc+1;
end
Time_Cost = etime(clock,t0);
disp(['程序执行时间:' num2str(Time_Cost),'秒']);
disp(['最短距离:' num2str(len_best(end))]);
disp(['最优路径为:' num2str(x(1,:))]);
%r=g_best;
%resultplot(len_best,citys,r);
% figure(1);
% scatter(citys(:,1),citys(:,2),'*')
% hold on
% plot(citys(r,1),citys(r,2),'-');
% hold on
% text(citys(r(1),1),citys(r(1),2),'  起点');
% text(citys(r(end),1),citys(r(end),2),'  终点');
% for i = 1:size(citys,1)
%     text(citys(i,1),citys(i,2),['  ' num2str(i)]);
% end
% 
% figure(2);
% plot(1:size(len_best,2),len_best);

function len_best=length(pn,n,distant,route_best)    
    for i=1:pn
        len_best(i)=0;
        for j=1:n-1
            len_best(i)=len_best(i)+distant(floor(j/10)+1,route_best(i,j));
        end
        len_best(i)=len_best(i)+distant(10,route_best(i,100));
    end
end
function t=change(a,b)
for k=1:size(a,1)
    for i=1:size(a,2)
        t(k,i)=find(b(k,:)==a(k,i));
        b(k,[i,t(k,i)])=b(k,[t(k,i),i]);
    end
end
end
function hold= choose( hold,Odds )
%%如果产生的随机数大于c1，则交换序留下，否则不换

[x,y]=size(hold);
for i=1:x
    for j=1:y
        if rand>Odds
            hold(i,j)=0;
        end
    end
end
end
function b=path_change(b,t)
if any(t)
    for k=1:size(b,1)
        for i=1:size(b,2)
            if t(k,i)~=0
                b(k,[i,t(k,i)])=b(k,[t(k,i),i]);
            end
        end
    end
end
end
