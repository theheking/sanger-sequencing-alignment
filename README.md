# Sanger Sequencing Alignment Pipeline
## Overview
This pipeline processes raw Sanger sequencing trace files to validate custom pCRISPRi dual-guide RNA libraries. The workflow reads the base-calling probabilities at each position to build an accurate consensus sequence. Once the consensus is generated, it is aligned against custom-built reference databases.

Output: The pipeline generates a detailed table of BLAST results summarizing the alignments for each critical vector component, including:

- Protospacer sequences

- hU6 promoter

- mU6 promoter

- cs1 (capture sequence 1)


Used to confirm library for a Direct Capture Perturb-seq experiment: 

- Replogle, J.M., Norman, T.M., Xu, A. et al. Combinatorial single-cell CRISPR screens by direct guide RNA capture and targeted sequencing. Nat Biotechnol 38, 954–961 (2020). https://doi.org/10.1038/s41587-020-0470-y



