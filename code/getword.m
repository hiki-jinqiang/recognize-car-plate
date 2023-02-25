function [word, result] = getword(d)
% 分割字符
% d,输入待分割字符图�?% word,输出�?��分割后的字符图像
% result,输出分割后剩余的字符图像
word = [];
flag = false;
y1 = 8;
y2 = 0.5;
while flag == false
    [m, n] = size(d);
    wide = 0;
    while sum(d(:,wide+1))>0 && wide<n-1
        wide = wide+1;
    end
    temp = qiege(imcrop(d,[1 1 wide m])); % 用于返回图像的一个裁剪区�?     [m1, n1] = size(temp);
    if wide<y1 && n1/m1<y2 % 宽度小于8且宽高比小于0.5
        d(:,1:wide) = 0;
        if sum(sum(d)) > 0
            d = qiege(d); % 切割出最小范�?        else
            word = [];
            flag = true;
        end
    else
        word = qiege(imcrop(d,[1 1 wide m]));
        d(:,1:wide) = 0;
        if sum(sum(d)) > 0
            d = qiege(d);
            flag = true;
        else
            d = [];
        end
    end
end
result = d;
end