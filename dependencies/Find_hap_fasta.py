#!/usr/bin/env python3

import argparse
import sys

p = argparse.ArgumentParser()

# Arguments to accept files from the command line. -f [fasta file] -r [list of names to extract] -u [optional]
# Use example: ./rename_fasta.py -f <file.fasta> -r <query.txt> 

#Notes:
    #How to handle sequences with different sizes
    #How to handle "N","?","-" (At the edges or in the middle of the seq)
    #Make functions
    #Eliminate unnecesary code
    #add a feature in case not all the names from the popmap file are in the fasta
    

p.add_argument('-f', type=str, required=True, help="Input file in fasta format")
p.add_argument('-r', type=str, required=True, help="tab delimited file with a unique word to look in fasta header (column 1) and the new header name (column 2). e.g., OldNameID[tab]NewHeader_name")
p.add_argument("-s", "--stout", help = "if activated a tab delimited with Haplotype dessignation and fasta header will be created", action = "store_true")
p.add_argument("-d", "--duplicate", help = "if activated file with fasta file collapsed by pop and hap will be created", action = "store_true")
p.add_argument("-a", "--all", help = "if activated file with fasta file collapsed by sample and hap will be created", action = "store_true")


args = p.parse_args()
Fasta_file = args.f
list_pop = args.r
Haplotype_header = Fasta_file.split(".")[0]+'_haplotype.tsv'
Fasta_PopHap = Fasta_file.split(".")[0]+'_pophap.fasta'
Fasta_all = Fasta_file.split(".")[0]+'_allhap.fasta'
# separator=args.separator
# fasta_output = Fasta_file.split(".")[0]+'_renamed.fasta'
      
#File handlers 
fh = open(list_pop, 'r')
fh2 = open(Fasta_file, 'r')
if args.stout:
    fhw = open(Haplotype_header, 'w')
if args.duplicate:
    fhwd = open(Fasta_PopHap, 'w')
if args.all:
    fhwa = open(Fasta_all, 'w')

#parse population map

pop={}
for popmap in fh:
    popmap=popmap.strip("\n")
    popmap=popmap.split("\t")    
    pop[popmap[0]]=popmap[1]

#Parse fasta file

# records_remaned=0

header_temp=[]
# header=[]
seq_temp=[]
seq=[]
count=0
Hap={}
Hap_pop={}
Hap_count={}
Hap_counter=0
total_seq=0

for line in fh2:
    line = line.strip("\n")
    if ">" in line:
        total_seq+=1
        line=line.strip(">")
        if len(header_temp) == 0:
            header_temp=line
            # header.append(line)
        else:
            seq.append(''.join(seq_temp))
            seq_temp=[]
            # header.append(line)
            if seq[count] in Hap:
                samecount=Hap_count[seq[count]]
                Hap[seq[count]].append(header_temp)  
                Hap_count[seq[count]]=samecount
                if args.stout:
                    Haplo=str(samecount)
                    print("Hap"+Haplo+"\t"+header_temp)
                    fhw.write("Hap"+Haplo+"\t"+header_temp+"\n")
            else:
                Hap_counter+=1
                Hap[seq[count]]=[]
                Hap[seq[count]].append(header_temp)
                Hap_count[seq[count]]=[]
                Hap_count[seq[count]]=Hap_counter
                if args.stout:
                    Haplo=str(Hap_counter)
                    print("Hap"+Haplo+"\t"+header_temp)
                    fhw.write("Hap"+Haplo+"\t"+header_temp+"\n")
            if pop[header_temp] not in Hap_pop:
                Hap_pop[pop[header_temp]]={}
                if seq[count] not in Hap_pop[pop[header_temp]]:
                    Hap_pop[pop[header_temp]][seq[count]]=[]
                    Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
                    header_temp=line
                else:
                    Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
                    header_temp=line
            elif pop[header_temp] in Hap_pop:
                if seq[count] not in Hap_pop[pop[header_temp]]:
                    Hap_pop[pop[header_temp]][seq[count]]=[]
                    Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
                    header_temp=line
                else:
                    Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
                    header_temp=line
                header_temp=line 
            count+=1
    else:
        seq_temp.append(line)

