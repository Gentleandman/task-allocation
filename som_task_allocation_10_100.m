%在之前版本做了改进，应用了som原理，增加了邻域，使得邻域内的其他auv仍有被挑选的机会。3.0版本打乱了target的次序
%把六组1v1改为100个AUV平均分给10个target 
close all
clear
clc
tic
In_DNumber=120;                                                            %内循环迭代次数
Out_DNumber=10000;                                                         %外循环迭代次数
Point_one_to_ten_distance=0;
P=ones(Out_DNumber,1).*10000;                                              %用于存放挑选后对应起点和目标的矩阵
Round=20;                                                                  %邻域半径                                                 
m=0.05;g0=1000;                                                            %常数
Output_V_d=0;                                                              %用于存放auv之间的距离
Choosn_AUV_number=zeros(10,10);

load('XYZ_data10.mat')                                                      %所有target和AUV的xyz坐标

for l=1:Out_DNumber
    R=randperm(10);
    X_Target0=X_Target(R);                                                  %初始化打乱顺序的target
    Y_Target0=Y_Target(R);
    Z_Target0=Z_Target(R);
A=zeros(1,100);
B=cell(10,1);                                                               %用于寄存target和AUV的距离  
for Targets_number=1:10                                                                  %target的次序
    for AUVs_number=1:100                                                             %AUV的次序
        A(AUVs_number)=sqrt((X_Target0(Targets_number)-X_AUV(AUVs_number))^2+...
                            (Y_Target0(Targets_number)-Y_AUV(AUVs_number))^2+...
                            (Z_Target0(Targets_number)-Z_AUV(AUVs_number))^2);
    end
    B{Targets_number}=A;
end
B1=B;
 Pick_inD=zeros(1,100);
 for Targets_number=1:10                                                   %功能:target按此次顺序，产生一组对应的配对
    
     %Min_distance=sort(B1{Targets_number},'ascend');                      %前十名获胜者
    X_Target1=X_Target0;Y_Target1=Y_Target0;Z_Target1=Z_Target0;           %刷新矩阵
    Vectory_AUV=zeros(1,10);
  for N=1:10
      X_AUV1=X_AUV;Y_AUV1=Y_AUV;Z_AUV1=Z_AUV;
      Vectory_AUV(N)=find(B1{Targets_number}==min(B1{Targets_number}), 1, 'first' ); %获胜不代表被挑选
      for AUVs_number=1:100
          if AUVs_number==Vectory_AUV(N)
              continue
          end
          if  Pick_inD(AUVs_number)==100
              X_AUV1(AUVs_number)=X_AUV1(AUVs_number).*Pick_inD(AUVs_number);
              Y_AUV1(AUVs_number)=Y_AUV1(AUVs_number).*Pick_inD(AUVs_number);
              Z_AUV1(AUVs_number)=Z_AUV1(AUVs_number).*Pick_inD(AUVs_number);
              continue
          end
          Output_V_d=sqrt((X_AUV(AUVs_number)-X_AUV(Vectory_AUV(N))).^2+...
                          (Y_AUV(AUVs_number)-Y_AUV(Vectory_AUV(N))).^2+...
                          (Z_AUV(AUVs_number)-Z_AUV(Vectory_AUV(N))).^2);  
                                                                           %输出神经元与获胜神经元之间的距离
               if Output_V_d<Round
                   Pick_inD(AUVs_number)=1;
               else 
                   Pick_inD(AUVs_number)=inf;
               end
              X_AUV1(AUVs_number)=X_AUV1(AUVs_number).*Pick_inD(AUVs_number);
              Y_AUV1(AUVs_number)=Y_AUV1(AUVs_number).*Pick_inD(AUVs_number);
              Z_AUV1(AUVs_number)=Z_AUV1(AUVs_number).*Pick_inD(AUVs_number);
      end                                             %获得了更新后的pick矩阵
     
      for k=1:In_DNumber
          for AUVs_number=1:100    
              if max(max(X_AUV1(AUVs_number),Y_AUV1(AUVs_number)),Z_AUV1(AUVs_number))>100
              continue
              end
              if sqrt((X_AUV1(AUVs_number)-X_Target0(Targets_number)).^2+...
                      (Y_AUV1(AUVs_number)-Y_Target0(Targets_number)).^2+...
                      (Z_AUV1(AUVs_number)-Z_Target0(Targets_number)).^2)<1
                 Choosn_AUV_number(Targets_number,N)=AUVs_number;
                  break
              end
             
              X_AUV1(AUVs_number)=X_AUV1(AUVs_number)+...
                                m*exp((Output_V_d^2)/(((1-m)^k*g0)^2))*...
                               (X_Target1(Targets_number)-X_AUV1(AUVs_number));
              Y_AUV1(AUVs_number)=Y_AUV1(AUVs_number)+...
                                m*exp((Output_V_d^2)/(((1-m)^k*g0)^2))*...
                               (Y_Target1(Targets_number)-Y_AUV1(AUVs_number));
              Z_AUV1(AUVs_number)=Z_AUV1(AUVs_number)+...
                                m*exp((Output_V_d^2)/(((1-m)^k*g0)^2))*...
                               (Z_Target1(Targets_number)-Z_AUV1(AUVs_number));
          end       
      end
      Pick_inD=zeros(1,100);                                               %判定是否在邻域内的矩阵
      for i=1:Targets_number-1
              for kk=1:10
                  Pick_inD(Choosn_AUV_number(i,kk))=100;
              end
      end
      for K=1:N
          Pick_inD(Choosn_AUV_number(Targets_number,K))=100;%把已经挑选好的AUV重新写进pick矩阵，防止被重新挑选
          for i=1:10
          B1{i}(Choosn_AUV_number(Targets_number,K))=inf;
          end
      end
          
  end  
 end
 for i=1:10
     for K=1:10
     Point_one_to_ten_distance=Point_one_to_ten_distance+B{i}(Choosn_AUV_number(i,K));
     end
 end
 
 if P(l)>Point_one_to_ten_distance 
    P(l)=Point_one_to_ten_distance;
    
   %开始画图
   
%    hold off
%    plot3(X_AUV,Y_AUV,Z_AUV,'b.','MarkerSize',20),xlabel('x轴'),ylabel('y轴'),zlabel('z轴');
%    hold on
%    plot3(X_Target,Y_Target,Z_Target,'r.','MarkerSize',30);
%    for number=1:10
%       text(X_Target(number),Y_Target(number),Z_Target(number),num2str(number),'FontSize',7);
%    end
%    for number=1:100
%          text(X_AUV(number),Y_AUV(number),Z_AUV(number),num2str(number),'FontSize',5);
%    end
%    axis equal 
%    %hold on 
%       for i=1:10
%           for kk=1:10
%           t=0:0.01:1;
%           x=X_Target(i)+(-X_Target(i)+X_AUV(Choosn_AUV_number(i,kk)))*t;
%           y=Y_Target(i)+(-Y_Target(i)+Y_AUV(Choosn_AUV_number(i,kk)))*t;
%           z=Z_Target(i)+(-Z_Target(i)+Z_AUV(Choosn_AUV_number(i,kk)))*t;
%           plot3(x,y,z,'-')                                                 %连接起点和终点
%           %hold on  
%           grid on
%           title(['迭代次数:',int2str(l),' 优化最短距离:',num2str(P)]);
%           pause(0.02);
%           end
%       end
 end
 P(l+1)=P(l);
 Point_one_to_ten_distance=0;
end
plot(P)
toc