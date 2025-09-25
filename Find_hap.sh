#!/bin/bash


# Set argument to use a variable when active in script for example -l file.txt
# Display help message if -h, --help is provided

# Parse command line arguments using getopts
fullFASTA=""
labels=""
outputNamePrefix=""

print_help() {
    echo "Usage: $0 -f <fullFASTA> [-l <labels>] [-p <outputNamePrefix>]"
    echo "  -f, --file      : Path to the full aligned FASTA file."
    echo "  -l, --labels    : Path to the text file containing sequence labels to extract. (optional)"
    echo "  -p, --prefix    : Prefix for the output files."
    echo "  -h, --help      : Display this help message."
}

# Support long options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            fullFASTA="$2"
            shift 2
            ;;
        -l|--labels)
            labels="$2"
            shift 2
            ;;
        -p|--prefix)
            outputNamePrefix="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Check required arguments
if [[ -z "$fullFASTA" ]]; then
    echo "Error: -f|--file is required."
    print_help
    exit 1
fi
    

# Check if dependencies are installed
if ! command -v seqkit &> /dev/null
then
    echo "seqkit could not be found, please install it to proceed."
    exit 1
fi

# 1) Define variables for input files and output names.
# Get from command line arguments or set default values
# fullFASTA=$1
# labels=$2
# outputNamePrefix=$3


# fullFASTA="Cytb_full_aligned_06-18-2025.fasta"
# labels="mimic_clade_labels.txt"
# outputNamePrefix="mimic_clade_"

# Define dependencies directory
dependenciesDir="./dependencies"

# Check if files provided are unix formatted, if not convert them.
if file "${fullFASTA}" | grep -q "CRLF"; then
    echo "Converting ${fullFASTA} to Unix format..."
    dos2unix ${fullFASTA}
fi

if [ -f "${labels}" ]; then
    echo "Labels file provided: ${labels}"
else
    echo "No labels file provided, extracting all sequences from ${fullFASTA}"
    # Create a temporary labels file with all sequence names from the fasta
    labels="temp_labels.txt"
    seqkit fx2tab ${fullFASTA} | cut -f1 > ${labels}
fi

if file "${labels}" | grep -q "CRLF"; then
    echo "Converting ${labels} to Unix format..."
    dos2unix ${labels}
fi

#2) Runn script to extract desired clade from original fasta file.
seqkit faidx ${fullFASTA} --infile-list ${labels}  > ${outputNamePrefix}_${fullFASTA} && \
echo "Fasta file with selected labels created: ${outputNamePrefix}_${fullFASTA}"

# # 3) Check sequences have all the same length and are aligned.
echo "Trimming sequences to ensure they are aligned and of equal length..."
${dependenciesDir}/AMAS.py trim -i ${outputNamePrefix}_${fullFASTA} -f fasta -d dna && \
echo "Trimmed fasta file created: trimmed_${outputNamePrefix}${fullFASTA}-out.fas"

# # 4) Run Find_hap_fasta.py to find haplotypes in the clade fasta file.
# trimmedFasta="trimmed_${outputNamePrefix}${fullFASTA}-out.fas"
# popmap="${outputNamePrefix}popmap.txt"
# #Create a popmap file for the clade
# cat ${labels} | sed -E 's/(.+)/\1\tpop/' > ${popmap}

# Find_hap_fasta.py -f ${trimmedFasta} -r ${popmap} -a -s

# #Convert to nexus format
# inputHapFasta=$(echo ${trimmedFasta} | cut -d '.' -f 1)
# AMAS convert -i ${inputHapFasta}_allhap.fasta -f fasta -u nexus -d dna
