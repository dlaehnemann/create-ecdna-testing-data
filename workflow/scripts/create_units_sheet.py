import sys
sys.stderr = open(snakemake.log[0], "w")

with open(snakemake.output.tsv, "w") as out:
    out.write(
        "\t".join(
            [
                "sample_name",
                "unit_name",
                "fq1",
                "fq2",
            ]
        )
    )
    out.write("\n")
    for g in snakemake.config["groups"]:
        for alias in snakemake.config["groups"][g]:
            out.write(
                "\t".join(
                    [
                        f"{g}_{alias}_i",
                        "u1",
                        f"raw/{g}/illumina/{g}.{alias}.mean_fragment_nucleotides_{snakemake.params.mean_nuc_illumina}.1.fq.gz",
                        f"raw/{g}/illumina/{g}.{alias}.mean_fragment_nucleotides_{snakemake.params.mean_nuc_illumina}.2.fq.gz",
                    ]
                )
            )
            out.write("\n")
            out.write(
                "\t".join(
                    [
                        f"{g}_{alias}_n",
                        "u1",
                        f"raw/{g}/nanopore/{snakemake.params.nanopore_model}/{g}.{alias}.fq.gz",
                        "",
                    ]
                )
            )
            out.write("\n")