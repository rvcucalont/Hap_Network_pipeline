# Haplotype Network Pipeline
This pipeline [1](#1-run-script-find_hapsh-in-bash-terminal) assigns haplotype names to headers on a fasta file and converts it into a nexus file aligment. Then [2](#2-run-script-get_matrix_networkr-in-r-studio) creates a matrix based on user defined localities in coma delimited format. Both outputs can then be used in PopArt as input to generate an haplotype network. 

## Prerequisites
### Step 1
- Unix-like terminal
- Download [seqkit](https://bioinf.shenwei.me/seqkit/)
- python3
### Step 2
- R 4.5.0 and R Studio 2025.09.0
- R Packages
   - `dplyr`
   - `readxl` Needed to open excel file with metadata
   - `ape` needed to open fasta file
# Workflow Steps
# 1. Run script Find_hap.sh in bash terminal
1. **Download this repository on your local machine following either method**
   a) If already have git installed use: `git clone https://github.com/rvcucalont/Hap_Network_pipeline.git`
   b) Click bottom "<> Code" on the top right, download Zip, extract zip. 
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
Final output will be converted to nexus format.

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
Final output will be converted to nexus format.
## Flag details
```
Usage: ./Find_hap.sh -f <fullFASTA> [-l <labels>] [-p <outputNamePrefix>]
  -f, --file      : Path to the full aligned FASTA file.
  -l, --labels    : Path to the text file containing sequence labels to extract. (optional)
  -p, --prefix    : Prefix for the output files.
  -h, --help      : Display this help message.
```

## This is what `Find_hap.sh` do internally.
1. **Check file formats**
   - Ensure label file uses Unix line endings:
   - Uses `dos2unix ` command to convert to proper format if needed
   - Check if fasta files is present

2. **Extract Sequences from FASTA**
   - Extract sequences if label list is provided using seqkit (see further usages: https://bioinf.shenwei.me/seqkit/) 

3. **Check and Trim Alignment**
   - Ensure all sequences are aligned and of equal length:
   - Uses AMAS.py (see further usages: https://github.com/marekborowiec/AMAS)
   - AMAS.py stand-alone script located in `dependencies`. No need to download separately.

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

# 2. Run script `Get_Matrix_Network.R` in R Studio

1. **Open R Studio**
   - I recommend open R Studio by clicking on file `Hap_Network_pipeline.Rproj` to ensure workflow starts from working directory.
2. **From R Studio, open the script `Get_Network_Matrix.R`**
3. **Load libraries and custom functions (lines 1-12)**
4. **Provide input files (line 15)**
   - This will generate a file called `config.yaml` and open an external window to edit with required file paths (i.e, fasta, and excel file with metadata).
   - if the files are not in current directory. Make sure to modify the path using "/" as separators if working in Windows.
   - You can later modify these paths by opening the file `conig.yaml`
Here is an example of the input file path that needs to be edited:
```
file.name: 'file.fasta' #--> this file is in working directory
metadata.file: 'C:/user/path/to/metadata/metadata.xlsx' #--> this file is not in working directory

```
5. **Load input files provided (lines 18-20)**
6. **Run the rest of the script and modify with user-specific parameters**
- There are 3 places that can be modified are pointed with `#--------> i. description`
   1) Provide name of column in excel file with ID that will match to the fasta file header. The ID does not need match the entire header name but it needs to match a unique identifier within the label.
   2) Provide name of the column in excel file the population or trait assignemnt each sample belongs to.
   3) provide the order you would like the population or trait assignemnt appear in the legend. (Optional)
      - if not provided the default order will be kept
7. **Use nexus file from step 1 and .csv file in popArt**
   -There are two matrices output called `popmap_network_by-*.csv` and `Haplotype_matrix_by-*.csv`
   - `popmap_network_by-*.csv` to be used in PopArt
   - `Haplotype_matrix_by-*.csv` can be open in excel to visualize haplotype distribution as matrix by user


# References:
- Wei Shen*, Botond Sipos, and Liuyang Zhao. 2024. SeqKit2: A Swiss Army Knife for Sequence and Alignment Processing. iMeta e191. doi:10.1002/imt2.191.
- Borowiec, M.L. 2016. AMAS: a fast tool for alignment manipulation and computing of summary statistics. PeerJ 4:e1660.

For questions or issues, please contact the repository maintainer.
