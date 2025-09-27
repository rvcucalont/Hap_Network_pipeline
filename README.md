# Haplotype Network Pipeline
This pipeline (1) assigns haplotype names to the headers on fasta file and converts it into a nexus file alignemnt and (2) creates a matrix based on user defined localities in coma delimited format. Both outputs can then be used in PopArt as input to generate an haplotype network. 

## Prerequisites
- Unix-like terminal
- R and R Studio
- Download [seqkit](https://bioinf.shenwei.me/seqkit/)

# Workflow Steps
# 1. Run script Find_hap.sh in bash terminal
1. **Download this repository on your local machine**
   - git clone https://github.com/rvcucalont/Hap_Network_pipeline.git
   or
   - Click bottom "<> Code" on the top right, download Zip, extract zip. 
2. **Open bash terminal and provide fasta file name and prefix output name to Find_hap.sh script**
## Example files:
### file.fasta
```
>Sample1_1_organism_site1_other
ACTAAA
>Sample2_organism_site2_other
ACTAAA
>Sample3_organism_site3_other
AGTAAA
```
### list_labels.txt
```
Sample1_1_organism_site1_other
Sample3_organism_site3_other
```
## Example Usage:
### If want to work with all samples from fasta file
```
./Find_hap.sh -f file.fasta -p Dataset1
```
### Output:
```
>Sample1_1_organism_site1_other_hap1
ACTAAA
>Sample2_organism_site2_other_hap1
ACTAAA
>Sample3_organism_site3_other_hap2
AGTAAA
```
Final output in nexus format.

### If only want a subset, provide a list of sample name headers to extract 
```
./Find_hap.sh -f file.fasta -p Dataset1 -l list_labels.txt
```
### Output:
```
>Sample1_1_organism_site1_other_hap1
ACTAAA
>Sample3_organism_site3_other_hap2
AGTAAA
```
Final output in nexus format.
## Flag details
```
Usage: ./Find_hap.sh -f <fullFASTA> [-l <labels>] [-p <outputNamePrefix>]
  -f, --file      : Path to the full aligned FASTA file.
  -l, --labels    : Path to the text file containing sequence labels to extract. (optional)
  -p, --prefix    : Prefix for the output files.
  -h, --help      : Display this help message.
```

# This is what Find_hap.sh do.
1. **Check file formats**
   - Ensure label file uses Unix line endings:
   - Uses `dos2unix ` command to convert to poper format if needed
   - Check if fasta files is present

2. **Extract Sequences from FASTA**
   - Extract sequences if label list is provided using seqkit (see further usages: https://bioinf.shenwei.me/seqkit/) 

3. **Check and Trim Alignment**
   - Ensure all sequences are aligned and of equal length:
   - Uses AMAS.py (see further usages: https://github.com/marekborowiec/AMAS)
   - AMAS.py stand-alone script located in `dependencies`. No need to download separatly.

4. **Find Haplotypes**
   - Run custom python script `Find_hap_fasta.py` to assign haplotypes based on similarity

5. **Convert to Nexus Format**
   - Convert the output FASTA to Nexus format for downstream analysis:
   - AMAS.py convert

## Notes
- Adjust file names and paths as needed for your dataset.
- For better worklow copy input files into working directory along with this repositories
- Make sure all required tools are installed and available in your PATH.

---

# 2. Run script Get_Matrix_Network.R in R Studio



# References:
- Wei Shen*, Botond Sipos, and Liuyang Zhao. 2024. SeqKit2: A Swiss Army Knife for Sequence and Alignment Processing. iMeta e191. doi:10.1002/imt2.191.
- Borowiec, M.L. 2016. AMAS: a fast tool for alignment manipulation and computing of summary statistics. PeerJ 4:e1660.

For questions or issues, please contact the repository maintainer.
