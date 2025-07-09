#!/bin/bash
Rscript Gene_Meta_Cor.R 
for i in $(seq 1 1 4);
do
sed -i 's/,/\t/g' R_corr_pearsonSG_ME_r_${i}.csv
sed -i 's/,/\t/g' R_corr_pearsonSG_TF_r_${i}.csv
sed -i 's/,/\t/g' R_corr_pearsonTF_ME_r_${i}.csv
sed -i 's/Var1/fromNode/g' R_corr_pearsonTF_ME_r_${i}.csv
sed -i 's/Var1/fromNode/g' R_corr_pearsonSG_TF_r_${i}.csv
sed -i 's/Var1/fromNode/g' R_corr_pearsonSG_ME_r_${i}.csv
sed -i 's/Var2/toNode/g' R_corr_pearsonSG_ME_r_${i}.csv
sed -i 's/Var2/toNode/g' R_corr_pearsonSG_TF_r_${i}.csv
sed -i 's/Var2/toNode/g' R_corr_pearsonTF_ME_r_${i}.csv
sed -i 's/value/weight/g' R_corr_pearsonTF_ME_r_${i}.csv
sed -i 's/value/weight/g' R_corr_pearsonSG_TF_r_${i}.csv
sed -i 's/value/weight/g' R_corr_pearsonSG_ME_r_${i}.csv
grep 'TF' R_corr_pearsonSG_TF_${i}.txt | awk '{if($2!~/^TF/)print}' > R_corr_pearsonSG_TF_${i}_only.txt
grep 'TM' R_corr_pearsonSG_ME_${i}.txt | awk '{if($2!~/^TM/)print}' > R_corr_pearsonSG_ME_${i}_only.txt
grep 'TM' R_corr_pearsonTF_ME_${i}.txt | awk '{if($2!~/^TM/)print}' > R_corr_pearsonTF_ME_${i}_only.txt
awk '{if($1~/^TF/)print}' R_corr_pearsonSG_TF_${i}.txt | awk '{if($2~/^TF/)print}' > R_corr_pearsonTF_TF_${i}_only.txt
awk '{if($1~/^SG/)print}' R_corr_pearsonSG_TF_${i}.txt | awk '{if($2~/^SG/)print}' > R_corr_pearsonSG_SG_${i}_only.txt
awk '{if($1~/^TM/)print}' R_corr_pearsonTF_ME_${i}.txt | awk '{if($2~/^TM/)print}' > R_corr_pearsonME_ME_${i}_only.txt
awk '$4>=0.5 && $5<0.01 {print $0}' R_corr_pearsonTF_ME_${i}_only1.txt > R_corr_pearsonTF_ME_${i}_only1_sign05.txt
awk '$4>=0.8 && $5<0.01 {print $0}' R_corr_pearsonSG_TF_${i}_only1.txt > R_corr_pearsonSG_TF_${i}_only1_sign08.txt
awk '$4>=0.5 && $5<0.01 {print $0}' R_corr_pearsonSG_ME_${i}_only1.txt > R_corr_pearsonSG_ME_${i}_only1_sign05.txt
awk '$4>=0.8 && $5<0.01 {print $0}' R_corr_pearsonTF_TF_${i}_only1.txt > R_corr_pearsonTF_TF_${i}_only1_sign08.txt
awk '$4>=0.8 && $5<0.01 {print $0}' R_corr_pearsonSG_SG_${i}_only1.txt > R_corr_pearsonSG_SG_${i}_only1_sign08.txt
awk '$4>=0.5 && $5<0.01 {print $0}' R_corr_pearsonME_ME_${i}_only1.txt > R_corr_pearsonME_ME_${i}_only1_sign05.txt
awk '$0=NR"\t"$0' R_corr_pearsonSG_TF_${i}_only.txt > R_corr_pearsonSG_TF_${i}_only1.txt
awk '$0=NR"\t"$0' R_corr_pearsonSG_ME_${i}_only.txt > R_corr_pearsonSG_ME_${i}_only1.txt
awk '$0=NR"\t"$0' R_corr_pearsonTF_ME_${i}_only.txt > R_corr_pearsonTF_ME_${i}_only1.txt
awk '$0=NR"\t"$0' R_corr_pearsonTF_TF_${i}_only.txt > R_corr_pearsonTF_TF_${i}_only1.txt
awk '$0=NR"\t"$0' R_corr_pearsonSG_SG_${i}_only.txt > R_corr_pearsonSG_SG_${i}_only1.txt
awk '$0=NR"\t"$0' R_corr_pearsonME_ME_${i}_only.txt > R_corr_pearsonME_ME_${i}_only1.txt
cat R_corr_pearsonME_ME_${i}_only1_sign05.txt R_corr_pearsonSG_ME_${i}_only1_sign05.txt R_corr_pearsonSG_SG_${i}_only1_sign08.txt R_corr_pearsonSG_TF_${i}_only1_sign08.txt R_corr_pearsonTF_ME_${i}_only1_sign05.txt R_corr_pearsonTF_TF_${i}_only1_sign08.txt > R_corr_pearson_${i}_sign_final1.txt
sort -k 4 -r R_corr_pearson_${i}_sign_final1.txt | awk '!a[$4]++{print}' > R_corr_pearson_${i}_sign_final1_rsort.txt
sed -i 's/^/SGSG/' R_corr_pearsonSG_SG_${i}_only1.txt 
sed -i 's/^/SGTF/' R_corr_pearsonSG_TF_${i}_only1.txt
sed -i 's/^/TFME/' R_corr_pearsonTF_ME_${i}_only1.txt
sed -i 's/^/TFTF/' R_corr_pearsonTF_TF_${i}_only1.txt
cut -f 1 R_cor_Cluster_final_${i}_sign_all_rsort.txt > R_cor_Cluster_final_${i}_sign_all_rsort.ID
done
for i in $(seq 1 1 9); 
do
sed -i s'/TMC'${i}'\./TM/'g R_cor_Cluster_final_1_sign_all_rsort.txt
sed -i s'/TMC'${i}'\./TM/'g R_cor_Cluster_final_2_sign_all_rsort.txt
sed -i s'/TMC'${i}'\./TM/'g R_cor_Cluster_final_3_sign_all_rsort.txt
sed -i s'/TMC'${i}'\./TM/'g R_cor_Cluster_final_4_sign_all_rsort.txt
sed -i s'/C'${i}'/model/'g  R_cor_Cluster_final_1_sign_all_rsort.txt
sed -i s'/C'${i}'/model/'g  R_cor_Cluster_final_2_sign_all_rsort.txt
sed -i s'/C'${i}'/model/'g  R_cor_Cluster_final_3_sign_all_rsort.txt
sed -i s'/C'${i}'/model/'g  R_cor_Cluster_final_4_sign_all_rsort.txt
done
awk  -F ':'  '{print $1"\t"$2}' R_cor_Cluster_final_merge_sign_all_rsort.txt1 > R_cor_Cluster_final_merge_sign_all_rsort.txt2
cut -f 1 Final_Cluster_Network.txt > Final_Cluster_Network.ID1
cut -f 2 Final_Cluster_Network.txt > Final_Cluster_Network.ID2
cat Final_Cluster_Network.ID1 Final_Cluster_Network.ID2 | sort -k 1 -u > Final_Cluster_Network.ID
for i in $(seq 1 1 633);
do
awk '{if($1~/^TM'${i}'/)print}' Meta_Network.txt > ${i}_Network.txt
awk '{if($2~/^SG/)print}' ${i}_Network.txt > ${i}_SG_Network.txt
awk '{if($2~/^TM/)print}' ${i}_Network.txt > ${i}_TM_Network.txt
awk '{if($2~/^TF/)print}' ${i}_Network.txt > ${i}_TF_Network.txt
sort -k 3 -r ${i}_TF_Network.txt |head -n 1  > ${i}_TF_max.txt
sort -k 3 -r ${i}_TM_Network.txt |head -n 1  > ${i}_TM_max.txt
sort -k 3 -r ${i}_SG_Network.txt |head -n 1  > ${i}_SG_max.txt
done
shuf -n20000 Final_Meta_Meta_Network.txt > Final_Meta_Meta_Network_random.txt
shuf -n20000 Final_Meta_SG_Network.txt > Final_Meta_SG_Network_random.txt
shuf -n20000 Final_Meta_TF_Network.txt > Final_Meta_TF_Network_random.txt
cat Final_Meta_Meta_Network_random.txt Final_Meta_SG_Network_random.txt Final_Meta_TF_Network_random.txt > Final_Meta_Network_random.txt


