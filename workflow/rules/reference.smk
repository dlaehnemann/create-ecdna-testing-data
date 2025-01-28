rule get_reference_chromosomes:
    output:
        "resources/chromosome_{chrom}.fa",
    params:
        species=lookup(dpath="reference/species", within=config),
        datatype="dna",
        build=lookup(dpath="reference/build", within=config),
        release=lookup(dpath="reference/release", within=config),
        chromosome=["{chrom}"]
        # branch="plants",  # optional: specify branch
    log:
        "logs/get_chromosome_{chrom}_ref.log",
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    wrapper:
        "v4.3.0/bio/reference/ensembl-sequence"


ALL_USED_CHROMOSOMES = sorted(
    set(
        [
            config['circles'][c][s]['chrom']
            for c in config['circles'].keys()
            for s in config['circles'][c].keys()
        ]
    )
)


rule merge_reference_chromosomes:
    input:
        chromosome_fastas=expand(
            "resources/chromosome_{chrom}.fa",
            chrom=ALL_USED_CHROMOSOMES
        ),
    output:
        "resources/all_used_chromosomes.fa"
    log:
        "logs/merge_all_used_chromosomes.log"
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    shell:
        "cat {input.chromosome_fastas} >{output} 2>{log}"


rule bwa_mem2_index:
    input:
        "resources/all_used_chromosomes.fa"
    output:
        "resources/all_used_chromosomes.fa.0123",
        "resources/all_used_chromosomes.fa.amb",
        "resources/all_used_chromosomes.fa.ann",
        "resources/all_used_chromosomes.fa.bwt.2bit.64",
        "resources/all_used_chromosomes.fa.pac",
    log:
        "logs/bwa-mem2_index/all_used_chromosomes.log",
    wrapper:
        "v5.5.2/bio/bwa-mem2/index"
