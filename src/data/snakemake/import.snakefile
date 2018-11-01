# author: Harald Brolin
# date: 2018-10-15
# contact: harald.brolin@wlab.gu.se
#
# Description:
# This scripts is intended to import 16S demultiplexed paired-end read
# using the Phred33 quality score. Later the input will be denoised with DADA2
# and summary visualizations created. Last a phylogenetic tree is created, using
# fasttree and MAFFT.

# version: Qiime2 v.2018.8


configfile: "verdi_config.yaml"

rule all:
    input:
        "../../../data/visualizations/import/quality_profiles.qzv"


# This rule imports the paired-end samples based on a manifest file, see input.
# Since we are impporting paired end each sample needs to have two sampels
# R1 and R2, forward and reverseself. A manifest file is also required specifying
# the sample name, path to sample and direction (forward or reverse), see below:
#
# sample-id,absolute-filepath,direction
# sample-1,$PWD/some/filepath/sample1_R1.fastq,forward
# sample-1,$PWD/some/filepath/sample1_R2.fastq,reverse

#####
#####If statement to check if the reads are Paired end or single end?
#####

rule paired_end_import:
    input:
        "../../../data/metadata/manifest_file"
    output:
        "../../../data/interim/artifacts/paired_end_demux.qza"
    run:
        shell(
            "qiime tools import"
            " --type 'SampleData[PairedEndSequencesWithQuality]'"
            " --input-path {input}"
            " --output-path {output}"
            " --input-format PairedEndFastqManifestPhred33")

# After importing the reads we are interested in seeing the quality profeiles of
# the samples, the script bellow generates a summary of the imported demultiplexed
# reads. This allows you to determine how many sequences were obtained per sample,
# and also to get a summary of the distribution of sequence qualities at each
# position in your sequence data.

rule quality_profiles:
    input:
        rules.paired_end_import.output
        # "../../data/interim/artifacts/paired_end_demux.qza"
    output:
        "../../../data/visualizations/import/quality_profiles.qzv"
    run:
        shell(
            "qiime demux summarize"
            " --i-data {input}"
            " --o-visualization {output}")
