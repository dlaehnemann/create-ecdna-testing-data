rule map_reads:
    input:
        reads=expand(
            "results/samples/{{group}}/{{technology}}{{model}}/{{group}}.{{alias}}.mean_fragment_nucleotides_{{mean_nuc}}{read}.fq.gz",
            read=lambda wc: [".1", ".2"] if wc.technology == "illumina" else "",
        ),
        # Index needs to be a list of all index files created by bwa
        idx=multiext(
            "resources/all_used_chromosomes.fa",
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac"
        ),
    output:
        "results/quality_control/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam",
    log:
        "logs/map_reads/{group}/{technology}{model}/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.log",
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