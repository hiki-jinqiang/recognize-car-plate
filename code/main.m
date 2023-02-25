clear,clc,close all
% 车牌识别
%% ======================车牌定位——输入图像===============================
[filename, pathname] = uigetfile('*.jpg;*.bmp;*.png;*.tif', '选择车牌图像');
inital_imag = imread([pathname filename]);
inital_imag=imresize(inital_imag,[1200,1600]);              %固定输入图片的大小
double_imag = im2double(inital_imag);
figure,imshow(inital_imag);title('彩色图片');

%% ======================车牌定位--颜色判断--图片颜色加减===============================

imag_clore=1.5*inital_imag(:,:,3)-inital_imag(:,:,1)-inital_imag(:,:,2);        %蓝色*1.5-红色-绿色
% figure,imshow(imag_clore);title('颜色处理后的结果');%输出黑白图像

BW = imbinarize(imag_clore);                                                    %二值化
% figure,imshow(BW);title('二值化');%输出黑白图像
I2=BW;

%% ======================车牌定位--颜色判断--图片腐蚀===============================
SE = strel('line',3,90);
I3 = imerode(I2,SE);                % 腐蚀
SE = strel('rectangle',[10,30]);
I4 = imclose(I3,SE);            %   闭运算  --图像聚类，填充图像
I4=bwareaopen(I4,1000);%移除面积小于2000的图案
% figure,imshow(I4);title('腐蚀');%输出黑白图像
imag_imclose=I4;

%% ======================车牌定位--颜色判断--颜色区域标记===============================  

[L,num] = bwlabel(imag_imclose,8);          %标注二进制图像中已连接的部分,c3是形态学处理后的图像
Feastats =regionprops(L,'basic');           %计算图像区域的特征尺寸
Area=[Feastats.Area];                       %区域面积
BoundingBox=[Feastats.BoundingBox]          ;%[x y width height]车牌的框架大小
RGB = label2rgb(L,'spring','k','shuffle'); %标志图像向RGB图像转换
% figure;imshow(RGB);title('彩色图');          


%% ======================车牌定位--颜色判断---长宽判断定位===============================    
lx=1;%统计宽和高满足要求的可能的车牌区域个数
region=1;
Getok=zeros(1,10);%统计满足要求个数
for l=1:num  %num是彩色标记区域个数
width=BoundingBox((l-1)*4+3);
hight=BoundingBox((l-1)*4+4);
rato=width/hight;%计算车牌长宽比
%利用已知的宽高和车牌大致位置进行确定。
if( rato>2&&rato<8) %长宽比要满足条件才标记
        Getok(lx)=l;
        lx=lx+1;  
        region=l;
end
end
startrow=1;startcol=1; 
% [original_hihgt original_width]=size(cA);
 fprintf('长宽定位后的满足条件的数量lx=%d\r\n',lx);
 fprintf('长宽定位后的总数量num=%d\r\n',num);
 fprintf('长宽定位后的区域region=%d\r\n',region);
 %返回区域region
 
 %% ======================车牌定位--颜色判断---显示图片===============================    
  if((lx>=1&&lx==2)|| num==1)                               %满足条件才算颜色识别正确，否则就使用形态化识别
  startcol2=round(BoundingBox((region-1)*4+1)-2);%开始列
  startrow2=round(BoundingBox((region-1)*4+2)-2);%开始行  
  width2=BoundingBox((region-1)*4+3)+2;%车牌宽
  hight2=BoundingBox((region-1)*4+4)+2;%车牌高 
  uncertaincy_area2=inital_imag(startrow2:startrow2+hight2,startcol2:startcol2+width2-1); %获取可能车牌区域
