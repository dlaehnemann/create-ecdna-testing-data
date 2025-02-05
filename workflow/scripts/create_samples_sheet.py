import sys
sys.stderr = open(snakemake.log[0], "w")

with open(snakemake.output.tsv, "w") as out:
    out.write(
        "\t".join(
            [
                "sample_name",
                "group",
                "alias",
                "platform",
            ]
        )
    )
    out.write("\n")
    for g in snakemake.config["groups"]:
        for alias in snakemake.config["groups"][g]:
            for platform in ["NANOPORE", "ILLUMINA"]:
                p = platform[0].lower()
                out.write(
                    "\t".join([f"{g}_{alias}_{p}", g, f"{alias}_{p}", platform])
                )
                out.write("\n")