// Import Modules

include {FAST5_to_POD5; BASECALL_CPU; BASECALL_CPU_DEMUX; BASECALL_GPU; BASECALL_GPU_DEMUX} from '../modules/basecall.nf'

workflow BASECALLING {
        
    take:
        pod5_path
        fast5_path
        speed
        modifications
        config
        trim
        quality_score
        trim_barcode
	devices
	ref

    main:


    FAST5_to_POD5(fast5_path)
    pod5_path = FAST5_to_POD5.out.mix(pod5_path)


    if (params.basecall_compute?.equalsIgnoreCase("cpu")) {
        
        if (params.basecall_demux == true) {

           BASECALL_CPU_DEMUX(pod5_path, speed, modifications, config, trim, quality_score, trim_barcode, devices, ref)

	   BASECALL_CPU_DEMUX.out.view()
        
        } else {
            
            BASECALL_CPU(pod5_path, speed, modifications, config, trim, quality_score, devices, ref)
	    
	    BASECALL_CPU.out.view()
        }
    
    } else if (params.basecall_compute?.equalsIgnoreCase("gpu")) {
        
        if (params.basecall_demux == true) {

            BASECALL_GPU_DEMUX(pod5_path, speed, modifications, config, trim, quality_score, trim_barcode, devices, ref)

  	    BASECALL_GPU_DEMUX.out.view()

        } else {

            BASECALL_GPU(pod5_path, speed, modifications, config, trim, quality_score, devices, ref)

	    BASECALL_GPU.out.view()
        }

    }
}
