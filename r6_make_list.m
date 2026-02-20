list1=textread('list_of_donut_interesting.txt','%s');
OUTDIR1='r6img/donut300';
mkdir(OUTDIR1);
for i=1:size(list1, 1)
    fname=strcat(OUTDIR1,'/',num2str(i,'%04d'),'.jpg')
    websave(fname, list1{i});
end
