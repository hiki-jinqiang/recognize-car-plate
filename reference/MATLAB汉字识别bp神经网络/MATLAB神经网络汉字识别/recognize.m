%recognize
%����������ʽ
M=figure('Color',[0.75 0.75 0.75],...
    'position',[200 200 400 200],...
    'Name','����BP������ĺ���ʶ����',...
    'NumberTitle','off',...
    'MenuBar','none');
M0=uicontrol(M,'Style','push',...
    'Position',[150 80 130 40],...
    'String','����ѵ������',...
    'FontSize',12,...
       'call','delete(M(1)) ' );  
    y=filename;
    y1=y(1);
    p1=ones(64,64);%��ʼ��16*16�Ķ�ֵͼ��ȫ�ף�
    m=strcat(y1,'.BMP');%�γ��ļ���
    x=imread(m,'BMP');%��ȡͼ��
    bw=im2bw(x,0.5);%ת���ɶ�ֵͼ������
    %�þ��ο��ȡ
    [i,j]=find(bw==0);%��������Ϊ�ڵ�����
    %ȡ�߽�����
    imin=min(i);
    imax=max(i);
    jmin=min(j);
    jmax=max(j);
    bw1=bw(imin:imax,jmin:jmax);%��ȡ
    %�������������ų�16*16��ͼ��
    rate=64/max(size(bw1));
    bw1=imresize(bw1,rate);%�����ת�����
    %��bw1ת���ɱ�׼��16*16ͼ��p1
    [i,j]=size(bw1);
    i1=round((64-i)/2);
    j1=round((64-j)/2);
    p1(i1+1:i1+i,j1+1:j1+j)=bw1;
    p1=-1.*p1+ones(64,64);
    %��ʾÿ����ĸ�ľ���
    disp(p1);
    %��p1ת������������
    
    for m=0:63
        q(m*64+1:(m+1)*64,1)=p1(1:64,m+1);
    end
%��ʾ��������
disp(q);
%ʶ��
[a,Pf,Af]=sim(net,q);
disp(a);
a=round(a);
disp(a);
msgbox('����ϵ΢�ţ�matlab2022')