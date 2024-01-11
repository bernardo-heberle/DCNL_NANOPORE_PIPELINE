process FAST5_to_POD5 {

    publishDir "results/${params.out_dir}/fast5_to_pod5/${id}/", mode: "symlink", overwrite: true
    
    label 'cpu'

    input:
        tuple val(id), path(fast5)

    output:
        tuple val("${id}"), path("*.pod5")


    script:
        """

        pod5 convert fast5 *.fast5 --output . --one-to-one . --threads 12
        
        """

}

process BASECALL_CPU {

    publishDir "results/${params.out_dir}/basecalling_output/", mode: "copy", overwrite: true    
    
    label 'cpu'
    
    input:
        tuple val(id), path(pod5_dir)
        val speed
        val mods
        val config
        val trim
        val qscore
	val devices
	path ref

    output:
	path("*.bam"), emit: bam
	path("*.txt"), emit: txt


   script:
        """

        if [[ "$config" == "false" ]]; then
            
            if [[ "$mods" == "false" ]]; then 
                dorado basecaller "${speed}" . -x cpu --trim "${trim}" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam" 
            else
                dorado basecaller "${speed},${mods}" . -x cpu --trim "${trim}" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"
            fi
         
         else
            
            if [[ "$mods" == "false" ]]; then
        
                dorado basecaller "${speed}" . -x cpu --trim "${trim}" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"

            else
            
                dorado basecaller "${speed},${mods}" . -x cpu --trim "${trim}" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"

            fi
        fi

        samtools sort -@ -12 "${id}.bam" -o "${id}_sorted.bam"
        rm "${id}.bam"
        mv "${id}_sorted.bam" "${id}.bam"

        dorado summary "${id}.bam" > "${id}.txt"

        """
}


process BASECALL_CPU_DEMUX {

    publishDir "results/${params.out_dir}/basecalling_output/", mode: "copy", overwrite: true


    label 'cpu'

    input:
        tuple val(id), path(pod5_dir)
        val speed
        val mods
        val config
        val trim
        val qscore
        val trim_barcode
	val devices
	path ref

    output:
	path("*.bam"), emit: bam
	path("*.txt"), emit: txt


   script:
        """

        if [[ "$config" == "false" ]]; then

            if [[ "$mods" == "false" ]]; then
                dorado basecaller "${speed}" . -x cpu --trim "none" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"
            else
                dorado basecaller "${speed},${mods}" . -x cpu --trim "none" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"
            fi

         else

            if [[ "$mods" == "false" ]]; then

                dorado basecaller "${speed}" . -x cpu --trim "none" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"

            else

                dorado basecaller "${speed},${mods}" . -x cpu --trim "none" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" > "${id}.bam"

            fi
        fi

        samtools sort -@ -12 "${id}.bam" -o "${id}_sorted.bam"
        rm "${id}.bam"
        mv "${id}_sorted.bam" "${id}.bam"
       
        if [[ "$trim_barcode" == "true" ]]; then
            dorado demux --output-dir "./demux_data/" --no-classify "${id}.bam"
        else
            dorado demux --no-trim --output-dir "./demux_data/" --no-classify "${id}.bam"
        fi

        cd ./demux_data/
       
        for file in *; do
            samtools sort -@ -12 "\$file" -o "${id}_\${file}"
            rm "\$file"
        done

        cd ../

        rm "${id}.bam"

        mv ./demux_data/* ./

        rm -r ./demux_data/

        for file in *.bam; do
            new_id="\${file%%.*}"
            dorado summary "\$file" > "\${new_id}.txt"
        done

        """
}
    
process BASECALL_GPU {

    publishDir "results/${params.out_dir}/basecalling_output/", mode: "copy", overwrite: true    
    
    label 'gpu'
    
    input:
        tuple val(id), path(pod5_dir)
        val speed
        val mods
        val config
        val trim
        val qscore
	val devices
	path ref

    output:
	path("*.bam"), emit: bam
	path("*.txt"), emit: txt


   script:
        """

        if [[ "$config" == "false" ]]; then
            
            if [[ "$mods" == "false" ]]; then 
                dorado basecaller "${speed}" . --trim "${trim}" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam" 
            else
                dorado basecaller "${speed},${mods}" . --trim "${trim}" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"
            fi
         
         else
            
            if [[ "$mods" == "false" ]]; then
        
                dorado basecaller "${speed}" . --trim "${trim}" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"

            else
            
                dorado basecaller "${speed},${mods}" . --trim "${trim}" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"

            fi
        fi

        samtools sort -@ -12 "${id}.bam" -o "${id}_sorted.bam"
        rm "${id}.bam"
        mv "${id}_sorted.bam" "${id}.bam"

        dorado summary "${id}.bam" > "${id}.txt"

        """
}


process BASECALL_GPU_DEMUX {

    publishDir "results/${params.out_dir}/basecalling_output/", mode: "copy", overwrite: true


    label 'gpu'

    input:
        tuple val(id), path(pod5_dir)
        val speed
        val mods
        val config
        val trim
        val qscore
        val trim_barcode
	val devices
	path ref

    output:
	path("*.bam"), emit: bam
	path("*.txt"), emit: txt

   script:
        """

        if [[ "$config" == "false" ]]; then

            if [[ "$mods" == "false" ]]; then
                dorado basecaller "${speed}" . --trim "none" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"
            else
                dorado basecaller "${speed},${mods}" . --trim "none" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"
            fi

         else

            if [[ "$mods" == "false" ]]; then

                dorado basecaller "${speed}" . --trim "none" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"

            else

                dorado basecaller "${speed},${mods}" . --trim "none" --config "${config}" --min-qscore "${qscore}" --reference "${ref}" --device "cuda:${devices}" > "${id}.bam"

            fi
        fi

	samtools sort -@ -12 "${id}.bam" -o "${id}_sorted.bam"
	rm "${id}.bam"
	mv "${id}_sorted.bam" "${id}.bam"
	
       
        if [[ "$trim_barcode" == "true" ]]; then
            dorado demux --output-dir "./demux_data/" --no-classify "${id}.bam"
        else
            dorado demux --no-trim --output-dir "./demux_data/" --no-classify "${id}.bam"
        fi

        cd ./demux_data/
       
        for file in *; do
	    samtools sort -@ -12 "\$file" -o "${id}_\${file}"
	    rm "\$file"	
        done

        cd ../

        rm "${id}.bam"

        mv ./demux_data/* ./

        rm -r ./demux_data/

        for file in *.bam; do
            new_id="\${file%%.*}"
            dorado summary "\$file" > "\${new_id}.txt"
        done

        """
}