%   subplot(2,1,2),imshow(mat2gray(uncertaincy_area2));
  figure,imshow(mat2gray(uncertaincy_area2));title('最后结果');
 end
 
 
 %% ======================车牌定位--形态车牌判断===============================    
 if(lx>2)           %形态化操作
      %% =========形态车牌判断---预处理================    
         gray_imag=rgb2gray(double_imag);
         s=strel('disk',10);%strei函数
         Bgray=imopen(gray_imag,s);% 开区间操作 打开sgray s图像
        % figure,imshow(Bgray);title('背景图像');%输出背景图像
        % %用原始图像与背景图像作减法，增强图像
        im=imsubtract(gray_imag,Bgray);%两幅图相减
        figure,imshow(mat2gray(gray_imag));title('增强黑白图像');%输出黑白图像
         
        %% ======================形态车牌判断---小波变换===============================
        [Lo_D,Hi_D]=wfilters('db2','d'); % d Decomposition filters
        [C,S]= wavedec2(im,1,Lo_D,Hi_D); %Lo_D  is the decomposition low-pass filter
                                            % decomposition vector C    corresponding bookkeeping matrix S
        isize=prod(S(1,:));%元素连乘
        %
        cA   = C(1:isize);              %cA  49152
        cH  = C(isize+(1:isize));
        cV  = C(2*isize+(1:isize));
        cD  = C(3*isize+(1:isize));
        %
        cA   = reshape(cA,S(1,1),S(1,2));
        cH  = reshape(cH,S(2,1),S(2,2));
        cV  = reshape(cV,S(2,1),S(2,2));
        cD  = reshape(cD,S(2,1),S(2,2));

