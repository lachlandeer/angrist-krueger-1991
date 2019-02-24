## Workflow - Replicate MHE Table 4.1.1
##
## authors: @lachlandeer
##

from pathlib import Path

# --- Importing Configuration Files --- #

configfile: "config.yaml"

# --- Dictionaries --- #

FIGS = glob_wildcards(config["src_figures"] + "{iFile}.R").iFile
print(FIGS)

# --- Build Rules --- #

rule all:
    input:
        figures = expand(config["out_figures"] + "{iFigure}.pdf",
                        iFigure = FIGS)

rule create_figure:
    input:
        script = config["src_figures"] + "{iFigure}.R",
        data   = config["out_data"] + "cohort_summary.csv",
    output:
        pdf = config["out_figures"] + "{iFigure}.pdf",
    log:
        config["log"] + "figures/{iFigure}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.pdf} \
            > {log} 2>&1"

rule gen_cohort_sum:
    input:
        script = config["src_data_mgt"] + "cohort_summary.R",
        data   = config["out_data"] + "angrist_krueger.csv",
    output:
        data = config["out_data"] + "cohort_summary.csv",
    log:
        config["log"] + "data-mgt/cohort_summary.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.data} \
            > {log} 2>&1"

rule gen_reg_vars:
    input:
        script      = config["src_data_mgt"] + "gen_reg_vars.R",
        zip_archive = config["src_data"] + "angrist_krueger_1991.zip"
    output:
        data = Path(config["out_data"] + "angrist_krueger.csv")
    log:
        config["log"] + "data-mgt/gen_reg_vars.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.zip_archive} \
            --out {output.data} \
            > {log} 2>&1"

rule download_data:
    input:
        script = config["src_data_mgt"] + "download_data.R",
    output:
        data = Path(config["src_data"] + "angrist_krueger_1991.zip"),
    params:
        url = "http://economics.mit.edu/files/397",
    log:
        config["log"] + "data-mgt/download_data.Rout"
    shell:
        "Rscript {input.script} \
            --url {params.url} \
            --dest {output.data} \
            > {log} 2>&1"

# --- Clean Rules --- #
## clean              : removes all content from out/ directory
rule clean:
    shell:
        "rm -rf out/*"

# --- Help Rules --- #
## help               : prints help comments for Snakefile
rule help:
    input:
        main     = "Snakefile",
    output: "HELP.txt"
    shell:
        "find . -type f -name 'Snakefile' | tac | xargs sed -n 's/^##//p' \
            > {output}"
