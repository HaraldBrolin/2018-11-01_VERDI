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
        "../../../data/interim/artifacts/phylo_tree/rooted_tree.qza",
        directory("../../../data/visualizations/alpha_rarefaction"),
        directory("../../../data/interim/artifacts/core_metrics_phylogeny")


#  The code below is a wrapper for creating a phylogenetic tree. This pipeline
#  will start by creating a sequence alignment using MAFFT, after which any alignment
#  columns that are phylogenetically uninformative or ambiguously aligned will be
#  removed (masked). The resulting masked alignment will be used to infer a
#  phylogenetic tree and then subsequently  rooted at its midpoint. Output files
#  from each step of the pipeline will  be saved. This includes both the unmasked
#  and masked MAFFT alignment from q2-alignment methods, and both the rooted and
#  unrooted phylogenies from q2-phylogeny methods.

rule generate_tree:
    input:
        representative_seqs = "../../../data/interim/artifacts/dada2/representative_sequences.qza"
    output:
        alignment = "../../../data/interim/artifacts/phylo_tree/alignment.qza",
        masked_alignment = "../../../data/interim/artifacts/phylo_tree/masked_alignment.qza",
        tree = "../../../data/interim/artifacts/phylo_tree/tree.qza",
        rooted_tree = "../../../data/interim/artifacts/phylo_tree/rooted_tree.qza"
    threads:
        threads = config['threads']
    run:
        shell(
            "qiime phylogeny align-to-tree-mafft-fasttree"
            "  --i-sequences {input.representative_seqs}"
            "  --p-n-threads {threads}"
            " --o-alignment {output.alignment}"
            " --o-masked-alignment {output.masked_alignment}"
            " --o-tree {output.tree}"
            " --o-rooted-tree {output.rooted_tree}")


rule core_metrics_phylogeny:
    input:
        rooted_tree = rules.generate_tree.output.rooted_tree,
        table = "../../../data/interim/artifacts/dada2/table.qza",
        metadata = config["metadata"]
    output:
        directory("../../../data/interim/artifacts/core_metrics_phylogeny")
        # faith_pd = "../../../data/interim/artifacts/core_metrics_phylogeny/faith_pd.qza",
        # observed = "../../../data/interim/artifacts/core_metrics_phylogeny/observed.qza",
        # shannon = "../../../data/interim/artifacts/core_metrics_phylogeny/shannon.qza",
        # pielou_eveness = "../../../data/interim/artifacts/core_metrics_phylogeny/pielou_eveness.qza",
        # unweighted_unifrac = "../../../data/interim/artifacts/core_metrics_phylogeny/unweighted_unifrac.qza",
        # weighted_unifrac = "../../../data/interim/artifacts/core_metrics_phylogeny/weighted_unifrac.qza",
        # jaccard = "../../../data/interim/artifacts/core_metrics_phylogeny/jaccard.qza",
        # bray_curtis = "../../../data/interim/artifacts/core_metrics_phylogeny/bray_curtis.qza",
    params:
        sampling_depth = config['sampling_depth']
    threads:
        threads = config['threads']
    run:
        shell(
            "qiime diversity core-metrics-phylogenetic"
            " --i-phylogeny {input.rooted_tree}"
            " --i-table {input.table}"
            " --p-sampling-depth {params.sampling_depth}"
            " --m-metadata-file {input.metadata}"
            # " --o-faith-pd-vector {input.faith_pd}"                    # Alpha-diversity
            # " --o-observed-otus-vector {input.observed}"
            # " --o-shannon-vector {input.shannon}"
            # " --o-evenness-vector {input.pielou_eveness}"   # Pielou
            # " --o-unweighted-unifrac-distance-matrix {input.unweighted_unifrac}" # Beta-diversity
            # " --o-weighted-unifrac-distance-matrix {input.weighted_unifrac}"
            # " --o-jaccard-distance-matrix {input.jaccard}"
            # " --o-bray-curtis-distance-matrix {input.bray_curtis}")
            " --output-dir {output}")


rule alpha_rarefaction:
    input:
        rooted_tree = "../../../data/interim/artifacts/phylo_tree/rooted_tree.qza",
        table = "../../../data/interim/artifacts/dada2/table.qza",
        metadata = config["metadata"]
    output:
        directory("../../../data/visualizations/alpha_rarefaction")
    params:
        max_depth = config['max_depth'],
        min_depth = config['min_depth'],
        steps = config['steps']
    run:
        shell(
            "qiime diversity alpha-rarefaction"
            " --i-phylogeny {input.rooted_tree}"
            " --i-table {input.table}"
            " --p-max-depth {params.max_depth}"
            " --p-min-depth {params.min_depth}"
            " --p-steps {params.steps}"
            " --m-metadata-file {input.metadata}"
            " --output-dir {output}")
