#!/bin/bash

RECORDS="
100 101 102 103 104 105 106 107 108 109
111 112 113 114 115 116 117 118 119 121
122 123 124 200 201 202 203 205 207 208
209 210 212 213 214 215 217 219 220 221
222 223 228 230 231 232 233 234"

for r in $RECORDS
do
	echo "Converting recording to Matlab format ..."
	wfdb2mat -r $r 
	rdann -r $r -a atr -p N V > $r".txt"
 	wrann -r $r -a fatr <$r".txt"
 	sigavg -r $r -a atr -p N -d -0.060 0.100 -f 0 -t 300 > $r"-avg.txt"
	echo "--------------------------------------------------"
done
