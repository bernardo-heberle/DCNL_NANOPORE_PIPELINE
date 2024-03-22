# DCNL_NANOPORE_PIPELINE
NextFlow pipeline used by the Developmental Cognitive Neuroscience Lab (DCNL) to process Oxford Nanopore (ONT) DNA methylation data



## Getting Started

### 1) Have a functioning version of Nextflow in your Path.

- Information on how to install NextFlow can be found [here](https://www.nextflow.io/docs/latest/getstarted.html).
          
### 2) Have a functioning version of Singularity on your Path.

- Information on how to install Singularity cna be found [here](https://docs.sylabs.io/guides/3.0/user-guide/installation.html)
          
          
### 3) Clone this github repo using the command below

```
git clone https://github.com/bernardo-heberle/DCNL_NANOPORE_PIPELINE
```


### 4) Make sure you have all the sequencing files and reference genomes/assemblies files you need to run the pipeline.
          
- ".fast5" or ".pod5" files.

- refecence/assembly ".fa" file specific to your organism of interest.
  

### 5) Set NXF_SINGULARITY_CACHEDIR environment variable to your desired directory:

Substitute `/<your>/<desired>/<path>/` in the codeblock below for the path to the directory you would like to store your singularity images in. Make sure the directory exists before executing the pipeline.

```
echo "" >> ~/.bash_profile && echo 'NXF_SINGULARITY_CACHEDIR="/<your>/<desired>/<path>/"' >> ~/.bash_profile && echo 'export NXF_SINGULARITY_CACHEDIR' >> ~/.bash_profile && . ~/.bash_profile
```

# Pipeline parameters:

## Parameters for step 1 (Basecalling)

Many of the parameters for this step are based on dorado basecaller, see their [documentation](https://github.com/nanoporetech/dorado) to understand it better.

```
--step                         <Type: Integer. Options are integers 1, 2, 3. Select 1 for basecalling. Select 2 for alignment
                                 filtering and quality control. Select 3 for methylation call pre-processing
                                 with modkit and generating a thorough multiQC report for sequencing stats.
                                 This parameter needs to be set for the pipeline to run. Default: "None">

       
--basecall_path               <Type: Path. Path to base directory containing all fast5 and/or pod5 files you want to basecall.
                              It will automatically separate samples based on naming conventions and 
                              directory structure. example: /sequencing_run/">

--basecall_speed              <Type: String. "fast", "hac", "sup". Default = "hac">

--basecall_mods               <Type: String. Comma separated list of base modifications you want to basecall. See dorado docs 
                              for more information. Example: "5mCG_5hmCG,5mC_5hmC,6mA". Default: "False">

--basecall_compute            <Type: String. "gpu", "cpu". Default: "gpu". Allows users to choose to basecall with 
                              CPU or GPU. CPU basecalling is super slow and should only be used for small
                              test datasets when GPUs are not available. Also, use --basecall_speed "fast"
                              when basecalling with CPU to make it less slow. Default: "gpu">

--basecall_config             <Type: String: configuration name for basecalling setting. This is not necessary since dorado 
                              is able to automatically determine the appropriate configuration. When set to "false"
                              the basecaller will automatically pick the basecall configuration.
                              Example: "dna_r9.4.1_e8_hac@v3.3". Default: "false">

--basecall_trim              <Type: String. "all", "primers", "adapters", "none". Default: "none">

--qscore_thresh              <Type: Integer. Mean quality score threshold for basecalled reads to be considered passing. Default: 9>


--demux                       <Type: Boolean. "True", "False". Whether you want the data to be demultiplexed
                              setting it to "True" will perform demultiplexing. Default: "False">

--trim_barcodes               <Type: Boolean. "True", "False". Only relevant is --demux is set to "True". 
                              if set to "True" barcodes will be trimmed during demultiplexing
                              and will not be present in output "fastq" files. Default: "False">

--gpu_devices                 <Type: String. Which gpu devices to use for basecalling. Only relevant when
                              parameter "--basecall_compute" is set to "gpu". Use the 
                              "nvidia-smi" command to see available gpu devices and their
                              current usage. Default: "all". Alternative: "0". 
                              Second Alternative: "0,1,2".

--prefix                      <Type: String. Will add a prefix to the beggining of your filenames, good
                               when wanting to keep track of batches of data.
                               Example: "Batch_1". Default value is "None" which does not add any prefixes>

--out_dir                    <Type: Path. Name of output directory. Output files/directories will be output to
                              "./results/<out_dir>/" in the directory you submitted the pipeline from.
                              Default: "output_directory">
```
## Parameters for step 2 (Alignment Filtering and Quality Control):

```
--step                                  <Type: Integer. Options are integers 1, 2, 3. Select 1 for basecalling. Select 2 for alignment
                                        filtering and quality control. Select 3 for methylation call pre-processing
                                        with modkit and generating a thorough multiQC report for sequencing stats.
                                        This parameter needs to be set for the pipeline to run. Default: "None">

--steps_2_and_3_input_directory          <This parameter must be set to the output path of step 1 set with the out_dir parameter.
                                          For example "./results/<out_dir>". Default = "None">

--qscore_thresh                          <Mean quality score threshold for basecalled reads to be considered passing.
                                           Should be set to the same value specified in step 1. Default: 9>

--mapq                                   <Type: nteger, set it to the number you want to be used to filter ".bam" file by mapq. --mapq 10 filters out reads
                                          with MAPQ < 10. set it to 0 if don't want to filter out any reads. Default: 10>
```                           


## Parameters for step 2 (Methylation Calling and MultiQC):

```
--step                                       <Type: Integer. Options are integers 1, 2, 3. Select 1 for basecalling. Select 2 for alignment
                                             filtering and quality control. Select 3 for methylation call pre-processing
                                             with modkit and generating a thorough multiQC report for sequencing stats.
                                             This parameter needs to be set for the pipeline to run. Default: "None">

--steps_2_and_3_input_directory             <Type: Path. This parameter must be set to the output path of step 1 set with the out_dir parameter.
                                             Must also be set to the same as the steps_2_and_3_input_directory for step 2.
                                             For example "./results/<out_dir>". Default = "None">

--multiqc_config                            <Type: Path. MultiQC configuration file. We provide a template that works well under
                                             "./references/multiqc_config.yaml" in this GitHub repository, but you are welcome to
                                              customize it as you see fit. Default: "None">

```

## Submission examples:

### STEP 1: GPU basecalling without demultiplexing

```
nextflow ../DCNL_NANOPORE_PIPELINE/workflow/main.nf --basecall_path "../data/test_data_minimal/" \
        --basecall_speed "hac" \
        --step 1 \
        --ref "../references/mouse_reference.fa" \
        --gpu_devices "all" \
        --basecall_mods "5mC_5hmC" \
        --qscore_thresh 9 \
        --basecall_config "False" \
        --basecall_trim "none" \
        --basecall_compute "gpu" \
        --basecall_demux "False" \
        --queue_size 1 \
        --out_dir "test_basecall_gpu_no_demux_mouse" -resume
  ```

### STEP 2: Alignment Filtering and Quality Control

```
nextflow ../DCNL_NANOPORE_PIPELINE/workflow/main.nf \
          --steps_2_and_3_input_directory "./results/test_basecall_gpu_no_demux_mouse/" \
          --qscore_thresh 9 --mapq 10 --step 2 -resume
```

### STEP 3: Methylation calling and MultiQC report:

```
nextflow ../DCNL_NANOPORE_PIPELINE/workflow/main.nf \
          --steps_2_and_3_input_directory "./results/test_basecall_gpu_no_demux_mouse/" \
          --multiqc_config "../DCNL_NANOPORE_PIPELINE/references/multiqc_config.yaml" --step 3 -resume

```
## Pipeline output directory description:

1. **fast5_to_pod5** - One directory per sample. Only exists for sample that had any fast5 files converted into pod5 files for more efficient basecalling with Dorado.

2. **basecalling_output** - Dorado basecalling output. One ".bam"  file per sample (already mapped to the reference genome of choice and sorted).
                                  Also includes one sequencing summary file per sample. Reads for the same run will be separated into different fastq files
                                  based on barcode when demultiplexing is enabled.
   
3. **multiqc_input/pycoqc_no_filter** - Includes pycoQC quality control reports for each sample with metrics prior to alignment filtering by MAPQ.
                                           PycoQC reports are output in both ".html" and ".json" format. The ".html" files can be imported into
                                           a personal computer and opened using any internet browser to provide a quick glance basic statistics from the sequencing run.

4. **multiqc_input/pycoqc_filtered** - Includes pycoQC quality control reports for each sample with metrics post alignment filtering by MAPQ.
                                           PycoQC reports are output in both ".html" and ".json" format. The ".html" files can be imported into
                                           a personal computer and opened using any internet browser to provide a quick glance basic statistics from the sequencing run.

5. **multiqc_input/minimap2** - Includes ".flagstat" and ".idxstat" files generate with samtools from before and after alignment filtering. These files show number
                                        of reads per sample and number of reads per chromosome. This information is integrated in the final multiQC report.

6. **bam_filtering** - Output from filtering bam files. Filtered files only include primary alignments with MAPQ greater than or equal to what the user specified.
                                 This directory includes sorted ".bam" files from before and after filtering and their respective index ".bai" files.

7. **intermediate_qc_reports** - Intermediate quality control reports for each sample separated into 3 directories:
                                         "read_length", "number_of_reads", "quality_score_thresholds".

8. **modkit** - Directory with methylation calls, bed file pileup, and summary files generated using modkit.
                       See [documentation](https://nanoporetech.github.io/modkit/quick_start.html) for more information.


9. **num_reads_report** - Three reports, one with number of reads for each sample, other with reads length, and another with
                            MAPQ and PHRED quality scores used to filter the files.


10. **multiQC_output** - MultiQC output files, most importantly the ".html" report showing summary statistics for all file.