seq.append(''.join(seq_temp))
# Hap[seq[count]].append(header_temp)
if seq[count] in Hap:
    samecount=Hap_count[seq[count]]
    Hap[seq[count]].append(header_temp)
    Hap_count[seq[count]]=samecount
    if args.stout:
        Haplo=str(samecount)
        print("Hap"+Haplo+"\t"+header_temp)
        fhw.write("Hap"+Haplo+"\t"+header_temp+"\n")
else:
    Hap_counter+=1
    Hap[seq[count]]=[]
    Hap[seq[count]].append(header_temp)
    Hap_count[seq[count]]=[]
    Hap_count[seq[count]]=Hap_counter  
    if args.stout:
        Haplo=str(Hap_counter)
        print("Hap"+Haplo+"\t"+header_temp)
        fhw.write("Hap"+Haplo+"\t"+header_temp+"\n")
if pop[header_temp] not in Hap_pop:
    Hap_pop[pop[header_temp]]={}
    if seq[count] not in Hap_pop[pop[header_temp]]:
        Hap_pop[pop[header_temp]][seq[count]]=[]
        Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
    else:
        Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
elif pop[header_temp] in Hap_pop:
    if seq[count] not in Hap_pop[pop[header_temp]]:
        Hap_pop[pop[header_temp]][seq[count]]=[]
        Hap_pop[pop[header_temp]][seq[count]].append(header_temp)
    else:
        Hap_pop[pop[header_temp]][seq[count]].append(header_temp)


contador=0
for i in Hap_pop:
    for k in Hap_pop[i]:
        if k in Hap_count:
            contador+=1
            NumSpec = str(len(Hap_pop[i][k]))
            Haplotype=str(Hap_count[k])
            # print(">"+i+"_Hap"+Haplotype+"_("+NumSpec+")")
            # print(k)
            if args.duplicate:
                fhwd.write(">"+i+"_Hap"+Haplotype+"_("+NumSpec+")"+"\n")
                fhwd.write(k+"\n")
        for y in Hap_pop[i][k]:
            Haplotype=str(Hap_count[k])
            if args.all:
                fhwa.write(">"+y+"_"+"Hap"+Haplotype+"\n")
                fhwa.write(k+"\n")
            # for g in range(len(Hap_pop[i][k])):
                # # print(i)
                # if k in Hap_count:
                    # Haplotype=str(Hap_count[k])
                    # # print(">"+y+"_"+"Hap"+Haplotype)
                    # # print(k)
                    # if args.all:
                        # fhwa.write(">"+y+"_"+"Hap"+Haplotype+"\n")
                        # fhwa.write(k+"\n")
            
            
fh2.close()  
fh.close()
if args.stout:  
    fhw.close()
if args.duplicate:
    fhwd.close()
if args.all:
    fhwa.close()



print("Total records:",total_seq)        
print("Total haplotypes:",Hap_counter)
print("\n")
if args.stout:
    print("Table with haplotypes was created with name:",Haplotype_header)
else:
    print("No table was created, select -s or --stout")
if args.duplicate:
    print("Fasta file with sequences collapsed by pop and hap was created with name:",Fasta_PopHap)
    print("Total sequences after filtering for duplicates:",contador)
else:
    print("Fasta file with sequences collapsed was not created, select option -d or --duplicate")
if args.all:
    print("Fasta file with all sequences with haplotype designation was created with name:",Fasta_all)
else:
    print("Fasta file with all sequences with haplotype was not created, select option -a or --all" )
# print("Records renamed:",records_remaned)
# print("Records not renamed:",Total_seq-records_remaned)

