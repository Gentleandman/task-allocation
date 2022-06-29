close all
clear
clc
tic
%% 参数设置
load('XYZ_data20.mat')
Num_AUV=size(X_AUV,2);
popsize=720;
pop=zeros(popsize,Num_AUV);
B=zeros(6,6);                                                           %target与AUV之间的距离
pc=.8;
pm=.08;
iter=100;
numberofcrossover=round(pc*popsize);                                       %交叉规模
numberofmutation=round(pm*popsize);                                        %变异规模
numberofrec=popsize-(numberofcrossover+numberofmutation);                  %其他
%% 初始化
for target_num=1:6
    for AUV_num=1:6
        B(target_num,AUV_num)=...
        sqrt((X_Target(target_num)-X_AUV(AUV_num))^2+...
             (Y_Target(target_num)-Y_AUV(AUV_num))^2+...
             (Z_Target(target_num)-Z_AUV(AUV_num))^2);
    end
end
for i=1:popsize                                                            %形成初代种群
    x=randperm(Num_AUV);
    j=1;
    while j<i
        if pop(j,:)==x
            j=1;
            x=randperm(Num_AUV);
        else
            j=j+1;
        end    
    end                                                                    %这个while循环是为了避免重复
    pop(i,:)=x;    
end
%count the distance of each root计算每个种群的适应度
for i=1:popsize
    x=0;
    for j=1:Num_AUV
        x=x+B(j,pop(i,j));
    end
    pop(i,Num_AUV+1)=x;
end
%sort unitage distance按照适应度排序
for i=1:popsize
    for j=1:i
        if pop(j,Num_AUV+1)>pop(i,Num_AUV+1)
            temp=pop(i,:);
            pop(i,:)=pop(j,:);
            pop(j,:)=temp;
        end
    end
end
%% 开始循环
for i=1:iter
%挑选保留的种群
    selected=[];
    for j=1:numberofrec
        selected(j,:)=pop(j,:);
    end
    
%Crossover   
    c=randperm(popsize);
    for j=1:numberofcrossover
           individualsForCross(j,:)=pop(c(j),1:Num_AUV);
    end    
    offspringset=[];       
    for zz=1:numberofcrossover
        n_parent1=ceil(numberofcrossover*rand);
        n_parent2=ceil(numberofcrossover*rand);
        parent1=individualsForCross(n_parent1,:);
        parent2=individualsForCross(n_parent2,:);                          %随意挑选出两行进行交叉  
        crossoverpoint=ceil((Num_AUV-1)*rand);                             %选择交叉片段的长度
        parent12=parent1(1:crossoverpoint);                                    %截取交叉片段
        parent21=parent2(1:crossoverpoint);
        s1=[];
        s2=[];
        for j=1:numel(parent1)
            if sum(parent1(j)~=parent21)==numel(parent21)
               s2=[s2 parent1(j)];
            end
            if sum(parent2(j)~=parent12)==numel(parent12)
               s1=[s1 parent2(j)];
            end
        end
        offspring1=[parent12 s1];
        offspring2=[parent21 s2];
% evaluate fitness
        offspring1(Num_AUV+1)=0;
        offspring2(Num_AUV+1)=0;
        for z=1:Num_AUV
            offspring1(Num_AUV+1)=offspring1(Num_AUV+1)+B(z,offspring1(1,z));
        end
        for z=1:Num_AUV
            offspring2(Num_AUV+1)=offspring2(Num_AUV+1)+B(z,offspring2(1,z));
        end        
    offspringset=[offspringset;offspring1;offspring2];
    end
    
%Mutation
    m=randperm(popsize);
    for j=1:numberofmutation
        individualsForMutation(j,:)=pop(m(j),1:Num_AUV);
    end   
%doing the mutation
    Mutatedset=[];
    for zz=1:numberofmutation
        parent=individualsForMutation(zz,:);
        mutationPoint1=ceil(Num_AUV*rand);
        mutationPoint2=ceil(Num_AUV*rand);
        temp=parent(mutationPoint1);
        parent(mutationPoint1)=parent(mutationPoint2);
        parent(mutationPoint2)=temp;        
% Evaluate fitness of mutateed members
        parent(Num_AUV+1)=0;
        for z=1:Num_AUV
            parent(Num_AUV+1)=parent(Num_AUV+1)+B(z,parent(1,z));
        end
        Mutatedset=[Mutatedset;parent];
    end
    pop2=[selected;offspringset;Mutatedset];
%sort the new population     
    for z=1:size(pop)
        for j=1:z
            if pop(j,Num_AUV+1)>pop(z,Num_AUV+1)
                temp=pop(z,:);
                pop2(z,:)=pop(j,:);
                pop2(j,:)=temp;
            end
        end
    end
end
best_root=pop(1,1:6);
min_distance=pop(1,7);
toc