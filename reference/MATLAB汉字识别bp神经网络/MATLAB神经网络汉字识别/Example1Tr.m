M=1;
N=3*M;

for kk=0:N-1
    p1=ones(64,64);
    m=strcat(int2str(kk),'.BMP');
    x=imread(m,'BMP');
    bw=im2bw(x,0.5);
    
    [i,j]=find(bw==0);
    
    imin=min(i);
    imax=max(i);
    jmin=min(j);
    jmax=max(j);
    bw1=bw(imin:imax,jmin:jmax);
    
    rate=64/max(size(bw1));
    bw1=imresize(bw1,rate);
    
    [i,j]=size(bw1);
    i1=round((64-i)/2);
    j1=round((64-j)/2);
    p1(i1+1:i1+i,j1+1:j1+j)=bw1;
    p1=-1.*p1+ones(64,64);
    
    for m=0:63
        p(m*64+1:(m+1)*64,kk+1)=p1(1:64,m+1);
    end
end

for kk=0:M-1
    for ii=0:2
        t(kk+ii+1)=ii;
    end
end

pr(1:4096,1)=0;
pr(1:4096,2)=1;

net=newff(pr,[30 1],{'logsig' 'purelin'},'traingdx','learngdm');
net.trainParam.epochs=2500;
net.trainParam.goal=0.001;
net.trainParam.show=10;
net.trainParam.lr=0.05;
net=train(net,p,t);