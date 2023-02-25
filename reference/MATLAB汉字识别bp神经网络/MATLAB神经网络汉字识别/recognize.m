%recognize
%生成向量形式
M=figure('Color',[0.75 0.75 0.75],...
    'position',[200 200 400 200],...
    'Name','基于BP神经网络的汉字识别结果',...
    'NumberTitle','off',...
    'MenuBar','none');
M0=uicontrol(M,'Style','push',...
    'Position',[150 80 130 40],...
    'String','请先训练网络',...
    'FontSize',12,...
       'call','delete(M(1)) ' );  
    y=filename;
    y1=y(1);
    p1=ones(64,64);%初始化16*16的二值图像（全白）
    m=strcat(y1,'.BMP');%形成文件名
    x=imread(m,'BMP');%读取图像
    bw=im2bw(x,0.5);%转换成二值图像数据
    %用矩形框截取
    [i,j]=find(bw==0);%查找像素为黑的坐标
    %取边界坐标
    imin=min(i);
    imax=max(i);
    jmin=min(j);
    jmax=max(j);
    bw1=bw(imin:imax,jmin:jmax);%截取
    %调整比例，缩放成16*16的图像
    rate=64/max(size(bw1));
    bw1=imresize(bw1,rate);%会存在转换误差
    %将bw1转换成标准的16*16图像p1
    [i,j]=size(bw1);
    i1=round((64-i)/2);
    j1=round((64-j)/2);
    p1(i1+1:i1+i,j1+1:j1+j)=bw1;
    p1=-1.*p1+ones(64,64);
    %显示每个字母的矩阵
    disp(p1);
    %将p1转换成输入向量
    
    for m=0:63
        q(m*64+1:(m+1)*64,1)=p1(1:64,m+1);
    end
%显示输入向量
disp(q);
%识别
[a,Pf,Af]=sim(net,q);
disp(a);
a=round(a);
disp(a);
msgbox('请联系微信：matlab2022')