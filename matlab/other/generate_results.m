function generate_results( k,l,method )
[CM,recall,precision,falpha]= where_evaluation_happens('cleandata_students.txt',k,l,method);
xlswrite('CN',CM);
xlswrite('recall',recall);
xlswrite('precision',precision);
xlswrite('falpha',falpha);
foldername = [mat2str(k) '_L' mat2str(l) '_' method];
mkdir(foldername);
movefile('CN.csv',foldername);
movefile('recall.csv',foldername);
movefile('precision.csv',foldername);
movefile('falpha.csv',foldername);

end

