#!/bin/bash
#PBS -q normal
#PBS -P oo78
#PBS -l storage=gdata/oo78+scratch/oo78+gdata/ha26
#PBS -l ncpus=8
#PBS -l mem=100GB
#PBS -l jobfs=30GB
#PBS -l walltime=24:00:00
#PBS -m be
#PBS -j oe



module load fastqc
module load fastp
module load bwa
module load samtools
###---------------
#Set Variables 
###----------------
#Input
SAMPLE_NAME=${1?Error: no sample name given}
ADAPTER_SEQ=${2?Error: no sequence given}
REFERENCE=${3?Error: no reference given}
PCR_FWD=${4?Error: pcr seq not given}
PCR_REV=${5?Error: pcr seq not given}
PROT_SPACER_COORDS_A=${6?Error: coordinates given startcoord-endcoord}


##Create reverse compliment
logit()
{
    echo "[`date`] - ${*}" >> ${LOG_FILE}
}

rev_comp()
{
    echo ${*} | rev | tr ATCG TAGC 
}




# #!! The flowthrough !!!###
# Two plasmids pJR85 and pCRISRi
# #an estimation of 100 sequencing reads per sgRNA 

# ~ 40 ng of pCRISPRi_dual-guide gRNA library DNA (1:1 or 3:1) per sample as starting material. 
# The following Illumina indexes were used:
# pJR85_dual-guide gRNA Illumina index #5  amplicon ~220 bp
# TruSeq Adapter, Index 5
# 5’ GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG
# Amplicon 1 photospacer A/C - pCRISPRi_dual-guide gRNALib 1:1 171 bp - Illumina index # 6 
# TruSeq Adapter, Index 6
# 5’ GATCGGAAGAGCACACGTCTGAACTCCAGTCACGCCAATATCTCGTATGCCGTCTTCTGCTTG
# Amplicon 2 photospacer B/D - pCRISPRi_dual-guide gRNALib 1:1 164 bp - Illumina index # 7 
# TruSeq Adapter, Index 7
# 5’ GATCGGAAGAGCACACGTCTGAACTCCAGTCACCAGATCATCTCGTATGCCGTCTTCTGCTTG
# Amplicon 3 photospacer A/C - pCRISPRi_dual-guide gRNALib 3:1 171 bp - Illumina index # 12 
# TruSeq Adapter, Index 12
# 5’ GATCGGAAGAGCACACGTCTGAACTCCAGTCACCTTGTAATCTCGTATGCCGTCTTCTGCTTG
# Amplicon 4 photospacer B/D - pCRISPRi_dual-guide gRNALib 3:1 164 bp - Illumina index # 13
# TruSeq Adapter, Index 13
# 5’ GATCGGAAGAGCACACGTCTGAACTCCAGTCACAGTCAACAATCTCGTATGCCGTCTTCTGCTTG
# #Use bwa locat

# #Uncomment to trial out pipeline
# FASTQ_R1="PCR_220b_S33_L002_R1_001.fastq.gz"
# FASTQ_R2="PCR_220b_S33_L002_R2_001.fastq.gz"
# OUTPUT_FASTQ_R1=${FASTQ_OUT_LOC}"PCR_220b_S33_L002_R1_001.trimmed.fastq.gz"
# ADAPTER_SEQ="GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG"
# OUTPUT_FASTQ_R2=${FASTQ_OUT_LOC}"PCR_220b_S33_L002_R2_001.trimmed.fastq.gz"
# SAMPLE_NAME="gDNA-LKO-705_S3"
# # SAMPLE_NAME="Plasmid-LKO-705_S1"
# ADAPTER_SEQ="GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG"
# PCR_PRIMER_F="GACTATCATATGCTTACCGT"
# PCR_PRIMER_R="GGCCAAGTTGATAACGGA"
# REFERENCE="pCRISPRi_dual_protospacer_AC_171"
# SAMPLE_NAME="gDNA-LKO-705_S3"
# ADAPTER_SEQ="GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG"
# REFERENCE="pCRISPRi_dual_protospacer_AC_171"
# PCR_FWD="GACTATCATATGCTTACCGT"
# PCR_REV="GGCCAAGTTGATAACGGA"
# PROT_SPACER_COORDS_A="84-103"
# PCR_FWD_COMP=`rev_comp ${PCR_FWD}`
# PCR_REV_COMP=`rev_comp ${PCR_REV}`


 	  
##All files are fastq
OUTPUT_DIR="/scratch/oo78/hk1145/sanger-sequencing-alignment/"
FASTQ_LOC="${OUTPUT_DIR}FASTQ_OG/"
FASTQ_OUT_LOC=${OUTPUT_DIR}"FASTQ_OUT/"
COVERAGE_LOC=${OUTPUT_DIR}"COVERAGE/"
mkdir -p ${FASTQ_OUT_LOC}
mkdir -p ${COVERAGE_LOC}

