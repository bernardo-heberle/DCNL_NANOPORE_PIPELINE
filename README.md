# DCNL_NANOPORE_PIPELINE
NextFlow pipeline used by the Developmental Cognitive Neuroscience Lab (DCNL) to process Oxford Nanopore (ONT) DNA methylation data



## Getting Started

### 1) Have a functioning version of Nextflow in your Path.

- Information on how to install NextFlow can be found [here](https://www.nextflow.io/docs/latest/getstarted.html).
          
### 2) Have a functioning version of Singularity on your Path.

- Information on how to install Singularity cna be found [here](https://docs.sylabs.io/guides/3.0/user-guide/installation.html)
          
          
### 3) Clone this github repo using the command below

          git clone https://github.com/bernardo-heberle/DCNL_NANOPORE_PIPELINE



### 4) Make sure you have all the sequencing files and reference genomes/assemblies files and annotation files you will need to run the pipeline.
          
- ".fast5" or ".pod5" files.

- refecence/assembly ".fa" file specific to your model organism.
- 

### 5) Set SINGULARITY_CACHEDIR environmental variable to your desired directory:

          echo "SINGULARITY_CACHEDIR=/<your>/<desired>/<path>/" >> ~/.bash_profile && . ~/.bash_profile




##  
## For documentation of pipeline output click on the `OUTPUT_DESCRIPTION.md` file in this repository.
## 


## Pipeline parameters

Many of the parameters for this step are based on dorado basecaller, see their [documentation](https://github.com/nanoporetech/dorado) to understand it better.

          
          --basecall_path               <path to base directory containing all fast5 and/or pod5 files you want to basecall.
                                        It will automatically separate samples based on naming conventions and 
                                        directory structure. example: /sequencing_run/">

          --basecall_speed              <"fast", "hac", "sup". Default = "hac">

          --basecall_mods               <Comma separated list of base modifications you want to basecall. See dorado docs 
                                        for more information. Example: "5mCG_5hmCG,5mC_5hmC,6mA". Default: "False">

          --basecall_compute            <"gpu", "cpu". Default: "gpu". Allows users to choose to basecall with 
                                        CPU or GPU. CPU basecalling is super slow and should only be used for small
                                        test datasets when GPUs are not available. Also, use --basecall_speed "fast"
                                        when basecalling with CPU to make it less slow. Default: "gpu">

          --basecall_config             <configuration name for basecalling setting. This is not necessary since dorado 
                                        is able to automatically determine the appropriate configuration. When set to "None"
                                        the basecaller will automatically pick the basecall configuration.
                                        Example: "dna_r9.4.1_e8_hac@v3.3". Default: "None">

          --basecall_trim              <"all", "primers", "adapters", "none". Default: "None">

          --qscore_thresh              <Mean quality score threshold for basecalled reads to be considered passing. Default: 9>

          
          --demux                       <"True", "False". Whether you want the data to be demultiplexed
                                        setting it to "True" will perform demultiplexing. Default: "False">

          --trim_barcodes               <"True", "False". Only relevant is --demux is set to "True". 
                                        if set to "True" barcodes will be trimmed during demultiplexing
                                        and will not be present in output "fastq" files. Default: "False">

          --gpu_devices                 <Which gpu devices to use for basecalling. Only relevant when
                                        parameter "--basecall_compute" is set to "gpu". Use the 
                                        "nvidia-smi" command to see available gpu devices and their
                                        current usage. Default: "all". Alternative: "0". 
                                        Second Alternative: "0,1,2".

          --prefix                      <Will add a prefix to the beggining of your filenames, good
                                         when wanting to keep track of batches of data.
                                         Example: "Batch_1". Default value is "None" which does not add any prefixes>

          --out_dir                    <Name of output directory. Output files/directories will be output to
                                        "./results/<out_dir>/" in the directory you submitted the pipeline from.
                                        Default: "output_directory">

## Submission example:

          nextflow ../workflow/main.nf --basecall_path "../../data/test_data/" \
                  --basecall_speed "hac" \
                  --ref "../references/mouse_reference.fa" \
                  --gpu_devices "all" \
                  --basecall_mods "5mC_5hmC" \
                  --basecall_config "False" \
                  --basecall_trim "none" \
                  --basecall_compute "gpu" \
                  --basecall_demux "False" \
                  --outdir "test_basecall_gpu_no_demux_mouse"
  


    `
