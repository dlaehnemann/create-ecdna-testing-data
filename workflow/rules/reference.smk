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

