#!/bin/bash

# 1) Get desired clade. This can be done in R using the the get_descent function from the full tree.


#2) Runn script to extract desired clade from original fasta file.

fullFASTA="Cytb_full_aligned_06-18-2025.fasta"
labels="mimic_clade_labels.txt"
outputNamePrefix="mimic_clade_"

#Convert dos2unix if needed
dos2unix ${labels}

seqkit faidx ${fullFASTA} --infile-list ${labels}  > ${outputNamePrefix}${fullFASTA}

# # 3) Check sequences have all the same length and are aligned.

AMAS trim -i ${outputNamePrefix}${fullFASTA} -f fasta -d dna

# 4) Run Find_hap_fasta.py to find haplotypes in the clade fasta file.
trimmedFasta="trimmed_${outputNamePrefix}${fullFASTA}-out.fas"
popmap="${outputNamePrefix}popmap.txt"
#Create a popmap file for the clade
cat ${labels} | sed -E 's/(.+)/\1\tpop/' > ${popmap}

Find_hap_fasta.py -f ${trimmedFasta} -r ${popmap} -a -s

#Convert to nexus format
inputHapFasta=$(echo ${trimmedFasta} | cut -d '.' -f 1)
AMAS convert -i ${inputHapFasta}_allhap.fasta -f fasta -u nexus -d dna
