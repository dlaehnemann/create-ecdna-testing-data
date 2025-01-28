rule create_samples_sheet:
    output:
        tsv="results/samples/samples.tsv"
    localrule: True
    run:
        with open(output.tsv, 'w') as out:
            out.write(
                "\t".join([
                    "sample_name",
                    "group",
                    "alias",
                    "platform",
                ])
            )
            out.write("\n")
            for g in config["groups"]:
                for alias in config["groups"][g]:
                    for platform in ["NANOPORE", "ILLUMINA"]:
                        p = platform[0].lower()
                        out.write(
                            "\t".join([
                                f"{g}_{alias}_{p}",
                                g,
                                f"{alias}_{p}",
                                platform
                            ])
                        )
                        out.write("\n")


rule create_units_sheet:
    output:
        tsv="results/samples/units.tsv"
    localrule: True
    run:
        with open(output.tsv, 'w') as out:
            out.write(
                "\t".join([
                    "sample_name",
                    "unit_name",
                    "fq1",
                    "fq2",
                ])
            )
            out.write("\n")
            for g in config["groups"]:
                for alias in config["groups"][g]:
                    out.write(
                        "\t".join([
                            f"{g}_{alias}_i",
                            "u1",
                            f"raw/{g}/illumina/{g}.{alias}.mean_fragment_nucleotides_{MEAN_NUC_ILLUMINA}.1.fq.gz",
                            f"raw/{g}/illumina/{g}.{alias}.mean_fragment_nucleotides_{MEAN_NUC_ILLUMINA}.2.fq.gz",
                        ])
                    )
                    out.write("\n")
                    out.write(
                        "\t".join([
                            f"{g}_{alias}_n",
                            "u1",
                            f"raw/{g}/nanopore{MODEL}/{g}.{alias}.mean_fragment_nucleotides_{MEAN_NUC_NANOPORE}.fq.gz",
                            "",
                        ])
                    )
                    out.write("\n")
