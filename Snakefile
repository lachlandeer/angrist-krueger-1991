## Workflow - Replicate MHE Table 4.1.1
##            and Figure 4.1.1
##
## authors: @lachlandeer
##

from pathlib import Path

# --- Importing Configuration Files --- #

configfile: "config.yaml"

# --- Dictionaries --- #

FIGS = glob_wildcards(config["src_figures"] + "{iFile}.R").iFile
INST = glob_wildcards(config["src_model_specs"] + "instrument_{iInst}.json").iInst
FIXED_EFFECTS = ["fixed_effects", "no_fixed_effects"]

# --- Build Rules --- #
## all                : moves pdf to root, builds project if missing dependency
rule all:
    input:
        paper  = config["out_paper"] + "paper.pdf",
        slides = config["out_slides"] + "slides.pdf"
    output:
        paper  = Path("pp4rs_assignment_paper.pdf"),
        slides = "pp4rs_assignment_slides.pdf"
    shell:
        "rm -f Rplots.pdf && \
            cp {input.paper} {output.paper} && \
                cp {input.slides} {output.slides}"

#
# Builds Paper & Slides
#

## slides             : builds a rmarkdown slide set to pdf
# Note: this uses a simpler command line parsing strategy
rule slides:
    input:
        slides = config["src_slides"] + "slides.Rmd",
        runner = config["src_lib"] + "knit_rmd.R",
        figures = expand(config["out_figures"] + "{iFigure}.pdf",
                        iFigure = FIGS),
        table = config["out_tables"] + "regression_table.tex"
    output:
        pdf = Path(config["out_slides"] + "slides.pdf")
    log:
        config["log"] + "slides/slides.Rout"
    shell:
        "Rscript {input.runner} {input.slides} {output.pdf} \
            > {log} 2>&1"

## paper              : builds rmarkdown paper to pdf
# Note: this uses a simpler command line parsing strategy
rule paper:
    input:
        paper = config["src_paper"] + "paper.Rmd",
        runner = config["src_lib"] + "knit_rmd.R",
        figures = expand(config["out_figures"] + "{iFigure}.pdf",
                        iFigure = FIGS),
        table = config["out_tables"] + "regression_table.tex"
    output:
        pdf = Path(config["out_paper"] + "paper.pdf")
    log:
        config["log"] + "paper/paper.Rout"
    shell:
        "Rscript {input.runner} {input.paper} {output.pdf} \
            > {log} 2>&1"

#
# Construct Estimates Table
#
## make_table         : construct regression table
rule make_table:
    input:
        script = config["src_tables"] + "regression_table.R",
        ols_results = expand(config["out_analysis"] + "ols_{iFixedEffect}.Rds",
                        iFixedEffect = FIXED_EFFECTS),
        iv_fe = expand(config["out_analysis"] + "iv_{iInstrument}.{iFixedEffect}.Rds",
                        iInstrument = INST,
                        iFixedEffect = FIXED_EFFECTS),
    output:
        table = Path(config["out_tables"] + "regression_table.tex"),
    params:
        directory = "out/analysis"
    log:
        config["log"] + "tables/regression_table.Rout"
    shell:
        "Rscript {input.script} \
            --filepath {params.directory} \
            --out {output.table} \
            > {log} 2>&1"


#
# Estimation Rules
#

## run_iv_fe          : estimate IV regression equations that have Fixed Effects
rule run_iv_fe:
    input:
        script   = config["src_analysis"] + "estimate_iv.R",
        data     = config["out_data"] + "angrist_krueger.csv",
        equation = config["src_model_specs"] + "estimating_equation.json",
        fe       = config["src_model_specs"] + "{iFixedEffect}.json",
        instr    = config["src_model_specs"] + "instrument_{iInstrument}.json",
    output:
        Path(config["out_analysis"] + "iv_{iInstrument}.{iFixedEffect}.Rds")
    log:
        config["log"] + "analysis/iv_{iInstrument}.{iFixedEffect}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --model {input.equation} \
            --fixedEffects {input.fe} \
            --instruments {input.instr} \
            --out {output} \
            > {log} 2>&1"

# run_ols             : run OLS models
rule run_ols:
    input:
        script   = config["src_analysis"] + "estimate_ols.R",
        data     = config["out_data"] + "angrist_krueger.csv",
        equation = config["src_model_specs"] + "estimating_equation.json",
        fe       = config["src_model_specs"] + "{iFixedEffect}.json",
    output:
        Path(config["out_analysis"] + "ols_{iFixedEffect}.Rds")
    log:
        config["log"] + "analysis/ols_{iFixedEffect}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --model {input.equation} \
            --fixedEffects {input.fe} \
            --out {output} \
            > {log} 2>&1"

#
# create figures
#
## create_figure      : constructs summary figures
rule create_figure:
    input:
        script = config["src_figures"] + "{iFigure}.R",
        data   = config["out_data"] + "cohort_summary.csv",
    output:
        pdf = Path(config["out_figures"] + "{iFigure}.pdf"),
    log:
        config["log"] + "figures/{iFigure}.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.pdf} \
            > {log} 2>&1"

#
# data management rules
#

## gen_cohort_sum     : compute summary stats by cohort
rule gen_cohort_sum:
    input:
        script = config["src_data_mgt"] + "cohort_summary.R",
        data   = config["out_data"] + "angrist_krueger.csv",
    output:
        data = Path(config["out_data"] + "cohort_summary.csv"),
    log:
        config["log"] + "data-mgt/cohort_summary.Rout"
    shell:
        "Rscript {input.script} \
            --data {input.data} \
            --out {output.data} \
            > {log} 2>&1"

## gen_reg_vars       : creates missing variables needed for regression
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

## download_data      : downloads AK1991 data from web
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

# --- R package resolution --- #

## find_packages      : looks for R packages used across all scripts
rule find_packages:
    output:
        "REQUIREMENTS.txt"
    shell:
        "bash find_r_packages.sh"

## install_packages   : installs missing R packages
rule install_packages:
    input:
        script = config["src_lib"] + "install_r_packages.R",
        requirements = "REQUIREMENTS.txt"
    shell:
        "Rscript {input.script}"

# --- Clean Rules --- #
## clean              : removes all content from out/ directory
rule clean:
    shell:
        "rm -rf out/* *.pdf"

# --- Help Rules --- #
## help               : prints help comments for Snakefile
rule help:
    input:
        main     = "Snakefile",
    output: "HELP.txt"
    shell:
        "find . -type f -name 'Snakefile' | tac | xargs sed -n 's/^##//p' \
            > {output}"
