rule get_circle_stats:
    input:
        fasta="results/circles/{circle}/{circle}.fa",
    output:
        tsv="results/circles/{circle}/{circle}.stats.tsv",
    log:
        "logs/circles/{circle}/{circle}.stats.log",
    params:
        command="stats",
        extra="--tabular",
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"


rule sliding_window_around_circle_references:
    input:
        fasta="results/circles/{circle}/{circle}.fa",
    output:
        fasta="results/circles/{circle}/{circle}.circular_sliding_windows.fa",
    log:
        "logs/circles/{circle}/{circle}.circular_sliding_windows.log",
    params:
        command="sliding",
        extra="--circular-genome -W 3996 -s 999",
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"


rule simulate_illumina_reads:
    input:
        fasta="results/circles/{circle}/{circle}.circular_sliding_windows.fa",
        tsv="results/circles/{circle}/{circle}.stats.tsv",
    output:
        fq1="results/circles/{circle}/illumina/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.1.fq",
        fq2="results/circles/{circle}/illumina/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.2.fq",
    log:
        "logs/circles/{circle}/illumina/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.log",
    conda:
        "../envs/mason.yaml"
    params:
        fragment_number=lambda wc, input: determine_fragment_number(wc, input),
        read_length=lambda wc: int(int(wc.mean_nuc) / 2),
    threads: 4
    shell:
        "mason_simulator "
        " --input-reference {input.fasta} "
        " --out {output.fq1} "
        " --out-right {output.fq2} "
        " --num-threads {threads} "
        " --fragment-mean-size 350 "
        " --illumina-read-length {params.read_length} "
        " --num-fragments {params.fragment_number} "
        " 2> {log}"


rule download_nanosim_genome_model:
    output:
        model=multiext(
            "resources/{model}/training",
            "_aligned_reads.pkl",
            "_aligned_region.pkl",
            "_base_qualities_model_parameters.tsv",
            "_chimeric_info",
            "_del.hist",
            "_error_markov_model",
            "_error_rate.tsv",
            "_first_match.hist",
            "_gap_length.pkl",
            "_hp_lengths_model_parameters.tsv",
            "_hp_lengths.tsv",
            "_ht_length.pkl",
            "_ht_ratio.pkl",
            "_ins.hist",
            "_match.hist",
            "_match_markov_model",
            "_mis.hist",
            "_model_profile",
            "_reads_alignment_rate",
            "_strandness_rate",
            "_unaligned_length.pkl",
        ),
    conda:
        "../envs/download.yaml"
    log:
        "logs/{model}/training_download.log",
    shell:
        "(cd resources/; "
        "wget https://github.com/bcgsc/NanoSim/raw/refs/heads/master/pre-trained_models/{wildcards.model}.tar.gz; "
        "tar xzf {wildcards.model}.tar.gz; "
        "rm {wildcards.model}.tar.gz; "
        ") 2>{log}"
        # TODO: make this more flexible with newer pretrained models


rule simulate_nanopore_reads:
    input:
        reference_genome="results/circles/{circle}/{circle}.fa",
        model=multiext(
            "resources/{model}/training",
            "_aligned_reads.pkl",
            "_aligned_region.pkl",
            "_base_qualities_model_parameters.tsv",
            "_chimeric_info",
            "_del.hist",
            "_error_markov_model",
            "_error_rate.tsv",
            "_first_match.hist",
            "_gap_length.pkl",
            "_hp_lengths_model_parameters.tsv",
            "_hp_lengths.tsv",
            "_ht_length.pkl",
            "_ht_ratio.pkl",
            "_ins.hist",
            "_match.hist",
            "_match_markov_model",
            "_mis.hist",
            "_model_profile",
            "_reads_alignment_rate",
            "_strandness_rate",
            "_unaligned_length.pkl",
        ),
    output:
        reads="results/circles/{circle}/nanopore/{model}/{circle}.{coverage}X.fq",  # fastq output requires specification of a --basecaller
        errors="results/circles/{circle}/nanopore/{model}/{circle}.{coverage}X.simulated_errors.txt",
        unaligned_reads="results/circles/{circle}/nanopore/{model}/{circle}.{coverage}X.unaligned.fq",  # asking for unaligned_reads implicitly turns off --perfect
    log:
        "logs/circles/{circle}/nanopore/{model}/{circle}.{coverage}X.log",
    params:
        extra=lambda wc: f"--coverage {wc.coverage} --basecaller {lookup(dpath=f"parameters/nanosim_basecaller", within=config)} -dna_type circular",
    resources:
        mem_mb=8000,
    threads: 4
    wrapper:
        "v5.8.0/bio/nanosim/simulator"


rule create_full_sample:
    input:
        fqs=get_sample_input_circle_reads,
    output:
        fq="raw/{group}/{technology}/{model_folder}{group}.{alias}.{frag_len}{read}fq.gz",
    log:
        "logs/samples/{group}/{technology}/{model_folder}{group}.{alias}.{frag_len}{read}log",
    conda:
        "../envs/coreutils.yaml"
    localrule: True
    threads: 1
    shell:
        "( cat {input.fqs} | gzip >{output.fq} ) 2>{log}"
