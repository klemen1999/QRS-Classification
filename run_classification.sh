#Matlab program and evaluation
#####
rm eval1.txt 2>/dev/null
rm eval2.txt 2>/dev/null
FILES=/mitbihDB/*.dat
for f in $FILES
do
 f=$(basename $f)
 f=${f%.*}

 echo $f
 wfdb2mat -r $f #convert records to Matlab format
 #extract only V and N beats from atr files into one text file for Matlab
 #and convert output to wfdb format using wrann to produce a reduced
 #annotation file which includes only N (normal) and V (abnormal) beats
 rdann -r $f -a atr -p N V > $f".txt"
 wrann -r $f -a fatr <$f".txt"
 #you will probably be interested in the second (fiducial point in samples)
 #and third (type of heart beat) columns in the latter two output files;
 #the produces .txt files can be read using the readannotations.m script
done
#Run algorithm in Matlab. Output should be annotations in text files
#with WFDB annotator structure. See Matlab frame on the webclassroom.
for f in $FILES
do
 f=$(basename $f)
 f=${f%.*}

 echo $f
 #evaluate using reference annotations .fatr and your annotations .cls
 wrann -r $f -a qrs < $f".cls" #convert text annotator to WFDB format
 bxb -r $f -a fatr cls -l eval1.txt eval2.txt
done
sumstats eval1.txt eval2.txt > results.txt #final statistics
