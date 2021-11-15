width=16;  %宽度是  
depth=256;  %深度是256                                   
   
   
value = zeros(1,256); 
value(1,1)=0x0211;
value(1,2)=0x0012;
value(1,3)=0x0110;
value(1,4)=0x0356;
value(1,0x56)=0x0400;
%===============================开始写mif文件===============================  
addr=0:depth-1;  
str_width=strcat('WIDTH=',num2str(width));  
str_depth=strcat('DEPTH=',num2str(depth));  
   
fid=fopen('C:\Users\zqliu\Desktop\romdata.mif','w');  %打开或者新建mif，存放位置和文件名任意  
                              %如果只写文件名，则在当前目录下建立此文件  
fprintf(fid,str_width);  
fprintf(fid,';\n');  
fprintf(fid,str_depth);  
fprintf(fid,';\n\n');  
fprintf(fid,'ADDRESS_RADIX=HEX;\n');  %因为下面的数据输入我选的是16进制，  
   
fprintf(fid,'DATA_RADIX=HEX;\n\n');  
fprintf(fid,'CONTENT BEGIN\n');  
fprintf(fid,'\t%X : %X;\n',[addr;value])  %开始写数据了  
fprintf(fid,'END;\n');  
fclose(fid);  