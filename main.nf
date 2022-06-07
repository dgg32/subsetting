println "Occupancy Analysis Pipeline     "
println "================================="

println "sam_file            : ${params.sam_file}"
println "sam_folder            : ${params.sam_folder}"



process split_sam {
    

    output:
    //path(params.sam_folder) into split_sam_ch
    val 1 into split_sam_ch

    script:
    """
    mkdir ${params.sam_folder}
    
    python $workflow.projectDir/split_sam_by_fov.py ${params.sam_file} ${params.sam_folder}  20
    """
}



process subset_excel {
    //publishDir params.collect_dir, mode: 'copy' 

    input:
    val dummy from split_sam_ch
    

    output:
    val 1 into occu_out

    //path("${params.output}/*_Summary.xlsx") into summary_ch


    //python /hwfssz8/MGI_BCC/USER/huangsixing/occupancy_analysis/occupancy_chip_wrapper.py -d ${params.data} -l ${lane} -o ${params.output} -s ${params.slide} -c ${params.start} -r ${params.range}

    ///share/app/singularity/3.8.1/bin/singularity exec -B /hwfssz8/MGI_BCC/USER/huangsixing/  ./occu.sif python /app/occupancy_chip_wrapper.py -d /hwfssz8/MGI_BCC/USER/huangsixing/Javier/V300098092_lite1.1 -l L01 -o /hwfssz8/MGI_BCC/USER/huangsixing/test -s V300098092 -c 1 -r 8

    //python ${params.script} -d ${params.data} -l ${lane} -o ${params.output} -s ${params.slide} -c ${params.start} -r ${params.range}


    script:
    """
    /share/app/singularity/3.8.1/bin/singularity exec -B ${params.sam_folder}:/app/sam $workflow.projectDir/filt.sif python  /app/filt_discord_table_pct.py /app/sam/ /app/sam/*.sam -l 10
    """



    ///share/app/singularity/3.8.1/bin/singularity exec -B $HOME  ${params.image} python /app/occupancy_chip_wrapper.py -d ${params.data} -l ${lane} -o ${params.output} -s ${params.slide} -c ${params.start} -r ${params.range} -p ${params.platform}

    //"""
    //python /hwfssz8/MGI_CG_SZ/USER/huangsixing/nextflow/occupancy_analysis_chip_singu/test.py ${params.output}/${params.slide}/Lite/
    //"""

}

