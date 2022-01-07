#!/bin/bash

rm eval1.txt 2> /dev/null
rm eval2.txt 2> /dev/null

saveName=${1:-"results"}

skipMitbih=("107" "109" "111" "118" "124" "207" "214" "232")

FILES="."/*
for f in $FILES
do
	f=$(basename $f)
	if [[ $f =~ \.mat$ ]]; then
		name=${f%m.mat*}
		if [[ " ${skipMitbih[*]} " =~ " ${name} " ]]; then
		   echo "Skipped file $name"
		   continue
		fi

		wrann -r $name -a qrs < $name".cls"
		bxb -r $name -a fatr qrs -l eval1.txt eval2.txt
	fi
done

sumstats eval1.txt eval2.txt > $saveName.txt

line=$(tail -n 6 "$saveName.txt" | head -n1)
line=$(echo "$line" | tr -s " ")
read -a elements <<< $line

Tp=${elements[1]}
Fp=${elements[2]}
Fn=${elements[5]}
Tn=${elements[6]}

Sensitivity=$(echo "scale=3; $Tp/($Tp+$Fn)"|bc -l)
Specificity=$(echo "scale=3; $Tn/($Tn+$Fp)"|bc -l)
PositivePredictivity=$(echo "scale=3; $Tp/($Tp+$Fp)"|bc -l)

outString="Results: Sensitivity=$Sensitivity, Specificity=$Specificity, PosPredictivity=$PositivePredictivity"
sed -i "1s/^/$outString\n/" $saveName.txt
echo $outString

