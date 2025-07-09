#!/bin/bash
#get k-means gene to meta list
for i in $(seq 1 1 9); do mv gene+meta_cluster${i}.txt gene+meta_rep1_cluster${i}.txt; done
for i in $(seq 1 1 9); do Rscript melt.R -e gene_meta_rep1_cluster${i}.txt -o ./${i}; done  
for i in $(seq 1 1 9); do mv ${i}/melt.txt ./gene_meta_rep1_melt_cluster${i}.txt; done
rm -r 1 2 3 4 5 6 7 8 9
for i in $(seq 1 1 9); do cut -f 1-2 gene_meta_rep1_melt_cluster${i}.txt > gene_meta_rep1_kmeans_cluster${i}.ID; done 
cat *.ID > gene_meta_rep1_kmeans_all.ID
sort -k 1 gene_meta_rep1_kmeans_all.ID |uniq > gene_meta_rep1_kmeans_all.ID1
for i in $(seq 1 1 9); do sed -i s'/TMC'${i}'\./TM/' gene_meta_rep1_kmeans_all.ID1; done 
for i in $(seq 1 1 9); do sed -i s'/C'${i}'/model/'g gene_meta_rep1_kmeans_all.ID1; done 
awk '{$1=$1":"$2;print $0}' gene_meta_rep1_kmeans_all.ID1 > gene_meta_rep1_kmeans_all.ID2 
cut -d' ' -f 1 gene_meta_rep1_kmeans_all.ID2 > gene_meta_rep1_kmeans_all.ID3
mv gene_meta_rep1_kmeans_all.ID3 gene_meta_rep1_kmeans_all.ID1

#get corr gene to meta list
for i in $(seq 1 1 9); do sed -i s'/K'${i}'\_//'g Cluster_all_gene_by_meta_corr_sort.ID; done 
awk '{print $2,$1}' Cluster_all_gene_by_meta_corr_sort.ID > Cluster_all_gene_by_meta_corr_sort.ID1 
awk '{$1=$1":"$2;print $0}' Cluster_all_gene_by_meta_corr_sort.ID1 > Cluster_all_gene_by_meta_corr_sort.ID2 
cut -d' ' -f1 Cluster_all_gene_by_meta_corr_sort.ID2 > Cluster_all_gene_by_meta_corr_sort.ID3
mv Cluster_all_gene_by_meta_corr_sort.ID3 Cluster_all_gene_by_meta_corr_sort.ID1

#merge k-means and corr cluster
grep -f Cluster_all_gene_by_meta_corr_sort.ID1 gene_meta_rep1_kmeans_all.ID1 > final.txt #merge
awk  -F ':'  '{print $1"\t"$2}' final.txt > final.txt1 #分列
for i in $(seq 1 1 9); do sed -i s'/C'${i}'/model/'g Gene_Cluster_rep1_cluster_kmeans.ID; done 
cut -f 1 final.txt1 > final.ID
grep -wFf final.ID Gene_Cluster_rep1_cluster_kmeans.ID > Gene_Cluster_rep1_cluster_final.ID 
for i in $(seq 1 1 9); do grep "cluster${i}"  Gene_Cluster_rep1_cluster_final.ID > Gene_Cluster_rep1_cluster${i}_final.ID; sed -i s'/model/C'${i}'/'g Gene_Cluster_rep1_cluster${i}_final.ID; done 

for i in $(seq 1 1 9); 
do
cut -f1 Gene_Cluster_rep1_cluster${i}_final.ID > Gene_Cluster_rep1_cluster${i}_final.geneID
grep 'SG' Gene_Cluster_rep1_cluster${i}_final.geneID > SG_Cluster${i}_final_rep1.ID
grep 'TF' Gene_Cluster_rep1_cluster${i}_final.geneID > TF_Cluster${i}_final_rep1.ID
done
cat SG_* > SG_Cluster_final_rep1.ID
cat TF_* > TF_Cluster_final_rep1.ID
grep -wFf SG_Cluster_final_rep1.ID SG_Cluster_Rep1.t > SG_Cluster_final_rep1.t

