# author: Harald Brolin
# date: 2018-10-15
# contact: harald.brolin@wlab.gu.se
#
# Description:
# This script is used to export the qiime2 artifacts like the feature_table.qza
# and the phylogenetic tree

# version: Qiime2 v.2018.8

configfile: "verdi_config.yaml"



rule all:
    input:
      "../../../data/processed/reference_sequences/ref_seq.csv"

rule create_reference_sequences_csv:
    input:
        "../../tools/qiime_rep_seqs_to_R/fasta_to_scv.py"
    output:
        "../../../data/processed/reference_sequences/ref_seq.csv"
    run:
        shell("python {input} > {output}")
