# Replicate MHE Table 4.1.1 and Figure 4.1.1

## What this repo does

We replicate Table 4.1.1 and Figure 4.1.1 from Mostly Harmless Econometrics using a reproducible research workflow.

Our weapons of choice are:

* `Snakemake` to manage the build and dependencies
* `R` for statistical analysis

## How to Build this repo

If you have Snakemake and R installed, navigate your terminal to this directory.

### Installing Missing R packages

To ensure all R libraries are installed, type

```
snakemake install_packages
```
into a your terminal and press `RETURN`.

If you modify the packages used in this repo, you should rerun this command to store package updates in the `REQUIREMENTS.txt`.

### Building the Output
Type:

```
snakemake all
```

into a your terminal and press `RETURN`

See [`HELP.txt`](HELP.txt) for explanation of what the Snakemake Rules are doing.

## Install instructions

### Installing `R`

* Install the latest version of `R` by following the instructions
  [here](https://pp4rs.github.io/installation-guide/r/).
    * You can ignore the RStudio instructions for the purpose of this project.

### Installing `Snakemake`

This project uses `Snakemake` to execute our research workflow.
You can install snakemake as follows:
* Install Snakemake from the command line (needs pip, and Python)
    ```
    pip install snakemake
    ```
    * If you haven't got Python installed click [here](https://pp4rs.github.io/installation-guide/python/) for instructions

* Windows and old Mac OSX users: you may need to manually install the `datrie` package if you are getting errors. Using conda, this seems to work best:

    ```
    conda install datrie
    ```

## Suggested Citation:

Deer, Lachlan, 2019. "Replication of Angrist and Krueger (1991) : Table 4.1.1 and Figure 4.1.1 from Mostly Harmless Econometrics.
