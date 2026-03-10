

##jupyter notebook that will be converted to the bash script for the download
##and processing of 

##Locations of Scripts and input files
SCRIPT_LOCATION="./scripts/2_pcr_analyze_coverage_protospacer.sh"
PCR_METADATA="./files/metadata.txt"
SAMPLE_NAME=`cat ${PCR_METADATA} | awk '{ print $1 }' FS='\t' `
SEQUENCE=`cat ${PCR_METADATA} | awk '{ print $5 }' FS='\t'`
REFERENCE=`cat ${PCR_METADATA} | awk '{ print $6 }' FS='\t'`

arr_SAMPLE_NAME=(`echo ${SAMPLE_NAME}`)
arr_SEQUENCE=(`echo ${SEQUENCE}`)
arr_REF=(`echo ${REFERENCE}`)

count=${#arr_SAMPLE_NAME[@]}
for ((i=1; i<$count; i+=1));
    do
    SAM_NAME=${arr_SAMPLE_NAME[i]}
    SEQ=${arr_SEQUENCE[i]}
    REF=${arr_REF[i]}

    
    echo $SAM_NAME $SEQ $REF
    # qsub ${SCRIPT_LOCATION} ${SAM_NAME} ${SEQ} ${REF}
    ${SCRIPT_LOCATION} ${SAM_NAME} ${SEQ} ${REF}


    done 


SCRIPT_LOCATION="./scripts/2_pcr_analyze_coverage_protospacer.sh"
##NB for primer seq always use 5--> 3 prime
#sample name adapter_seq reference fwd_primer rev_primer location
qsub ${SCRIPT_LOCATION} Plasmid-mU6-704_S1 GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG pCRISPRi_dual_protospacer_BD_164 CAGCACAAAAGGAAACTCACC GCGGCCAAGTTGTAAACGG 79-99
qsub ${SCRIPT_LOCATION} Plasmid-LKO-705_S2 GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG pCRISPRi_dual_protospacer_AC_171 GACTATCATATGCTTACCGT GGCCAAGTTGATAACGGA 84-103
qsub ${SCRIPT_LOCATION} gDNA-LKO-705_S3 GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG pCRISPRi_dual_protospacer_AC_171 GACTATCATATGCTTACCGT GGCCAAGTTGATAACGGA 84-103
qsub ${SCRIPT_LOCATION} gDNA-mU6-704_S4 GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG pCRISPRi_dual_protospacer_BD_164 CAGCACAAAAGGAAACTCACC GCGGCCAAGTTGTAAACGG 79-99
