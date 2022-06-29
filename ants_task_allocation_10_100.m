%% 将tsp问题映射到任务分配问题
%  1、路线映射为1*100的分配矩阵,1-10给target1，以此类推
%  2、矩阵中无需表现出target，target仅用于计算距离
%  3、总的来说是对分配矩阵的排序优化，目标函数是总距离
close all
clear
clc
tic
%% 参数定义
m=100;                                                                     %蚂蚁总数
alpha=1;                                                                   %信息度启发因子
beta=2;                                                                    %期望值启发式因子
Rho=0.6;                                                                   %信息素挥发因子
Out_DNumber=10;                                                          %外循环次数
NC_max=100;                                                                %最大循环次数
Q=8000;                                                                    %信息素增量
B=zeros(10,100);                                                           %target与AUV之间的距离
Tau=ones(10,100);                                                          %信息素浓度矩阵  
Tabu=zeros(m,100);                                                         %禁忌表
Road_best=zeros(NC_max,100);
Roadlength_best=inf.*ones(NC_max,1);
Point_one_to_ten_distance=ones(Out_DNumber,1).*10000;
PPP=zeros(Out_DNumber,100);
%% 初始化
load('XYZ_data7.mat')
for target_num=1:10
    for AUV_num=1:100
        B(target_num,AUV_num)=...
        sqrt((X_Target(target_num)-X_AUV(AUV_num))^2+...
             (Y_Target(target_num)-Y_AUV(AUV_num))^2+...
             (Z_Target(target_num)-Z_AUV(AUV_num))^2);
    end
end
Eta=1./B;                                                                  %城市与城市之间的能见度，在基于概率转移时用到这个参数

%% 开始循环
for l=1:Out_DNumber
    R=randperm(10);
    for k=1:NC_max
    Tabu(:,1)=randperm(100);
     for j=2:100                                                           %从第二个auv开始选择
        for i=1:m                                                          %第几只蚂蚁                
            visited=Tabu(i,1:(j-1));                                       %表示已经访问过的AUV
            J=zeros(1,(100-j+1));                                          %存放还没有访问过的AUV
            P=J;                        
            Jc=1;                      
            for kk=1:100                   
                if isempty(find(visited==kk, 1))                           %查找已经访问过的AUV里面有没有kk
                    J(Jc)=kk;                                              %没有的话，就把AUVkk记录进未访问过的AUV矩阵里面。J矩阵的作用是记录第i只蚂蚁还未访问过的AUV
                    Jc=Jc+1;           
                end
            end
           if  j<100                                                              %计算待选AUV的概率
           for kk=1:length(J)            
               P(kk)=(Tau(R(floor(j/10)+1),J(kk))^alpha)*(Eta(R(floor(j/10)+1),J(kk))^beta);
                                                                           %目前到下一个AUV的概率大小
           end
           else
               for kk=1:length(J)            
               P(kk)=(Tau(R(floor(j/10)),J(kk))^alpha)*(Eta(R(floor(j/10)),J(kk))^beta);
               end
           end
           P=P/sum(P);                                                     %按照概率选取下一个AUV
           Pcum=cumsum(P);
           select=[];
           while isempty(select)==1
           select=find(Pcum>=rand);
           end
           to_visit=J(select(1));      
           Tabu(i,j)=to_visit;          
        end
    end
    if k>=2                           
        Tabu(1,:)=Road_best(k-1,:);    
    end
%记录本次迭代最佳路线
  L=zeros(m,1);
  for i=1:m
      for j=1:100                     
          if j<100
              L(i)=L(i)+B(R(floor(j/10)+1),Tabu(i,j));                                 %每一只蚂蚁所走的路径长度
          else
              L(i)=L(i)+B(R(floor(j/10)),Tabu(i,j));  
          end
      end
  end
  Roadlength_best(k)=min(L);                                              %本次循环的所有路径中的最短路径放在Roadlength_best中
  pos=find(L==Roadlength_best(k));                                        %找出最短路径的所有蚂蚁
  Road_best(k,:)=Tabu(pos(1),:);                                          %只取第一只蚂蚁的路径                              
  %% 跟新信息素
  delta_Tau=zeros(10,100);                
  for i=1:m                             
      for j=1:99
          delta_Tau(R(floor(j/10)+1),Tabu(i,j))=delta_Tau(R(floor(j/10)+1),Tabu(i,j))+Q/L(i);
      end
          delta_Tau(R(10),Tabu(i,j))=delta_Tau(R(10),Tabu(i,j))+Q/L(i);
  end
  Tau=(1-Rho).*Tau+delta_Tau;                                              %这里运用的是蚁周模型          
  % 禁忌表清零                                 
  Tabu=zeros(m,100); 
   end
  Tau=ones(10,100);
    if Point_one_to_ten_distance(l)>Roadlength_best(end)
       Point_one_to_ten_distance(l)=Roadlength_best(end);
       PPP(l,:)=Road_best(end,:);
    end
    Point_one_to_ten_distance(l+1)=Point_one_to_ten_distance(l);
    PPP(l+1,:)=Road_best(end,:);
end
plot(Point_one_to_ten_distance)
toc



