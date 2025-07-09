#!/bin/bash
#step1
for i in $(seq 1 1 9);
do
grep "cluster${i}"  Gene_Meta_Cluster_mean_cluster_kmeans.ID | cut -f 2 > Gene_Meta_Cluster_mean_cluster${i}_kmeans.ID
done
#step2 
cut -f 1,3 R_cor_Cluster_final_merge_sign_all_rsort.txt2 > R_cor_Cluster_final_merge_sign_all_rsort.1
cut -f 2,3 R_cor_Cluster_final_merge_sign_all_rsort.txt2 > R_cor_Cluster_final_merge_sign_all_rsort.2
#step3 
for i in $(seq 1 1 9);
do
grep -wFf Gene_Meta_Cluster_mean_cluster${i}_kmeans.ID R_cor_Cluster_final_merge_sign_all_rsort.1 | sed s'/model/C'${i}'/'g | sed s'/TM/TMC'${i}'\./'g > Gene_Meta_Cluster_mean_cluster${i}_kmeans.1
grep -wFf Gene_Meta_Cluster_mean_cluster${i}_kmeans.ID R_cor_Cluster_final_merge_sign_all_rsort.2 | sed s'/model/C'${i}'/'g | sed s'/TM/TMC'${i}'\./'g > Gene_Meta_Cluster_mean_cluster${i}_kmeans.2
done
#merge
cat Gene_Meta_Cluster_mean_cluster1_kmeans.1 Gene_Meta_Cluster_mean_cluster2_kmeans.1 Gene_Meta_Cluster_mean_cluster3_kmeans.1 Gene_Meta_Cluster_mean_cluster4_kmeans.1 Gene_Meta_Cluster_mean_cluster5_kmeans.1 Gene_Meta_Cluster_mean_cluster6_kmeans.1 Gene_Meta_Cluster_mean_cluster7_kmeans.1 Gene_Meta_Cluster_mean_cluster8_kmeans.1 Gene_Meta_Cluster_mean_cluster9_kmeans.1 > Gene_Meta_Cluster_mean_clusterall_kmeans.1
cat Gene_Meta_Cluster_mean_cluster1_kmeans.2 Gene_Meta_Cluster_mean_cluster2_kmeans.2 Gene_Meta_Cluster_mean_cluster3_kmeans.2 Gene_Meta_Cluster_mean_cluster4_kmeans.2 Gene_Meta_Cluster_mean_cluster5_kmeans.2 Gene_Meta_Cluster_mean_cluster6_kmeans.2 Gene_Meta_Cluster_mean_cluster7_kmeans.2 Gene_Meta_Cluster_mean_cluster8_kmeans.2 Gene_Meta_Cluster_mean_cluster9_kmeans.2 > Gene_Meta_Cluster_mean_clusterall_kmeans.2
#step4
awk -v OFS="\t" '{print $2,$1}' Gene_Meta_Cluster_mean_clusterall_kmeans.1 > Gene_Meta_Cluster_mean_clusterall_kmeans.11
awk -v OFS="\t" '{print $2,$1}' Gene_Meta_Cluster_mean_clusterall_kmeans.2 > Gene_Meta_Cluster_mean_clusterall_kmeans.21
sort -k 1 Gene_Meta_Cluster_mean_clusterall_kmeans.11 > Gene_Meta_Cluster_mean_clusterall_kmeans.12
sort -k 1 Gene_Meta_Cluster_mean_clusterall_kmeans.21 > Gene_Meta_Cluster_mean_clusterall_kmeans.22
#Merge
join Gene_Meta_Cluster_mean_clusterall_kmeans.12 Gene_Meta_Cluster_mean_clusterall_kmeans.22 > Gene_Meta_Cluster_mean_clusterall_kmeans.1122
awk -v OFS="\t" '{print $2,$3,$1}' Gene_Meta_Cluster_mean_clusterall_kmeans.1122 > R_cor_Cluster_final_merge_sign_all_rsort_clusterall.txt
