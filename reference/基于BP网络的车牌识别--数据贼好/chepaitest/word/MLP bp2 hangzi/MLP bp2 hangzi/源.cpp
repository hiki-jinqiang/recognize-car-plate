Mat inputs2(1195, 560, CV_32FC1, Scalar(0));
//初始化输入样本
ifstream file1("word.txt");
int imgindex2 = 0;
for (; imgindex2<1195; imgindex2++)  //表示文件流的结尾
{
	char txt_cont2[1195];//指针  
	file1.getline(txt_cont2, 1195); //获取字符串
	char imgfile2[1195];
	sprintf(imgfile2, "word/%s", txt_cont2);  //连接字符串
	Mat src2 = imread(imgfile2);//注意读取的图片被视为是真彩色图像
	cvtColor(src2, src2, CV_BGR2GRAY);
	resize(src2, src2, Size(32, 16));
	threshold(src2, src2, 0, 255, CV_THRESH_OTSU + CV_THRESH_BINARY);
	Mat charfeature2(1, 560, CV_32FC1, Scalar(0));
	features(src2, charfeature2);

	//Mat src1=src.reshape(0,1);
	for (int i = 0; i<560; i++)
	{
		inputs2.at<float>(imgindex2, i) = charfeature2.at<float>(0, i);
	}
}


//初始化输出样本
Mat outputs2(1195, 31, CV_32FC1, Scalar(0));
CvMLData mlData2;
mlData2.read_csv("wenzi.csv");//读取csv文件
outputs2 = Mat(mlData2.get_values(), true);

//训练函数的接口,输入矩阵， 预期输出矩阵，训练参数
bp2.train(inputs2, outputs2, Mat(), Mat(), params2);
bp2.save("mlp2.xml");