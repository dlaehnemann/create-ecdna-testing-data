# function defining the main workflow output
def final_output():
    final_output = [
        "results/simulated_ecdna_data_package.tar.gz"
    ]
    for g in lookup(dpath="groups", within=config):
        final_output.extend(
            expand(
                [
                    "results/quality_control/{group}/illumina/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam",
                    "results/quality_control/mosdepth_coverage/{group}/illumina/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.regions.bed.gz",
                ],
                group=g,
                alias=lookup(dpath=f"groups/{g}", within=config),
                mean_nuc=lookup(
                    dpath=f"parameters/mean_illumina_joint_read_length", within=config
                ),
                read=[".1", ".2"],
            )
        )
        final_output.extend(
            expand(
                [
                    "results/quality_control/{group}/nanopore/{model}{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.bam",
                    "results/quality_control/mosdepth_coverage/{group}/nanopore/{model}{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.regions.bed.gz",
                ],
                group=g,
                model=lookup(
                    dpath=f"parameters/nanosim_pretrained_model", within=config
                ),
                alias=lookup(dpath=f"groups/{g}", within=config),
                mean_nuc=lookup(
                    dpath=f"parameters/mean_nanopore_read_length", within=config
                ),
            )
        )
    return final_output


# helper functions


def determine_fragment_number(wildcards, input):
    stats = pd.read_csv(input.tsv, delimiter="\t")
    total_length = int(stats.loc[0, "sum_len"])
    return int(
        np.ceil(total_length * int(wildcards.coverage) / int(wildcards.mean_nuc))
    )


# I have no intuitive understanding of this parameter, apart from that a higher
# value will mean a wider and flatter distribution. So I am simply fixing it to
# a reasonable value in this spot, and don't expose it to the config.yaml file.
SD_LOGNORMAL = 1.1


def determine_nanopore_median_nuc(wildcards):
    # the log-normal was quite a bit to wrap my head around, this figure helped:
    # https://en.wikipedia.org/wiki/Log-normal_distribution#/media/File:Lognormal_Distribution.svg
    # Following the formula given for the expected value, the following calculates the e^mu, which seems
    # to be what you need to specify as --median_len here, as this then gets transformed with np.log(e^mu)
    # to mu in the nanosim code.
    return int(int(wildcards.mean_nuc) / np.exp(SD_LOGNORMAL**2 / 2))


# input functions


def get_sample_input_circle_reads(wc):
    circles = lookup(dpath=f"groups/{wc.group}/{wc.alias}", within=config)
    files = []
    model = "" if wc.model == "" else f"{wc.model}"
    for c in circles:
        cov = lookup(dpath=f"groups/{wc.group}/{wc.alias}/{c}", within=config)
        if wc.model != "":
            cov = int(int(cov) / 4)
        files.append(
            f"results/circles/{c}/{wc.technology}/{model}{c}.{cov}X.mean_fragment_nucleotides_{wc.mean_nuc}{wc.read}.fq",
        )
    return files


def get_package_data_files(wc):
    file_list = []
    for g in lookup(dpath="groups", within=config):
        file_list.extend(
            expand(
                [
                    "results/samples/{group}/illumina/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}{read}.fq.gz",
                ],
                group=g,
                alias=lookup(dpath=f"groups/{g}", within=config),
                mean_nuc=lookup(
                    dpath=f"parameters/mean_illumina_joint_read_length", within=config
                ),
                read=[".1", ".2"],
            )
        )
        file_list.extend(
            expand(
                [
                    "results/samples/{group}/nanopore/{model}{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.fq.gz",
                ],
                group=g,
                model=lookup(
                    dpath=f"parameters/nanosim_pretrained_model", within=config
                ),
                alias=lookup(dpath=f"groups/{g}", within=config),
                mean_nuc=lookup(
                    dpath=f"parameters/mean_nanopore_read_length", within=config
                ),
            )
        )
        file_list.extend(
            [
                "results/samples/samples.tsv",
                "results/samples/units.tsv",
                "config/config.yaml",
            ]
        )
    return file_list

