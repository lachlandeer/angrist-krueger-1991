## Workflow - Replicate MHE Table 4.1.1
##
## authors: @lachlandeer
##

from pathlib import Path

# --- Importing Configuration Files --- #

configfile: "config.yaml"

# --- Dictionaries --- #

# --- Build Rules --- #

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