%         figure(5);
%         显示小波变换后的图片
%         subplot(221),imagesc(cA);
% 
%         subplot(222),imagesc(cH);
% 
%         subplot(223),imagesc(cV);
% 
%         subplot(224),imagesc(cD);

        %% ======================形态车牌判断---形态学操作===============================
        I2=edge(cV,'sobel',0.020,'vertical');   %根据所指定的敏感度阈值thresh，在所指定的方向direction上，
        figure,imshow(I2);title('从对象中移除小对象');  
        a1=imclearborder(I2,8);                  %8连通 抑制和图像边界相连的亮对象
        se=strel('rectangle',[10,35]);              %[10,20]
        I4=imclose(a1,se);
        st=ones(1,8);                           %选取的结构元素
        bg1=imclose(I4,st);                     %闭运算
        bg3=imopen(bg1,st);                     %开运算
        bg2=imopen(bg3,[1 1 1 1]'); 
        I5=bwareaopen(bg2,1000);                %移除面积小于2000的图案
        I5=imclearborder(I5,4);                 %8连通 抑制和图像边界相连的亮对象
%         figure,imshow(I5);title('腐蚀后的操作');  
        
         %利用长宽比进行区域筛选
        [L1,num1] = bwlabel(I5,8);              %标注二进制图像中已连接的部分,c3是形态学处理后的图像
        Feastats =regionprops(L1,'basic');      %计算图像区域的特征尺寸
        Area=[Feastats.Area];%区域面积
        BoundingBox=[Feastats.BoundingBox];         %[x y width height]车牌的框架大小
        RGB = label2rgb(L1,'spring','k','shuffle');     %标志图像向RGB图像转换
        figure;imshow(RGB);title('彩色图');
        
        
        %% ======================形态车牌判断---长宽初步判断定位===============================    
        lx1=1;                      %统计宽和高满足要求的可能的车牌区域个数
        Getok=zeros(1,10);          %统计满足要求个数
        for l=1:num1                %num是彩色标记区域个数
        width=BoundingBox((l-1)*4+3);
        hight=BoundingBox((l-1)*4+4);
        rato=width/hight;               %计算车牌长宽比
        %利用已知的宽高和车牌大致位置进行确定。
        if( (rato>2&&rato<10)&&width>15&&hight>8) %width>50 & width<1500 & hight>15 & hight<600
                Getok(lx1)=l;
                lx1=lx1+1;  
        end
        end
        startrow=1;startcol=1;
        [original_hihgt, original_width]=size(cA);
         fprintf('长宽定位后的数量lx1=%d\r\n',lx1);
          count=1;
          
         cv=imresize(gray_imag,[601,801]);
         
      %% ======================形态车牌判断---垂直投影计算峰值定位===============================    
        for order_num=1:lx1-1                               %利用垂直投影计算峰值个数来确定区域
          area_num=Getok(order_num);
          startcol=round(BoundingBox((area_num-1)*4+1)-2);  %开始列
          startrow=round(BoundingBox((area_num-1)*4+2)-2);  %开始行  
          width=BoundingBox((area_num-1)*4+3)+2;            %车牌宽
          hight=BoundingBox((area_num-1)*4+4)+2;            %车牌高 
          uncertaincy_area=cA(startrow:startrow+hight,startcol:startcol+width-1); %获取可能车牌区域
          image_binary=imbinarize(uncertaincy_area);                    %图像二值化
          histcol_unsure=sum(uncertaincy_area);                         %计算垂直投影
           histcol_unsure=smooth(histcol_unsure)';                      %平滑滤波
              histcol_unsure=smooth(histcol_unsure)';                   %平滑滤波
              average_vertical=mean(histcol_unsure);
          figure,subplot(2,1,1),bar(histcol_unsure);
          subplot(2,1,2),imshow(mat2gray(uncertaincy_area));
          [data_1 ,data_2]=size(histcol_unsure);
          peak_number=0; %判断峰值个数
          for j=2:data_2-1%判断峰值个数
              if (histcol_unsure(j)>histcol_unsure(j-1))&&(histcol_unsure(j)>histcol_unsure(j+1))
                  peak_number=peak_number+1;
              end
          end
          fprintf('高峰值检测%d是：%d\n\r',order_num,peak_number);
           valley_number=0; %判断波谷个数
          for j=2:data_2-1
              if (histcol_unsure(j)<histcol_unsure(j-1))&&(histcol_unsure(j)<histcol_unsure(j+1)) &&(histcol_unsure(j)<average_vertical)
                   %波谷值比平均值小
                  valley_number=valley_number+1;
              end
          end 
          fprintf('低峰值检测%d是：%d\n\r',order_num,peak_number);
          %peak_number<=15
         if peak_number>=4 && peak_number<=30 &&valley_number>=2 && valley_number<=30
             %进一步确认可能区域
             select_unsure_area(count)=area_num;
             standard_deviation(count)=std2(histcol_unsure);%计算标准差
             count=count+1;
         end  ,
        end
        %% ======================形态车牌判断---标准差判断车牌位置===============================  
        fprintf('低峰值检测%d是：%d\n\r',order_num,peak_number);
        fprintf('峰值检测后的结果num=%d\n\r',count);
        correct_num_area=0;
        max_standard_deviation=0;
        % if(count<=2) %仅有一个区域
        %    
        %     correct_num_area=select_unsure_area(count-1);
        % else
            for  num=1:count-1
               if(standard_deviation(num)>max_standard_deviation)
                   max_standard_deviation=standard_deviation(num);
                 correct_num_area=select_unsure_area(num);
               end
            end   
        % end

          startcol2=round(BoundingBox((correct_num_area-1)*4+1)-2);%开始列
          startrow2=round(BoundingBox((correct_num_area-1)*4+2)-2);%开始行  
          width2=BoundingBox((correct_num_area-1)*4+3)+2;%车牌宽
          hight2=BoundingBox((correct_num_area-1)*4+4)+2;%车牌高 
          uncertaincy_area2=cv(startrow2:startrow2+hight2,startcol2:startcol2+width2-1); %获取可能车牌区域
        %   subplot(2,1,2),imshow(mat2gray(uncertaincy_area2));
%         figure,imshow(mat2gray(uncertaincy_area2));title('最后结果');   
                   
 end
 
     imag_cardetect=im2double(uncertaincy_area2);       %将颜色和形态学的结果保存在imag-cardetect中
 %% ======================字符分割——尺寸调整预处理===============================
%   figure,imshow(mat2gray(imag_cardetect));title('字符分割的输入图片');
    imag_detecter=imresize(imag_cardetect,[140,440]); %尺寸化
    figure,imshow(imag_detecter);title('尺寸化后结果');      
    
 %% ======================字符分割——倾斜矫正===============================
    
    bw1=edge(imag_detecter,'sobel','horizontal');
    figure,imshow(bw1);title('sobel检测');  
    
    theta = 1:180;
    [R,xp] = radon(bw1,theta);
    [I,J] = find(R>=max(max(R)));                 %J记录了倾斜角
    angle=90-J;
    A=imrotate(imag_detecter,angle,'crop');%对图像进行旋转矫正
     figure,imshow(A);title('矫正后');       
    
    level = graythresh(A);  
    a=im2bw(A,level);  
%     figure,imshow(a);title('没有去除二值化');    %翼会消失，没有办法
%     a=bwareaopen(a,20);%移除面积小于5000的图案
%     figure,imshow(a);title('二值化');
    
%% ======================字符分割——行向量的像素的统计和切割===============================
        [y,x]=size(a);
        Y1=zeros(y,1);
        Y2=zeros(y,1);
  for i=1:y
      n=0;
   for j=1:x
    if(a(i,j,1)==1) 
        Y1(i,1)= Y1(i,1)+1;%计算I3第j列有几个一
    end  
    if(a(i,j,1)~=n)
        Y2(i,1)= Y2(i,1)+1;
        n=a(i,j,1);
    end
   end       
 end
    figure(2);
%     plot(Y1,0:y-1),title('行方向像素点灰度值累计和'),xlabel('累计像素量'),ylabel('行');
    figure(3);
%     plot(Y2,0:y-1),title('次数'),xlabel('次数'),ylabel('行');
    
    
    Py0=fix(y/2);
    Py1=fix(y/2)+1;
    while ((Y1(Py0,1)>=50)&&(Py0>2))
     Py0=Py0-1;%找到去除边框后上边的位置
    end
    while ((Y1(Py1,1)>=50)&&(Py1<y))
     Py1=Py1+1;%找到去除边框后下边的位置
    end
    Z1=a(Py0:Py1,:,:);%将二值图像上下边框去除
    figure(3);
    imshow(Z1),title('将二值图像上下边框去除后图像');
    
    
    
  %% ======================字符分割——去原点===============================   
    Z1=bwareaopen(Z1,150);%移除面积小于5000的图案
    figure;
    imshow(Z1),title('去除圆点图像');
 

 %% ======================字符分割——原图像列向量的像素的统计===============================
%     X1=zeros(1,x);
%     for j=1:x
%     for i=1:y
%      if(a(i,j,1)==1) 
%       X1(1,j)= X1(1,j)+1;%计算I3第j列有几个一
%       end  
%         end       
%      end
%     figure(4);
%     plot(0:x-1,X1),title('列方向像素点灰度值累计和'),xlabel('列值'),ylabel('累计像素');

%  %% ======================字符分割——垂直分割===============================
%     
%     [y,x]=size(Z1);%计算此时图像的大小
%     X1=zeros(1,x);
%     for j=1:x
%     for i=1:y
%      if(Z1(i,j,1)==1) 
%       X1(1,j)= X1(1,j)+1;%计算I3第j列有几个一
%       end  
%         end       
%      end
%     figure(4);
%     plot(0:x-1,X1),title('列方向像素点灰度值累计和'),xlabel('列值'),ylabel('累计像素');
% 
%     
%     
%     x1=fix(x/2)+1;
%     for i=1:6
%     while (i~=6)
%         while ((X1(1,x1)>=13)&&(x1<x))
%          x1=x1+1;%找到去除边框后右边的位置
%         end
%          i=i+1;
%         while ((X1(1,x1)<13)&&(x1<x)&&(i<5))
%         x1=x1+1;%从车牌中间开始寻找字符间隙，直到找到第四个间隙%为止，即找到去除边框后车牌右边的位置
%         end   
%     end
%     end
% %     fprintf('垂直切割%d是：%d\n\r',order_num,peak_number);
%     x0=fix(x*45/440);%找到第一个字符的位置
%     for i=1:2
%     while (i~=2)
%        while ((X1(1,x0)>=5)&&(x0>2))
%         x0=x0-1;%从车牌的第一个字符开始寻找第一个字符间隙，找到%去除边框左边的位置
%         end
%           i=i+1;
%          while ((X1(1,x0)<5)&&(x0>1)&&i~=2)
%          x0=x0-1;%找到去除边框后左边的位置
%          end   
%     end
%     end
%     Z2=Z1(:,x0:x1,:);%将二值图像左右边框去除
%     figure(5);
% %     imshow(Z2),title('将二值图像垂直边框去除后图像');
    Z2=Z1;

  %% ======================字符分割——字符分割--整理数据===============================   
    [yz2,xz2]=size(Z2);%计算此时图像的大小
    X4=zeros(1,xz2);
   for j=1:xz2
    for i=1:yz2
     if(Z2(i,j,1)==1) 
      X4(1,j)= X4(1,j)+1;%计算I3第j列有几个一
      end  
    end       
  end
    figure(4);
    plot(0:xz2-1,X4),title('要切割的图像行像素'),xlabel('列值'),ylabel('累计像素');
    
    px0=1;
    px1=1;
    indx=1;
    pxabs=zeros(1,x);
    pxpos=zeros(1,x);
    for i=1:xz2-1
        pxabs(1,i)=abs( X4(1,i)-X4(1,i+1) );     %将差值保持在数组里面
       if( (pxabs(1,i)<=5) && (X4(1,i)<=5) )
           pxpos(1,indx)=i;                        %将差值大于10的位置保持在位置数组里面
           indx=indx+1;
           fprintf('满足要求的数组%d\r\n',i);
       end
 
    end
    figure(5);
    plot(0:x-1,pxabs),title('差值'),xlabel('列值'),ylabel('差');
    
    
    %% ======================字符分割——字符分割--切割位置的判断1=============================== 
    index=1;
    pos0=1;
    pos1=1;
    qiege=zeros(1,40);
    for j=1:x-1
        if( pxpos(1,j)~=0)
           if( abs(  pxpos(1,j+1)- pxpos(1,j) ) >=15)   %不能太大，不然 “1” 识别不了
               qiege(1,index)=pxpos(1,j);
               index=index+1;
               qiege(1,index)=pxpos(1,j+1);
               index=index+1;
              
           end
        end
    end
    
   %% ======================字符分割——字符分割--切割的位置汉字 川  和1  的特别处理。===============================    
    index_special=1;
    qiege_end=zeros(1,18);
    qiege_end(1,1)=qiege(1,1);
    indx2=0;
   for indx=2:15
       qiege_end(1,indx)=qiege(1,indx+indx2);
       if( qiege(1,indx+indx2)<=70 && ( qiege(1,indx+indx2)-qiege(1,indx+indx2-1)<=40 )&& (qiege(1,indx+indx2)~=0) )
                temp=indx+indx2;
           while(( qiege(1,temp)-qiege(1,temp-1)<=30) && ( qiege(1,temp+1)-qiege(1,temp)<=30 ) )
                  qiege_end(1,indx)=qiege(1,temp);
                  temp=temp+1;
                  indx2=temp-3;
            end
           if(indx2<0)
              indx2=0; 
           end
       end   
         
       if( qiege(1,indx+indx2)>=80 && (qiege(1,indx+indx2)-qiege(1,indx+indx2-1)<=30) )
          
           in=(qiege(1,indx+indx2)+qiege(1,indx+indx2-1))/2;
           in=fix(in);
           if(X4(1,in)>=50)
               qiege_end(1,indx)=qiege_end(1,indx)+10;
               qiege_end(1,indx-1)=qiege_end(1,indx-1)-10;
           end
           
       end
       
       
       
   end
   
    
   
    %% ======================字符分割——字符分割--切割中===============================      
    for i=1:7
          Z3=Z2(:,qiege_end(1,i*2-1):qiege_end(1,i*2),:);%二值化图像分割后
          word{i} = imresize(Z3,[32 16]);
%           figure(7);
%           subplot(1,7,i);
%           imshow(Z3);%将二值化图像分割后显示出来
    end
    
     figure;
    for i = 1:7
        subplot(5,7,i); imshow(word{i}),title(i);
    end
    
    
    % License plate character recognition
    characters = LicPlateRec(word);
    disp(characters); 
    figure,imshow(Z2),title(['车牌号码：',characters])
    
    
 

    
    
    
   