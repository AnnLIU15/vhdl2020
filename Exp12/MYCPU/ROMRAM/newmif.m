width=16;  %�����  
depth=256;  %�����256                                   
   
   
value = zeros(1,256); 
value(1,1)=0x0211;
value(1,2)=0x0012;
value(1,3)=0x0110;
value(1,4)=0x0356;
value(1,0x56)=0x0400;
%===============================��ʼдmif�ļ�===============================  
addr=0:depth-1;  
str_width=strcat('WIDTH=',num2str(width));  
str_depth=strcat('DEPTH=',num2str(depth));  
   
fid=fopen('C:\Users\zqliu\Desktop\romdata.mif','w');  %�򿪻����½�mif�����λ�ú��ļ�������  
                              %���ֻд�ļ��������ڵ�ǰĿ¼�½������ļ�  
fprintf(fid,str_width);  
fprintf(fid,';\n');  
fprintf(fid,str_depth);  
fprintf(fid,';\n\n');  
fprintf(fid,'ADDRESS_RADIX=HEX;\n');  %��Ϊ���������������ѡ����16���ƣ�  
   
fprintf(fid,'DATA_RADIX=HEX;\n\n');  
fprintf(fid,'CONTENT BEGIN\n');  
fprintf(fid,'\t%X : %X;\n',[addr;value])  %��ʼд������  
fprintf(fid,'END;\n');  
fclose(fid);  