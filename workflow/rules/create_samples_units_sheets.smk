rule create_samples_sheet:
    output:
        tsv="results/samples/samples.tsv",
    log:
        "logs/samples/samples.tsv.log",
    localrule: True
    script:
        "../create_samples_sheet.py"


rule create_units_sheet:
    output:
        tsv="results/samples/units.tsv",
    log:
        "logs/samples/units.tsv.log",
    localrule: True
    params:
        mean_nuc_illumina=lookup(dpath="parameters/mean_illumina_joint_read_length", within=config),
        mean_nuc_nanopore=lookup(dpath="parameters/mean_nanopore_read_length", within=config),
        nanopore_model=lookup(dpath="parameters/nanosim_pretrained_model", within=config),
    script:
        "../create_units_sheet.py"

