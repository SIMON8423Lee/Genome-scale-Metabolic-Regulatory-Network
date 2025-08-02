#!/bin/bash
perl get_gokegg_anno.pl  -Anno pep.emapper.annotations -obo go2name.tsv -kegg ko2gene.tsv -go go2gene.tsv
Rscript kegg_enrich.r -l geneID.txt -n ko2name.tsv -g ko2gene.tsv -p 0.01 -q 0.01 -o kegg
Rscript go_enrich.r -l geneID.txt -n go2name.tsv -g go2gene.tsv -p 0.01 -q 0.01 -o go