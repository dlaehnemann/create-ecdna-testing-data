rule get_circle_stats:
    input:
        fasta="results/circles/{circle}/{circle}.fa"
    output:
        tsv="results/circles/{circle}/{circle}.stats.tsv"
    log:
        "logs/circles/{circle}/{circle}.stats.log"
    params:
        command="stats",
        extra="--tabular"
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"


rule sliding_window_around_circle_references:
    input:
        fasta="results/circles/{circle}/{circle}.fa"
    output:
        fasta="results/circles/{circle}/{circle}.circular_sliding_windows.fa",
    log:
        "logs/circles/{circle}/{circle}.circular_sliding_windows.log"
    params:
        command="sliding",
        extra="--circular-genome -W 3996 -s 999",
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"


def determine_fragment_number(wildcards, input):
    stats = pd.read_csv(input.tsv, delimiter="\t")
    total_length = int(stats.loc[0, "sum_len"])
    return int( np.ceil( total_length * int(wildcards.coverage) / int(wildcards.mean_nuc) ) )

rule simulate_illumina_reads:
    input:
        fasta="results/circles/{circle}/{circle}.circular_sliding_windows.fa",
        tsv="results/circles/{circle}/{circle}.stats.tsv",
    output:
        fq1="results/circles/{circle}/illumina/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.1.fq",
        fq2="results/circles/{circle}/illumina/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.2.fq",
    log:
        "logs/circles/{circle}/illumina/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.log",
    conda: "../envs/mason.yaml"
    params:
        fragment_number=lambda wc, input: determine_fragment_number(wc, input),
        read_length=lambda wc: int( int(wc.mean_nuc) / 2),
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
            "resources/human_NA12878_DNA_FAB49712_guppy/training",
            "_aligned_reads.pkl",
            "_aligned_region.pkl",
            "_chimeric_info",
            "_error_markov_model",
            "_error_rate.tsv",
            "_first_match.hist",
            "_gap_length.pkl",
            "_ht_length.pkl",
            "_ht_ratio.pkl",
            "_match_markov_model",
            "_model_profile",
            "_reads_alignment_rate",
            "_strandness_rate",
            "_unaligned_length.pkl",
        ),
    conda: "../envs/download.yaml"
    log: "logs/human_NA12878_DNA_FAB49712_guppy/training_download.log",
    shell:
        "(cd resources/; "
        "wget https://github.com/bcgsc/NanoSim/raw/v3.1.0/pre-trained_models/human_NA12878_DNA_FAB49712_guppy.tar.gz; "
        "tar xzf human_NA12878_DNA_FAB49712_guppy.tar.gz; "
        "rm human_NA12878_DNA_FAB49712_guppy.tar.gz; "
        ") 2>{log}"


SD_LOGNORMAL=1.1

def determine_nanopore_median_nuc(wildcards):
    # the log-normal was quite a bit to wrap my head around, this figure helped:
    # https://en.wikipedia.org/wiki/Log-normal_distribution#/media/File:Lognormal_Distribution.svg
    # Following the formula given for the expected value, the following calculates the e^mu, which seems
    # to be what you need to specify as --median_len here, as this then gets transformed with np.log(e^mu)
    # to mu in the nanosim code.
    return int(int(wildcards.mean_nuc)/np.exp(SD_LOGNORMAL**2/2))

rule simulate_nanopore_reads:
    input:
        reference_genome="results/circles/{circle}/{circle}.fa",
        model=multiext(
            "resources{model}",
            "_aligned_reads.pkl",
            "_aligned_region.pkl",
            "_chimeric_info",
            "_error_markov_model",
            "_error_rate.tsv",
            "_first_match.hist",
            "_gap_length.pkl",
            "_ht_length.pkl",
            "_ht_ratio.pkl",
            "_match_markov_model",
            "_model_profile",
            "_reads_alignment_rate",
            "_strandness_rate",
            "_unaligned_length.pkl",
        ),
        tsv="results/circles/{circle}/{circle}.stats.tsv"
    output:
        reads="results/circles/{circle}/nanopore{model}/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.fq",  # fastq output requires specification of a --basecaller
        errors="results/circles/{circle}/nanopore{model}/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.simulated_errors.txt",
        unaligned_reads="results/circles/{circle}/nanopore{model}/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}simulated_reads.unaligned.fq",  # asking for unaligned_reads implicitly turns off --perfect
    log:
        "logs/circles/{circle}/nanopore{model}/{circle}.{coverage}X.mean_fragment_nucleotides_{mean_nuc}.log",
    params:
        extra=lambda wc, input: f"--number {determine_fragment_number(wc, input)} --median_len {determine_nanopore_median_nuc(wc)} --sd_len {SD_LOGNORMAL} --basecaller guppy -dna_type circular", # --median_len is really used as the mean length argument in numpy.random.lognormal, see here: https://github.com/bcgsc/NanoSim/blob/23911b67ce4733f0468ac26296e25348e3b73b4b/src/simulator.py#L1411
    resources:
        mem_mb=99000,  # this very high memory requirement was for one particular circle: results/circles/c02/nanopore/human_NA12878_DNA_FAB49712_guppy/training/c02.10X.mean_fragment_nucleotides_30000.fq
        #lsf_queue="highmem",  # if you work on a cluster, make this the variable you need to send your job to a queue with the above mentioned amount of memory
    threads: 4
    wrapper:
        "v5.5.2/bio/nanosim/simulator"


def get_sample_input_circle_reads(wc):
    circles = lookup(dpath=f"groups/{wc.group}/{wc.alias}", within=config)
    files = []
    model = "" if wc.model == "" else f"{wc.model}"
    for c in circles:
        cov = lookup(dpath=f"groups/{wc.group}/{wc.alias}/{c}", within=config)
        if wc.model != "":
            cov = int(int(cov) / 4)
        files.append(
            f"results/circles/{c}/{wc.technology}{model}/{c}.{cov}X.mean_fragment_nucleotides_{wc.mean_nuc}{wc.read}.fq",

        )
    return files

rule create_full_sample:
    input:
        fqs=get_sample_input_circle_reads,
    output:
        fq="results/samples/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}{read}.fq.gz",
    log:
        "logs/samples/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}{read}.log",
    conda: "../envs/coreutils.yaml"
    localrule: True
    threads: 1
    shell:
        "( cat {input.fqs} | gzip >{output.fq} ) 2>{log}"
