rule map_reads_minimap2:
    input:
        target="resources/all_used_chromosomes.mmi",
        query=expand(
            "results/samples/{{group}}/{{technology}}{{model}}/{{group}}.{{alias}}.mean_fragment_nucleotides_{{mean_nuc}}{read}.fq.gz",
            read=lambda wc: [".1", ".2"] if wc.technology == "illumina" else "",
        ),
    output:
        "results/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam",
    log:
        "logs/map_reads_minimap2/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.log",
    params:
        extra=lambda wc: "-x map-ont" if wc.technology == "nanopore" else "-x sr",  # optional
        sorting="coordinate",  # optional: Enable sorting. Possible values: 'none', 'queryname' or 'coordinate'
        sort_extra="",  # optional: extra arguments for samtools/picard
    threads: 3
    wrapper:
        "v5.5.2/bio/minimap2/aligner"


rule samtools_index:
    input:
        "results/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam",
    output:
        "results/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam.bai",
    log:
        "logs/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.index_bam.log",
    params:
        extra="",  # optional params string
    threads: 4  # This value - 1 will be sent to -@
    wrapper:
        "v5.5.2/bio/samtools/index"


ALL_CIRCLE_SEGMENT_COMBINATIONS = [
    {c: s} for c in config["circles"] for s in config["circles"][c]
]


rule create_all_segments_bed:
    input:
        segments=expand(
            "results/segments/{circle}.{segment}.bed",
            zip,
            circle=[list(d)[0] for d in ALL_CIRCLE_SEGMENT_COMBINATIONS],
            segment=[list(d.values())[0] for d in ALL_CIRCLE_SEGMENT_COMBINATIONS],
        ),
    output:
        all_segments="results/segments/all_segments.bed",
    log:
        "logs/segments/all_segments.log",
    shell:
        "(cat {input.segments} | sort -k 1,1 -k2,2n > {output.all_segments}) 2>{log}"


rule mosdepth_cram:
    input:
        bam="results/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam",
        bai="results/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam.bai",
        bed="results/segments/all_segments.bed",
        fasta="resources/all_used_chromosomes.fa",
    output:
        "results/quality_control/mosdepth_coverage/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.mosdepth.global.dist.txt",
        "results/quality_control/mosdepth_coverage/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.mosdepth.region.dist.txt",
        "results/quality_control/mosdepth_coverage/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.regions.bed.gz",
        summary="results/quality_control/mosdepth_coverage/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.mosdepth.summary.txt",  # this named output is required for prefix parsing
    log:
        "logs/quality_control/mosdepth_coverage/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.coverage.log",
    params:
        extra="--no-per-base",  # optional
    # additional decompression threads through `--threads`
    threads: 4  # This value - 1 will be sent to `--threads`
    wrapper:
        "v5.5.2/bio/mosdepth"
