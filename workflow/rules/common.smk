# function defining the main workflow output
def final_output():
    final_output = ["results/simulated_ecdna_data_package.tar.gz"]
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
            )
        )
        final_output.extend(
            expand(
                [
                    "results/quality_control/{group}/nanopore/{model}/{group}.{alias}.bam",
                    "results/quality_control/mosdepth_coverage/{group}/nanopore/{model}/{group}.{alias}.regions.bed.gz",
                ],
                group=g,
                model=lookup(
                    dpath=f"parameters/nanosim_pretrained_model", within=config
                ),
                alias=lookup(dpath=f"groups/{g}", within=config),
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


# input functions


def get_sample_input_circle_reads(wc):
    circles = lookup(dpath=f"groups/{wc.group}/{wc.alias}", within=config)
    files = []
    for c in circles:
        cov = lookup(dpath=f"groups/{wc.group}/{wc.alias}/{c}", within=config)
        if wc.model_folder != "":
            cov = int(int(cov) / 4)
        files.append(
            f"results/circles/{c}/{wc.technology}/{wc.model_folder}{c}.{cov}X.{wc.frag_len}{wc.read}fq",
        )
    return files


def get_package_data_files(wc):
    file_list = []
    for g in lookup(dpath="groups", within=config):
        file_list.extend(
            expand(
                [
                    "raw/{group}/illumina/{group}.{alias}.mean_fragment_nucleotides_{mean_nuc}.{reads}fq.gz",
                ],
                group=g,
                alias=lookup(dpath=f"groups/{g}", within=config),
                mean_nuc=lookup(
                    dpath=f"parameters/mean_illumina_joint_read_length", within=config
                ),
                reads=["1.", "2."],
            )
        )
        file_list.extend(
            expand(
                [
                    "raw/{group}/nanopore/{model}/{group}.{alias}.fq.gz",
                ],
                group=g,
                model=lookup(
                    dpath=f"parameters/nanosim_pretrained_model", within=config
                ),
                alias=lookup(dpath=f"groups/{g}", within=config),
            )
        )
        file_list.extend(
            [
                "raw/samples.tsv",
                "raw/units.tsv",
            ]
        )
    return file_list
