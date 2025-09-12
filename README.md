# Haplotype Network Pipeline

This pipeline extracts a specific clade from a full FASTA alignment, processes it, and generates haplotype and network files for downstream analysis. The steps below are based on the workflow in `Fin_hap.sh`.

## Prerequisites
- R (for clade selection)
- [seqkit](https://bioinf.shenwei.me/seqkit/)
- [AMAS](https://github.com/marekborowiec/AMAS)
- [Find_hap_fasta.py](https://github.com/yourrepo/Find_hap_fasta.py) (or your local script)
- `dos2unix` (if needed)

# Workflow Steps
## Run manually (step 1)
1. **Select Desired Clade manually in R**
   - Use the `Get_clade.R` script on your full tree to identify the clade of interest.
   - Export the list of sequence labels to a file (e.g., `clade_labels.txt`).

## Run automatically using `Fin_hap.R` script (step 2-5)
### Provide user-specific paths to config.R file
- fullFASTA="fullfile.fasta"
- labels="clade_labels.txt"
- outputNamePrefix="prefix_"

2. **Extract Clade Sequences from FASTA**
   - Ensure label file uses Unix line endings:
   - Extract sequences:

3. **Check and Trim Alignment**
   - Ensure all sequences are aligned and of equal length:

4. **Find Haplotypes**
   - Create a popmap file:
   - Run haplotype finder `Find_hap_fasta.py`: (see repo for usage)

5. **Convert to Nexus Format**
   - Convert the output FASTA to Nexus format for downstream analysis:

## Notes
- Adjust file names and paths as needed for your dataset.
- Make sure all required tools are installed and available in your PATH.
- For user-specific configuration, see `config_example.R`.

---

For questions or issues, please contact the repository maintainer.
