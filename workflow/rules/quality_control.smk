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

    params:
        extra=r"-R '@RG\tID:{technology}{model}.{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}\tSM:{technology}{model}.{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}'",
        sort="samtools",  # Can be 'none', 'samtools', or 'picard'.
        sort_order="coordinate",  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra="",  # Extra args for samtools/picard sorts.
    threads: 8
    wrapper:
        "v5.5.2/bio/bwa-mem2/mem"


#rule create_all_segments_bed:
#    input:
#    output:
#        "results/segments/all_segments.bed",
#    conda:
#        "../envs/bedtools.yaml"