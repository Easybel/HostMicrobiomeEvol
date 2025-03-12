import argparse
from argparse import RawTextHelpFormatter

# Author: Neda Barghi

parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,description="""description""")
parser.add_argument('--input', required=True, dest='Input', type=str, help="Input file in sync format from which polymorphic sites will be called.")
parser.add_argument('--output', required=True, dest='Output', type=str, help="Output file contains polymorphic sites in sync format. SNPs in chromosomes X, 2, 3 and 4 are called only.")

args = parser.parse_args()

#-------------------
# function
#-------------------

def get_sum_of_positions(cols_of_reps,position):
    return sum([int(rep.split(':')[position]) for rep in cols_of_reps])

#-------------------
# main
#-------------------

InputFile=open(args.Input,"r")
OutputFile=open(args.Output,"w")

chromosomes = ['NC_003279.8', 'NC_003280.10', 'NC_003281.10', 'NC_003282.8','NC_003283.11', 'NC_003284.9', 'NC_001328.1']
get_base = {0:'A', 1:'T', 2:'C', 3:'G', 5: '*'}
for line in InputFile:
    line=line.rstrip()
    cols=line.split('\t')
    if cols[0] in chromosomes:
    	sum_allele_freq_base = [get_sum_of_positions(cols[3:],i) for i in [0,1,2,3,5]]
    	if len([i for i in sum_allele_freq_base if i > 0]) >= 2:
            OutputFile.write(line+'\n')            
OutputFile.flush()
InputFile.close()
