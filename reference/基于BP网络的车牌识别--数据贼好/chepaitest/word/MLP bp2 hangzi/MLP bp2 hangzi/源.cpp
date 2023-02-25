Mat inputs2(1195, 560, CV_32FC1, Scalar(0));
//��ʼ����������
ifstream file1("word.txt");
int imgindex2 = 0;
for (; imgindex2<1195; imgindex2++)  //��ʾ�ļ����Ľ�β
{
	char txt_cont2[1195];//ָ��  
	file1.getline(txt_cont2, 1195); //��ȡ�ַ���
	char imgfile2[1195];
	sprintf(imgfile2, "word/%s", txt_cont2);  //�����ַ���
	Mat src2 = imread(imgfile2);//ע���ȡ��ͼƬ����Ϊ�����ɫͼ��
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


//��ʼ���������
Mat outputs2(1195, 31, CV_32FC1, Scalar(0));
CvMLData mlData2;
mlData2.read_csv("wenzi.csv");//��ȡcsv�ļ�
outputs2 = Mat(mlData2.get_values(), true);

//ѵ�������Ľӿ�,������� Ԥ���������ѵ������
bp2.train(inputs2, outputs2, Mat(), Mat(), params2);
bp2.save("mlp2.xml");