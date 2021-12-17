# ECM-Model
Knowledge base how to setup the ECM model inputs

# Workflow
### Scan size
If there is LIKWID available:
```
./bench_scan_size.sh
```
This script includes `check-state.sh` and `machine-state.sh` and collects different benchmark results.
The configuration is set in a config file (like "`casclakesp2_config.txt`").


### ECM Generator
`ecm_generator/ecm.sh` works with application model and machine model.
- Files in `application_model/` consist of RDs and WRs of application and can be given to `ecm.sh` script
- Files in `machine_model/` consist of machine information like cache sizes, cache BWs, MEM BWs, and the ECM hypothesis.
  Currently, penalties are not covered.

### Plot results
`./generate_all_plots.sh <RESULTS> <MACHINEMODEL>` runs ecm script and collects "everything" and generates plots in different PDFs and an overall `ecm.pdf` PDF.

