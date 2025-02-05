import sys
sys.stderr = open(snakemake.log[0], "w")

with open(snakemake.output["bed"], "w") as bed:
    bed.write(
        f"{snakemake.params.segment['chrom']}\t"
        f"{snakemake.params.segment['start']}\t"
        f"{snakemake.params.segment['end']}\t"
        f"{snakemake.params.segment['name']}\t\t"
        f"{snakemake.params.segment['strand']}\n"
    )
