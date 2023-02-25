clear,clc,close all
% ����ʶ��
%% ======================���ƶ�λ��������ͼ��===============================
[filename, pathname] = uigetfile('*.jpg;*.bmp;*.png;*.tif', 'ѡ����ͼ��');
inital_imag = imread([pathname filename]);
inital_imag=imresize(inital_imag,[1200,1600]);              %�̶�����ͼƬ�Ĵ�С
double_imag = im2double(inital_imag);
figure,imshow(inital_imag);title('��ɫͼƬ');

%% ======================���ƶ�λ--��ɫ�ж�--ͼƬ��ɫ�Ӽ�===============================

imag_clore=1.5*inital_imag(:,:,3)-inital_imag(:,:,1)-inital_imag(:,:,2);        %��ɫ*1.5-��ɫ-��ɫ
% figure,imshow(imag_clore);title('��ɫ�����Ľ��');%����ڰ�ͼ��

BW = imbinarize(imag_clore);                                                    %��ֵ��
% figure,imshow(BW);title('��ֵ��');%����ڰ�ͼ��
I2=BW;

%% ======================���ƶ�λ--��ɫ�ж�--ͼƬ��ʴ===============================
SE = strel('line',3,90);
I3 = imerode(I2,SE);                % ��ʴ
SE = strel('rectangle',[10,30]);
I4 = imclose(I3,SE);            %   ������  --ͼ����࣬���ͼ��
I4=bwareaopen(I4,1000);%�Ƴ����С��2000��ͼ��
% figure,imshow(I4);title('��ʴ');%����ڰ�ͼ��
imag_imclose=I4;

%% ======================���ƶ�λ--��ɫ�ж�--��ɫ������===============================  

[L,num] = bwlabel(imag_imclose,8);          %��ע������ͼ���������ӵĲ���,c3����̬ѧ������ͼ��
Feastats =regionprops(L,'basic');           %����ͼ������������ߴ�
Area=[Feastats.Area];                       %�������
BoundingBox=[Feastats.BoundingBox]          ;%[x y width height]���ƵĿ�ܴ�С
RGB = label2rgb(L,'spring','k','shuffle'); %��־ͼ����RGBͼ��ת��
% figure;imshow(RGB);title('��ɫͼ');          


%% ======================���ƶ�λ--��ɫ�ж�---�����ж϶�λ===============================    
lx=1;%ͳ�ƿ�͸�����Ҫ��Ŀ��ܵĳ����������
region=1;
Getok=zeros(1,10);%ͳ������Ҫ�����
for l=1:num  %num�ǲ�ɫ����������
width=BoundingBox((l-1)*4+3);
hight=BoundingBox((l-1)*4+4);
rato=width/hight;%���㳵�Ƴ����
%������֪�Ŀ�ߺͳ��ƴ���λ�ý���ȷ����
if( rato>2&&rato<8) %�����Ҫ���������ű��
        Getok(lx)=l;
        lx=lx+1;  
        region=l;
end
end
startrow=1;startcol=1; 
% [original_hihgt original_width]=size(cA);
 fprintf('����λ�����������������lx=%d\r\n',lx);
 fprintf('����λ���������num=%d\r\n',num);
 fprintf('����λ�������region=%d\r\n',region);
 %��������region
 
 %% ======================���ƶ�λ--��ɫ�ж�---��ʾͼƬ===============================    
  if((lx>=1&&lx==2)|| num==1)                               %��������������ɫʶ����ȷ�������ʹ����̬��ʶ��
  startcol2=round(BoundingBox((region-1)*4+1)-2);%��ʼ��
  startrow2=round(BoundingBox((region-1)*4+2)-2);%��ʼ��  
  width2=BoundingBox((region-1)*4+3)+2;%���ƿ�
  hight2=BoundingBox((region-1)*4+4)+2;%���Ƹ� 
  uncertaincy_area2=inital_imag(startrow2:startrow2+hight2,startcol2:startcol2+width2-1); %��ȡ���ܳ�������
