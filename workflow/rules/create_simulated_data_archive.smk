rule create_samples_sheet:
    output:
        tsv="raw/samples.tsv",
    log:
        "logs/samples/samples.tsv.log",
    conda:
        "../envs/python.yaml"
    localrule: True
    script:
        "../scripts/create_samples_sheet.py"


rule create_units_sheet:
    output:
        tsv="raw/units.tsv",
    log:
        "logs/samples/units.tsv.log",
    conda:
        "../envs/python.yaml"
    localrule: True
    params:
        mean_nuc_illumina=lookup(
            dpath="parameters/mean_illumina_joint_read_length", within=config
        ),
        nanopore_model=lookup(
            dpath="parameters/nanosim_pretrained_model", within=config
        ),
    script:
        "../scripts/create_units_sheet.py"


rule package_full_simulated_dataset:
    input:
        files=get_package_data_files,
    output:
        archive="results/simulated_ecdna_data_package.tar.gz",
    log:
        "results/simulated_ecdna_data_package.tar.gz",
    conda:
        "../envs/tar.yaml"
    shell:
        "tar czfv {output.archive} {input.files} 2>{log}"