LOG_FILE="${OUTPUT_DIR}tst.log"

#Build index creates index 6 files with the bt2 file extension
REFERENCE_LOC="${OUTPUT_DIR}/files/${REFERENCE}"



##Testing
##First input select for only index files
FASTQ_R1=${SAMPLE_NAME}"_L001_R1_001.fastq.gz"
FASTQ_R2=${SAMPLE_NAME}"_L001_R2_001.fastq.gz"
INPUT_FASTQ_R1_LOC="${FASTQ_LOC}${FASTQ_R1}"
INPUT_FASTQ_R2_LOC="${FASTQ_LOC}${FASTQ_R2}"

TMP_FASTQ_R1="${FASTQ_LOC}tmp_R1_001.fastq.gz"
TMP_FASTQ_R2="${FASTQ_LOC}tmp_R2_001.fastq.gz"


OUTPUT_FASTQ_R1="${FASTQ_OUT_LOC}${FASTQ_R1}"
OUTPUT_FASTQ_R2="${FASTQ_OUT_LOC}${FASTQ_R2}"



##Create SAM BAM FILE NAMES
# BASENAME=`basename "${OUTPUT_FASTQ_R1%%.*}"`
SAM_FILE="${BAM_OUT_LOC}${SAMPLE_NAME}.sam"




mkdir -p "${OUTPUT_DIR}FASTQC/"

##Remove adaptor sequences
fastp -i ${INPUT_FASTQ_R1_LOC} -I ${INPUT_FASTQ_R2_LOC} \
      -o ${OUTPUT_FASTQ_R1} -O ${OUTPUT_FASTQ_R2} \
      -a ${ADAPTER_SEQ} \
      --adapter_sequence_r2=${ADAPTER_SEQ} \
      -q 20 \
      -c \
      -g \
      -x \
      -j ${FASTQ_OUT_LOC}${SAMPLE_NAME}_fastp.json \
      -h ${FASTQ_OUT_LOC}${SAMPLE_NAME}_fastp.html

##FASTQC
fastqc ${OUTPUT_FASTQ_R1} ${OUTPUT_FASTQ_R2} --outdir "${OUTPUT_DIR}FASTQC/"
logit "fastqc donezo"
##!!! Reference !!!!###

#concenate all into 
#use the reference pool_oligo_library for jfdjfkos
#use the reference pool_oligo_library_crispri for 

for ref_in_ref in ${REFERENCE_LOC}/*.fa
do
    echo $ref_in_ref
    bwa index -a bwtsw ${ref_in_ref}
    name="${ref_in_ref%.*}.sorted.bam"
    prot_a_name="${ref_in_ref%.*}.prota.sorted.bam"

    bwa mem ${ref_in_ref} ${OUTPUT_FASTQ_R1} ${OUTPUT_FASTQ_R2} > ${COVERAGE_LOC}/$SAMPLE_NAME.proto.tst.sam
    samtools view -b -S ${COVERAGE_LOC}/$SAMPLE_NAME.proto.tst.sam > ${COVERAGE_LOC}/$SAMPLE_NAME.proto.tst.bam 
    samtools sort ${COVERAGE_LOC}/$SAMPLE_NAME.proto.tst.bam  > ${name}
    samtools index ${name}
    
    
    TEST_HEAD=`head -n 1 ${ref_in_ref}`
    TEST_HEAD=${TEST_HEAD:1}
    samtools view -e '[NM]==1 || [NM]==0 | [NM]==2' -O BAM -o ${prot_a_name} ${name} ${TEST_HEAD}:${PROT_SPACER_COORDS_A}

    coverage="${COVERAGE_LOC}${SAMPLE_NAME}-${TEST_HEAD}.coverage"
    prot_a_name_coverage="${COVERAGE_LOC}${SAMPLE_NAME}-${TEST_HEAD}.protospacerA.coverage"

    echo $TEST_HEAD ${coverage}
    samtools depth -o ${coverage} ${name}
    samtools depth -o ${prot_a_name_coverage} ${prot_a_name}

done


