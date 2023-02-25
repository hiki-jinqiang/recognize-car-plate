%op
%读取图像文件
[filename,pathname]=uigetfile({'*.bmp';'*.jpg';...
    '*.gif';'*.*'},...
    'Pick an Image File');
X=imread([pathname,filename]);
%显示图像
axes(h0);%将h0设置为当前坐标轴句柄
imshow(X);%在h0上显示原始图像
y=filename;
y1=y(1);