rule get_reference_chromosomes:
    output:
        "resources/chromosome_{chrom}.fa",
    params:
        species=lookup(dpath="reference/species", within=config),
        datatype="dna",
        build=lookup(dpath="reference/build", within=config),
        release=lookup(dpath="reference/release", within=config),
        chromosome=["{chrom}"],
    log:
        "logs/get_chromosome_{chrom}_ref.log",
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    wrapper:
        "v4.3.0/bio/reference/ensembl-sequence"


ALL_USED_CHROMOSOMES = sorted(
    set(
        [
            config["circles"][c][s]["chrom"]
            for c in config["circles"].keys()
            for s in config["circles"][c].keys()
        ]
    )
)


rule merge_reference_chromosomes:
    input:
        chromosome_fastas=expand(
            "resources/chromosome_{chrom}.fa", chrom=ALL_USED_CHROMOSOMES
        ),
    output:
        "resources/all_used_chromosomes.fa",
    log:
        "logs/merge_all_used_chromosomes.log",
    conda:
        "../envs/coreutils.yaml"
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    shell:
        "cat {input.chromosome_fastas} >{output} 2>{log}"


rule minimap2_index:
    input:
        target="resources/all_used_chromosomes.fa",
    output:
        "resources/all_used_chromosomes.mmi",
    log:
        "logs/minimap2_index/all_used_chromosomes.mmi",
    params:
        extra="",  # optional additional args
    threads: 3
    wrapper:
        "v5.5.2/bio/minimap2/index"
