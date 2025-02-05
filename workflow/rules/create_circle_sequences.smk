rule config_segment_to_bed:
    output:
        bed="results/segments/{circle}.{segment}.bed",
    log:
        "logs/segments/{circle}.{segment}.bed.log",
    conda:
        "../envs/python.yaml"
    params:
        segment=lookup(dpath="circles/{circle}/{segment}", within=config),
    script:
        "../scripts/config_segment_to_bed.py"


rule segment_bed_to_fasta:
    input:
        fasta=f"resources/chromosome_{lookup(dpath= "circles/{circle}/{segment}/chrom", within= config)}.fa",
        bed="results/segments/{circle}.{segment}.bed",
    output:
        fasta="results/segments/{circle}.{segment}.fa.gz",
    log:
        "logs/segments/{circle}.{segment}.fa.log",
    params:
        command="subseq",
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"


rule segment_fasta_rename:
    input:
        fasta="results/segments/{circle}.{segment}.fa.gz",
    output:
        fasta="results/segments/{circle}.{segment}.circle_name.fa.gz",
    log:
        "logs/segments/{circle}.{segment}.circle_name.fa.log",
    params:
        command="replace",
        extra='-p "^" -r "{circle} {segment} "',
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"


rule create_full_circle:
    input:
        fastas=lambda wc: expand(
            "results/segments/{{circle}}.{segment}.circle_name.fa.gz",
            segment=lookup(dpath=f"circles/{wc.circle}", within=config).keys(),
        ),
    output:
        fasta="results/circles/{circle}/{circle}.fa",
    log:
        "logs/circles/{circle}/{circle}.log",
    params:
        command=lambda wc, input: "concat" if len(input.fastas) > 1 else "grep",  # do-nothing grep for circle name if only one segment in circle
        extra=lambda wc, input: "" if len(input.fastas) > 1 else f'-r -p "{wc.circle}"',
    threads: 2
    wrapper:
        "v4.3.0/bio/seqkit"
