# ECM-Model
Knowledge base how to setup the ECM model inputs

# Dependencies
- LIKWID
- LaTeX and TikZ for plotting (Step 3)

# Current limitations
- Only for streaming kernels
- No hardware counter measurements included for verification

# Workflow
## Step 1: Running benchmarks
The script `./bench_scan_size.sh` has to be used to run the benchmark and collect the performance results.
The script takes in a machine configuration file which defines the `likwid-bench` benchmarks to be runs, the result folders and hardware settings.
Some sample configuration files can be found in the `machine_config` folder.
The benchmark runs streaming kernels with different stream/array size.
For example to run with the settings in `machine_config/casclakesp2_config.txt` file the following can be used:
```
/bench_scan_size.sh machine_config/casclakesp2_config.txt
```

NB: If some basic performance relevant hardware configuration is not set as described in the config file, the script will 
pre-exit with a message "Hardware not configured properly".

## Step 2: ECM Generator
This step is optional. The step generates the ECM model plots corresponding to the benchmarks run in the previous step.
The ECM generation requires two basic inputs: application model and machine model.

### 2.1 Application model
The application model defines the properties of the benchmark.
The application model is defined using a file written into the folder `ecm_generator/application_model` which indicates the number and type of streams seen in the benchmark.
- `Read-only` specifies the number of steams/arrays that have to be just read
- `Write-only` specifies the number of steams/arrays that have to be just written
- `Read-Write` specifies the number of steams/arrays that have to be both read and written

Examples of the application model files can be found in the `ecm_generator/application_model` folder.

### 2.2 Machine model
The machine model determines the machine capabilities. 
It is defined using files written to `ecm_generator/machine_model` folder.
The files carry information like:
- `CL_size` specifies the cacheline size in bytes
- `[cache-name]_read_bw` specifies the read bandwidth between the given [cache-name] cache level and its higher hierarchy. For example `L1_read_bw` indicates read bandwidth between L1 and registers
- `[cache-name]_write_bw` specifies the write bandwidth between the given [cache-name] cache level and its higher hierarchy. For example `L1_write_bw` indicates write bandwidth between L1 and registers
- `[cache-name]_shared_bw` specifies the bandwidth between the given [cache-name] cache level and its higher hierarchy when a different resource becomes a bottleneck. For example `L1_shared_bw` indicates the bandwidth when the common (for both reads and writes) address generation unit (AGU) becomes a bottleneck.
- `[cache-name]_WA` indicates whether write-allocate is applicable for the cache
- `[cache-name]_VICTIM` indicates whether the cache is a victim cache
- `[cache-name]_SIZE` indicates the cache size in kB
- `ECM_hypothesis` indicates the overlap hypothesis of the given hardware under a given setting.

### 2.3 Generating ECM data
The script `ecm_generator/ecm.sh` generates the ECM model prediction data.
It takes the application model and machine model defined above as input.
For example to generate ECM model with application model `ecm_generator/application_model/copy.config` and machine model `ecm_generator/machine_model/casclakesp2_nps1.config` following command can be used:
```
cd ecm_generator
./ecm.sh "application_model/copy.config" "machine_model/casclakesp2_nps1.config" 
```

Note that in general only the application model (2.1) and machine model (2.2) has to be defined. 
The generation of ECM model (2.3) need not be done manually as indicated here and will be done automatically when calling the plotting script. See next section.


## Step 3: Plotting results
The script `./generate_all_plots.sh` runs ecm script `ecm_generator/ecm.sh` (2.3) and collects the performance measurements collected in Step 1 to generate final plots. 
The script requires the location of folder where performance measurements are collected (as specified through configuration file in Step 1) and the machine name to identify the corresponding machine model.
For example to plot the results collected in `results/casclakesp2/nps2/avx512/` with the ECM model corresponding to machine model file `ecm_generator/machine_model/casclakesp2_nps2.config`, the following command should be used:
```
./generate_all_plots.sh results/casclakesp2/nps2/avx512/ casclakesp2_nps2
```
The plots are then generated in a folder called `plots` located in the same directory given in the input.
Plots (in pdf format) for different benchmarks as well as an overall compiled plot called `ecm.pdf` could be found in the `plots` directory.
