clear
close all
clc
tic
%% 参数设置
load('XYZ_data20.mat')
% Target的起始坐标矩阵
tracks = [ X_Target',Y_Target',Z_Target'];
old_tracks = tracks;
% 所有任务矩阵
dets = [ X_AUV',Y_AUV',Z_AUV'];
% plot3(tracks(:, 1), tracks(:, 2),tracks(:, 3) ,'*', dets(:, 1), dets(:, 2), dets(:, 3),'o')
% axis equal
% hold on
% xlabel('X');
% ylabel('Y');
% title("任务分配")
costofnonassignment = 100;
a = 0;
total_costMatrix = zeros(size(tracks,1),1); % 小车总的任务代价值
%% 开始循环
while true
    if size(dets,1)>0
        a = a + 1;
        T = sprintf("第%d轮拍卖:",a);
         disp(T)
        costMatrix = [];
        % 计算价值矩阵 ，起始是一个距离矩阵
        for i = size(tracks, 1):-1:1
            delta = dets - tracks(i, :);
            costMatrix(i, :) = sqrt(sum(delta .^ 2, 2)); % 距离矩阵,计算出每个小车到每个点的距离矩阵
        end
%         total_costMatrix = costMatrix + total_costMatrix;
    %     disp(costMatrix)% 距离矩阵
        % 开始进行任务拍卖，返回得到 i 号车得到 j 号任务的矩阵
        [assignments, unassignedTracks, unassignedDetections] = assignauction(costMatrix,costofnonassignment);
         disp(assignments)
        old_tracks = tracks;  % 用来保存原来的小车的坐标位姿
        for i = 1:size(assignments, 1)
            ass = assignments(i, :);  %逐行检索买卖双方
            tar_idex = ass(1,2);   % 检索拍卖的任务索引
            tar = dets(tar_idex,:); % 通过索引找到对应的任务  这是这轮拍卖被拍到的任务的坐标点
            trac_idex = ass(1,1);  % 找到买家的索引

            trac = tracks(trac_idex,:); % 找到任务小车   拍下这个任务的小车的坐标点
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            deta = trac - tar;
            total_costMatrix(trac_idex,1) = total_costMatrix(trac_idex,1)+sqrt(deta(1,1)^2 + deta(1,2)^2+deta(1,3)^2);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %tracks(trac_idex,:) = tar; % 将买家坐标更新至当前拍卖到的任务点
            dets(tar_idex,:) = [-999,-999,-999]; % 将已经拍卖掉的标记
        end
        dets(dets(:,2)<0,:)=[]; %将已经拍卖掉的在任务列表中删除
%% 画图
%         for i= 1:size(tracks, 1)
%            if (tracks(i, 1) ~= old_tracks(i,1)) || (tracks(i, 2) ~= old_tracks(i,2))
%                t =  tracks(i, :);
%                t_x = t(1); t_y = t(2);
%                old_t = old_tracks(i, :);
%                ot_x = old_t(1);ot_y = old_t(2);
%                if ot_x ~= t_x
%                    if ot_x < t_x
%                     X = ot_x:0.3: t_x;
%                    else
%                        %ot_x > t_x
%                        X = t_x:0.3:ot_x ; 
%                    end
%                Y = ((t_y-ot_y)/(t_x-ot_x))*(X -ot_x) + ot_y;
%                end
%                if ot_x == t_x
%                     if(ot_y < t_y)
%                        Y =  ot_y :0.3:t_y;
%                     else
%                        Y =  t_y :0.3:ot_y;
%                     end
%                X = ot_x + 0*Y;
%                end
%                if i==1
%                 plot(X,Y,'--r');
%                elseif i==2
%                   plot(X,Y,'-g');
%                elseif i==3
%                    plot(X,Y,'-.b');
%                elseif 4==i
%                    plot(X,Y,'-m');
%                end
%                legend('小车', '任务')
% %                hold on;
% %                T = sprintf("   %d号小车，接收到目标点(%d,%d)",i,t_x,t_y);
%                disp(T);
%            end
%         end
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %返回原点代价加进去
%         dist = tracks - old_tracks ;
%         for i = size(tracks, 1):-1:1
%             total_costMatrix(i,1) = total_costMatrix(i,1)+sqrt(dist(1,1)^2 + dist(1,2)^2);
%         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        break
    end
    % 将 tracks 移动到任务点
end



toc
T=sum(total_costMatrix);
disp(T)