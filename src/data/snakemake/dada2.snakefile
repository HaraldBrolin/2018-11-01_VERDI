# author: Harald Brolin
# date: 2018-10-15
# contact: harald.brolin@wlab.gu.se
#
# Description:
# This scripts is intended to generate alpha and beta diversity report of the
# 16S data.

# version: Qiime2 v.2018.8


configfile: "verdi_config.yaml"

rule all:
    input:
        "../../../data/visualizations/feature_summarize/feature_sequences.qzv",
        "../../../data/visualizations/feature_summarize/feature_table_summarize.qzv",
        "../../../data/visualizations/dada2/denoising_stats.qzv"


# !!!!! Important !!!!!
# Befor filtering look at the output of the quality_profiles (quality_profiles.qzv)
# to evaluate the correct forward and reverse trunc lengths.

# DADA2 is a pipeline for detecting and correcting (where possible) Illumina
# amplicon sequence data. This quality control process will additionally filter
# any eads that are identified in the sequencing data, and will filter chimeric sequences.

# params: more information about the paramters can be found in the configfile

rule dada2_denoise_paired:
    input:
        "../../../data/interim/artifacts/paired_end_demux.qza"
    output:
        table = "../../../data/interim/artifacts/dada2/table.qza",
        representative_seqs = "../../../data/interim/artifacts/dada2/representative_sequences.qza",
        denoising_stats = "../../../data/interim/artifacts/dada2/denoising_stats.qza"
    params:
        truncf = config['trunc-len-f'],
        truncr = config['trunc-len-r']
    threads:
        threads = config['threads']
    message:
        "If this step yeilds an error, make sure that there is an overlap of 20 bp or more between forward and reverse"

    run:
        shell(
            "qiime dada2 denoise-paired"
            " --i-demultiplexed-seqs {input}"
            " --p-trunc-len-f {params.truncf}"
            " --p-trunc-len-r {params.truncr}"
            " --p-n-threads {threads}"
            " --o-table {output.table}"
            " --o-representative-sequences {output.representative_seqs}"
            " --o-denoising-stats {output.denoising_stats}")


#  Generate a tabular view of Metadata. The output visualization supports
#  interactive filtering, sorting, and exporting to common file formats.

rule dada2_metadata_tabulate:
    input:
        rules.dada2_denoise_paired.output.denoising_stats
    output:
        "../../../data/visualizations/dada2/denoising_stats.qzv"
    run:
        shell(
            "qiime metadata tabulate"
            " --m-input-file {input}"
            " --o-visualization {output}")


# The following commands will create visual summaries of the data. The feature_table_summarize
# command will give you information on how many sequences are associated with
# each sample and with each feature, histograms of those distributions, and
# some related summary statistics. The feature_sequences will provide a mapping
# of feature IDs to sequences, and provide links to easily BLAST each sequence
# against the NCBI nt database.

rule feature_table_summarize:
    input:
        feature_table = rules.dada2_denoise_paired.output.table,
        metadata = config["metadata"]
    output:
        "../../../data/visualizations/feature_summarize/feature_table_summarize.qzv"
    run:
        shell(
            "qiime feature-table summarize"
            " --i-table {input.feature_table}"
            " --o-visualization {output}"
            " --m-sample-metadata-file {input.metadata}")

rule feature_sequences:
    input:
        representative_seqs = rules.dada2_denoise_paired.output.representative_seqs
    output:
        "../../../data/visualizations/feature_summarize/feature_sequences.qzv"
    run:
        shell(
            "qiime feature-table tabulate-seqs"
            " --i-data {input.representative_seqs}"
            " --o-visualization {output}")
