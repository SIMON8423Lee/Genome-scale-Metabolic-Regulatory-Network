#!/bin/bash
#for i in $(seq 1 1 9);
#do
#replace TM to KTM (add cluster information)
#grep -f K${i}_ME.ID R_corr_pearsonSG_ME_1_only.txt | sed s'/TM/K'${i}'_TM/'g  > R_corr_pearsonSG_ME_1_only_K${i}.txt

#split 4 rep file
#for i in $(seq 1 1 4);
#do
#split corr file by meta (per 633 line)
split -l 633 R_corr_pearsonSG_ME_1_only.txt -d -a 5 R_corr_pearsonSG_ME_1_only_
split -l 633 R_corr_pearsonTF_ME_1_only.txt -d -a 4 R_corr_pearsonTF_ME_1_only_  
#done

#replace TM to KTM (add cluster information)
#grep -f K${i}_ME.ID 

for i in $(seq -w 0 2390); 
do
   #replace TM to KTM (add cluster information)
   for C in $(seq 1 1 9)
   do
   grep -f K${C}_ME.ID R_corr_pearsonTF_ME_1_only_${i} | sed s'/TM/K'${C}'_TM/'g  > R_corr_pearsonTF_ME_1_only_${i}_K${C}
   #cat K file
   cat R_corr_pearsonTF_ME_1_only_${i}_K1 R_corr_pearsonTF_ME_1_only_${i}_K2 R_corr_pearsonTF_ME_1_only_${i}_K3 R_corr_pearsonTF_ME_1_only_${i}_K4 R_corr_pearsonTF_ME_1_only_${i}_K5 R_corr_pearsonTF_ME_1_only_${i}_K6 R_corr_pearsonTF_ME_1_only_${i}_K7 R_corr_pearsonTF_ME_1_only_${i}_K8 R_corr_pearsonTF_ME_1_only_${i}_K9 > R_corr_pearsonTF_ME_1_only_${i}_K
   #sort file by PCC values
   #sort -k 3 -r -n R_corr_pearsonSG_ME_1_only_${i} > R_corr_pearsonSG_ME_1_only_${i}_sort
   #sort -k 3 -r -n R_corr_pearsonSG_ME_2_only_${i} > R_corr_pearsonSG_ME_2_only_${i}_sort
   #sort -k 3 -r -n R_corr_pearsonSG_ME_3_only_${i} > R_corr_pearsonSG_ME_3_only_${i}_sort
   #sort -k 3 -r -n R_corr_pearsonSG_ME_4_only_${i} > R_corr_pearsonSG_ME_4_only_${i}_sort
   sort -k 3 -r -g R_corr_pearsonTF_ME_1_only_${i}_K > R_corr_pearsonTF_ME_1_only_${i}_K_sort
   #sort -k 3 -r -n R_corr_pearsonTF_ME_2_only_${i}_K > R_corr_pearsonTF_ME_2_only_${i}_sort
   #sort -k 3 -r -n R_corr_pearsonTF_ME_3_only_${i} > R_corr_pearsonTF_ME_3_only_${i}_sort
   #sort -k 3 -r -n R_corr_pearsonTF_ME_4_only_${i} > R_corr_pearsonTF_ME_4_only_${i}_sort
   #extract max PCC value
   head -n 1 R_corr_pearsonTF_ME_1_only_${i}_K_sort > R_corr_pearsonTF_ME_1_only_${i}_K_sort_max
   done
done

#sort SG file (23594 SGs) by PCC values
for i in $(seq -w 0 23594);
do
    #replace TM to KTM (add cluster information)
    for C in $(seq 1 1 9)
    do
    grep -f K${C}_ME.ID R_corr_pearsonSG_ME_1_only_${i} | sed s'/TM/K'${C}'_TM/'g  > R_corr_pearsonSG_ME_1_only_${i}_K${C}
    #cat K file
    cat R_corr_pearsonSG_ME_1_only_${i}_K1 R_corr_pearsonSG_ME_1_only_${i}_K2 R_corr_pearsonSG_ME_1_only_${i}_K3 R_corr_pearsonSG_ME_1_only_${i}_K4 R_corr_pearsonSG_ME_1_only_${i}_K5 R_corr_pearsonSG_ME_1_only_${i}_K6 R_corr_pearsonSG_ME_1_only_${i}_K7 R_corr_pearsonSG_ME_1_only_${i}_K8 R_corr_pearsonSG_ME_1_only_${i}_K9 > R_corr_pearsonSG_ME_1_only_${i}_K
    ##sort file by PCC values
    sort -k 3 -r -g R_corr_pearsonSG_ME_1_only_${i}_K > R_corr_pearsonSG_ME_1_only_${i}_K_sort
    #sort -k 3 -r -n R_corr_pearsonSG_ME_2_only_${i} > R_corr_pearsonSG_ME_2_only_${i}_sort
    #sort -k 3 -r -n R_corr_pearsonSG_ME_3_only_${i} > R_corr_pearsonSG_ME_3_only_${i}_sort
    #sort -k 3 -r -n R_corr_pearsonSG_ME_4_only_${i} > R_corr_pearsonSG_ME_4_only_${i}_sort
    #extract max PCC value
    head -n 1 R_corr_pearsonSG_ME_1_only_${i}_K_sort > R_corr_pearsonSG_ME_1_only_${i}_K_sort_max
    done
done

#cat all max file
cat *_max > Cluster_all_gene_by_meta_corr.txt
#extract gene by cluster
for i in $(seq 1 1 9);
do
grep "K${i}_" Cluster_all_gene_by_meta_corr.txt > Cluster_${i}_gene_by_meta_corr.txt
done