%   subplot(2,1,2),imshow(mat2gray(uncertaincy_area2));
  figure,imshow(mat2gray(uncertaincy_area2));title('�����');
 end
 
 
 %% ======================���ƶ�λ--��̬�����ж�===============================    
 if(lx>2)           %��̬������
      %% =========��̬�����ж�---Ԥ����================    
         gray_imag=rgb2gray(double_imag);
         s=strel('disk',10);%strei����
         Bgray=imopen(gray_imag,s);% ��������� ��sgray sͼ��
        % figure,imshow(Bgray);title('����ͼ��');%�������ͼ��
        % %��ԭʼͼ���뱳��ͼ������������ǿͼ��
        im=imsubtract(gray_imag,Bgray);%����ͼ���
        figure,imshow(mat2gray(gray_imag));title('��ǿ�ڰ�ͼ��');%����ڰ�ͼ��
         
        %% ======================��̬�����ж�---С���任===============================
        [Lo_D,Hi_D]=wfilters('db2','d'); % d Decomposition filters
        [C,S]= wavedec2(im,1,Lo_D,Hi_D); %Lo_D  is the decomposition low-pass filter
                                            % decomposition vector C    corresponding bookkeeping matrix S
        isize=prod(S(1,:));%Ԫ������
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
%         ��ʾС���任���ͼƬ
%         subplot(221),imagesc(cA);
% 
%         subplot(222),imagesc(cH);
% 
%         subplot(223),imagesc(cV);
% 
%         subplot(224),imagesc(cD);

        %% ======================��̬�����ж�---��̬ѧ����===============================
        I2=edge(cV,'sobel',0.020,'vertical');   %������ָ�������ж���ֵthresh������ָ���ķ���direction�ϣ�
        figure,imshow(I2);title('�Ӷ������Ƴ�С����');  
        a1=imclearborder(I2,8);                  %8��ͨ ���ƺ�ͼ��߽�������������
        se=strel('rectangle',[10,35]);              %[10,20]
        I4=imclose(a1,se);
        st=ones(1,8);                           %ѡȡ�ĽṹԪ��
        bg1=imclose(I4,st);                     %������
        bg3=imopen(bg1,st);                     %������
        bg2=imopen(bg3,[1 1 1 1]'); 
        I5=bwareaopen(bg2,1000);                %�Ƴ����С��2000��ͼ��
        I5=imclearborder(I5,4);                 %8��ͨ ���ƺ�ͼ��߽�������������
%         figure,imshow(I5);title('��ʴ��Ĳ���');  
        
         %���ó���Ƚ�������ɸѡ
        [L1,num1] = bwlabel(I5,8);              %��ע������ͼ���������ӵĲ���,c3����̬ѧ������ͼ��
        Feastats =regionprops(L1,'basic');      %����ͼ������������ߴ�
        Area=[Feastats.Area];%�������
        BoundingBox=[Feastats.BoundingBox];         %[x y width height]���ƵĿ�ܴ�С
        RGB = label2rgb(L1,'spring','k','shuffle');     %��־ͼ����RGBͼ��ת��
        figure;imshow(RGB);title('��ɫͼ');
        
        
        %% ======================��̬�����ж�---��������ж϶�λ===============================    
        lx1=1;                      %ͳ�ƿ�͸�����Ҫ��Ŀ��ܵĳ����������
        Getok=zeros(1,10);          %ͳ������Ҫ�����
        for l=1:num1                %num�ǲ�ɫ����������
        width=BoundingBox((l-1)*4+3);
        hight=BoundingBox((l-1)*4+4);
        rato=width/hight;               %���㳵�Ƴ����
        %������֪�Ŀ�ߺͳ��ƴ���λ�ý���ȷ����
        if( (rato>2&&rato<10)&&width>15&&hight>8) %width>50 & width<1500 & hight>15 & hight<600
                Getok(lx1)=l;
                lx1=lx1+1;  
        end
        end
        startrow=1;startcol=1;
        [original_hihgt, original_width]=size(cA);
         fprintf('����λ�������lx1=%d\r\n',lx1);
          count=1;
          
         cv=imresize(gray_imag,[601,801]);
         
      %% ======================��̬�����ж�---��ֱͶӰ�����ֵ��λ===============================    
        for order_num=1:lx1-1                               %���ô�ֱͶӰ�����ֵ������ȷ������
          area_num=Getok(order_num);
          startcol=round(BoundingBox((area_num-1)*4+1)-2);  %��ʼ��
          startrow=round(BoundingBox((area_num-1)*4+2)-2);  %��ʼ��  
          width=BoundingBox((area_num-1)*4+3)+2;            %���ƿ�
          hight=BoundingBox((area_num-1)*4+4)+2;            %���Ƹ� 
          uncertaincy_area=cA(startrow:startrow+hight,startcol:startcol+width-1); %��ȡ���ܳ�������
          image_binary=imbinarize(uncertaincy_area);                    %ͼ���ֵ��
          histcol_unsure=sum(uncertaincy_area);                         %���㴹ֱͶӰ
           histcol_unsure=smooth(histcol_unsure)';                      %ƽ���˲�
              histcol_unsure=smooth(histcol_unsure)';                   %ƽ���˲�
              average_vertical=mean(histcol_unsure);
          figure,subplot(2,1,1),bar(histcol_unsure);
          subplot(2,1,2),imshow(mat2gray(uncertaincy_area));
          [data_1 ,data_2]=size(histcol_unsure);
          peak_number=0; %�жϷ�ֵ����
          for j=2:data_2-1%�жϷ�ֵ����
              if (histcol_unsure(j)>histcol_unsure(j-1))&&(histcol_unsure(j)>histcol_unsure(j+1))
                  peak_number=peak_number+1;
              end
          end
          fprintf('�߷�ֵ���%d�ǣ�%d\n\r',order_num,peak_number);
           valley_number=0; %�жϲ��ȸ���
          for j=2:data_2-1
              if (histcol_unsure(j)<histcol_unsure(j-1))&&(histcol_unsure(j)<histcol_unsure(j+1)) &&(histcol_unsure(j)<average_vertical)
                   %����ֵ��ƽ��ֵС
                  valley_number=valley_number+1;
              end
          end 
          fprintf('�ͷ�ֵ���%d�ǣ�%d\n\r',order_num,peak_number);
          %peak_number<=15
         if peak_number>=4 && peak_number<=30 &&valley_number>=2 && valley_number<=30
             %��һ��ȷ�Ͽ�������
             select_unsure_area(count)=area_num;
             standard_deviation(count)=std2(histcol_unsure);%�����׼��
             count=count+1;
         end  ,
        end
        %% ======================��̬�����ж�---��׼���жϳ���λ��===============================  
        fprintf('�ͷ�ֵ���%d�ǣ�%d\n\r',order_num,peak_number);
        fprintf('��ֵ����Ľ��num=%d\n\r',count);
        correct_num_area=0;
        max_standard_deviation=0;
        % if(count<=2) %����һ������
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

          startcol2=round(BoundingBox((correct_num_area-1)*4+1)-2);%��ʼ��
          startrow2=round(BoundingBox((correct_num_area-1)*4+2)-2);%��ʼ��  
          width2=BoundingBox((correct_num_area-1)*4+3)+2;%���ƿ�
          hight2=BoundingBox((correct_num_area-1)*4+4)+2;%���Ƹ� 
          uncertaincy_area2=cv(startrow2:startrow2+hight2,startcol2:startcol2+width2-1); %��ȡ���ܳ�������
        %   subplot(2,1,2),imshow(mat2gray(uncertaincy_area2));
%         figure,imshow(mat2gray(uncertaincy_area2));title('�����');   
                   
 end
 
     imag_cardetect=im2double(uncertaincy_area2);       %����ɫ����̬ѧ�Ľ��������imag-cardetect��
 %% ======================�ַ��ָ���ߴ����Ԥ����===============================
%   figure,imshow(mat2gray(imag_cardetect));title('�ַ��ָ������ͼƬ');
    imag_detecter=imresize(imag_cardetect,[140,440]); %�ߴ绯
    figure,imshow(imag_detecter);title('�ߴ绯����');      
    
 %% ======================�ַ��ָ����б����===============================
    
    bw1=edge(imag_detecter,'sobel','horizontal');
    figure,imshow(bw1);title('sobel���');  
    
    theta = 1:180;
    [R,xp] = radon(bw1,theta);
    [I,J] = find(R>=max(max(R)));                 %J��¼����б��
    angle=90-J;
    A=imrotate(imag_detecter,angle,'crop');%��ͼ�������ת����
     figure,imshow(A);title('������');       
    
    level = graythresh(A);  
    a=im2bw(A,level);  
%     figure,imshow(a);title('û��ȥ����ֵ��');    %�����ʧ��û�а취
%     a=bwareaopen(a,20);%�Ƴ����С��5000��ͼ��
%     figure,imshow(a);title('��ֵ��');
    
%% ======================�ַ��ָ�������������ص�ͳ�ƺ��и�===============================
        [y,x]=size(a);
        Y1=zeros(y,1);
        Y2=zeros(y,1);
  for i=1:y
      n=0;
   for j=1:x
    if(a(i,j,1)==1) 
        Y1(i,1)= Y1(i,1)+1;%����I3��j���м���һ
    end  
    if(a(i,j,1)~=n)
        Y2(i,1)= Y2(i,1)+1;
        n=a(i,j,1);
    end
   end       
 end
    figure(2);
%     plot(Y1,0:y-1),title('�з������ص�Ҷ�ֵ�ۼƺ�'),xlabel('�ۼ�������'),ylabel('��');
    figure(3);
%     plot(Y2,0:y-1),title('����'),xlabel('����'),ylabel('��');
    
    
    Py0=fix(y/2);
    Py1=fix(y/2)+1;
    while ((Y1(Py0,1)>=50)&&(Py0>2))
     Py0=Py0-1;%�ҵ�ȥ���߿���ϱߵ�λ��
    end
    while ((Y1(Py1,1)>=50)&&(Py1<y))
     Py1=Py1+1;%�ҵ�ȥ���߿���±ߵ�λ��
    end
    Z1=a(Py0:Py1,:,:);%����ֵͼ�����±߿�ȥ��
    figure(3);
    imshow(Z1),title('����ֵͼ�����±߿�ȥ����ͼ��');
    
    
    
  %% ======================�ַ��ָ��ȥԭ��===============================   
    Z1=bwareaopen(Z1,150);%�Ƴ����С��5000��ͼ��
    figure;
    imshow(Z1),title('ȥ��Բ��ͼ��');
 

 %% ======================�ַ��ָ��ԭͼ�������������ص�ͳ��===============================
%     X1=zeros(1,x);
%     for j=1:x
%     for i=1:y
%      if(a(i,j,1)==1) 
%       X1(1,j)= X1(1,j)+1;%����I3��j���м���һ
%       end  
%         end       
%      end
%     figure(4);
%     plot(0:x-1,X1),title('�з������ص�Ҷ�ֵ�ۼƺ�'),xlabel('��ֵ'),ylabel('�ۼ�����');

%  %% ======================�ַ��ָ����ֱ�ָ�===============================
%     
%     [y,x]=size(Z1);%�����ʱͼ��Ĵ�С
%     X1=zeros(1,x);
%     for j=1:x
%     for i=1:y
%      if(Z1(i,j,1)==1) 
%       X1(1,j)= X1(1,j)+1;%����I3��j���м���һ
%       end  
%         end       
%      end
%     figure(4);
%     plot(0:x-1,X1),title('�з������ص�Ҷ�ֵ�ۼƺ�'),xlabel('��ֵ'),ylabel('�ۼ�����');
% 
%     
%     
%     x1=fix(x/2)+1;
%     for i=1:6
%     while (i~=6)
%         while ((X1(1,x1)>=13)&&(x1<x))
%          x1=x1+1;%�ҵ�ȥ���߿���ұߵ�λ��
%         end
%          i=i+1;
%         while ((X1(1,x1)<13)&&(x1<x)&&(i<5))
%         x1=x1+1;%�ӳ����м俪ʼѰ���ַ���϶��ֱ���ҵ����ĸ���϶%Ϊֹ�����ҵ�ȥ���߿�����ұߵ�λ��
%         end   
%     end
%     end
% %     fprintf('��ֱ�и�%d�ǣ�%d\n\r',order_num,peak_number);
%     x0=fix(x*45/440);%�ҵ���һ���ַ���λ��
%     for i=1:2
%     while (i~=2)
%        while ((X1(1,x0)>=5)&&(x0>2))
%         x0=x0-1;%�ӳ��Ƶĵ�һ���ַ���ʼѰ�ҵ�һ���ַ���϶���ҵ�%ȥ���߿���ߵ�λ��
%         end
%           i=i+1;
%          while ((X1(1,x0)<5)&&(x0>1)&&i~=2)
%          x0=x0-1;%�ҵ�ȥ���߿����ߵ�λ��
%          end   
%     end
%     end
%     Z2=Z1(:,x0:x1,:);%����ֵͼ�����ұ߿�ȥ��
%     figure(5);
% %     imshow(Z2),title('����ֵͼ��ֱ�߿�ȥ����ͼ��');
    Z2=Z1;

  %% ======================�ַ��ָ���ַ��ָ�--��������===============================   
    [yz2,xz2]=size(Z2);%�����ʱͼ��Ĵ�С
    X4=zeros(1,xz2);
   for j=1:xz2
    for i=1:yz2
     if(Z2(i,j,1)==1) 
      X4(1,j)= X4(1,j)+1;%����I3��j���м���һ
      end  
    end       
  end
    figure(4);
    plot(0:xz2-1,X4),title('Ҫ�и��ͼ��������'),xlabel('��ֵ'),ylabel('�ۼ�����');
    
    px0=1;
    px1=1;
    indx=1;
    pxabs=zeros(1,x);
    pxpos=zeros(1,x);
    for i=1:xz2-1
        pxabs(1,i)=abs( X4(1,i)-X4(1,i+1) );     %����ֵ��������������
       if( (pxabs(1,i)<=5) && (X4(1,i)<=5) )
           pxpos(1,indx)=i;                        %����ֵ����10��λ�ñ�����λ����������
           indx=indx+1;
           fprintf('����Ҫ�������%d\r\n',i);
       end
 
    end
    figure(5);
    plot(0:x-1,pxabs),title('��ֵ'),xlabel('��ֵ'),ylabel('��');
    
    
    %% ======================�ַ��ָ���ַ��ָ�--�и�λ�õ��ж�1=============================== 
    index=1;
    pos0=1;
    pos1=1;
    qiege=zeros(1,40);
    for j=1:x-1
        if( pxpos(1,j)~=0)
           if( abs(  pxpos(1,j+1)- pxpos(1,j) ) >=15)   %����̫�󣬲�Ȼ ��1�� ʶ����
               qiege(1,index)=pxpos(1,j);
               index=index+1;
               qiege(1,index)=pxpos(1,j+1);
               index=index+1;
              
           end
        end
    end
    
   %% ======================�ַ��ָ���ַ��ָ�--�и��λ�ú��� ��  ��1  ���ر���===============================    
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
   
    
   
    %% ======================�ַ��ָ���ַ��ָ�--�и���===============================      
    for i=1:7
          Z3=Z2(:,qiege_end(1,i*2-1):qiege_end(1,i*2),:);%��ֵ��ͼ��ָ��
          word{i} = imresize(Z3,[32 16]);
%           figure(7);
%           subplot(1,7,i);
%           imshow(Z3);%����ֵ��ͼ��ָ����ʾ����
    end
    
     figure;
    for i = 1:7
        subplot(5,7,i); imshow(word{i}),title(i);
    end
    
    
    % License plate character recognition
    characters = LicPlateRec(word);
    disp(characters); 
    figure,imshow(Z2),title(['���ƺ��룺',characters])
    
    
 

    
    
    
   