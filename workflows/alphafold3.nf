/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Loaded from modules/local/
//
include { FASTA_TO_ALPHAFOLD3_JSON } from '../modules/local/fasta_to_alphafold3_json'
include { RUN_ALPHAFOLD3 } from '../modules/local/run_alphafold3'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ALPHAFOLD3 {

    take:
    ch_samplesheet          // channel: samplesheet read in from --input
    ch_versions             // channel: [ path(versions.yml) ]
    // full_dbs                // boolean: Use full databases (otherwise reduced version)
    alphafold3_mode         //  string: Mode to run Alphafold2 in
    // alphafold2_model_preset //  string: Specifies the model preset to use for Alphafold2
    ch_alphafold3_params    // channel: path(alphafold2_params)
    // ch_bfd                  // channel: path(bfd)
    ch_small_bfd            // channel: path(small_bfd)
    ch_mgnify               // channel: path(mgnify)
    // ch_pdb70                // channel: path(pdb70)
    ch_pdb_mmcif            // channel: path(pdb_mmcif)
    // ch_uniref30             // channel: path(uniref30)
    ch_uniref90             // channel: path(uniref90)
    ch_pdb_seqres           // channel: path(pdb_seqres)
    ch_uniprot              // channel: path(uniprot)

    main:
    ch_multiqc_files  = Channel.empty()
    ch_pdb            = Channel.empty()
    ch_top_ranked_pdb = Channel.empty()
    ch_msa            = Channel.empty()
    ch_multiqc_report = Channel.empty()
    
    // if (alphafold2_model_preset != 'multimer') {
    //     ch_samplesheet
    //         .map {
    //             meta, fasta ->
    //             [ meta, fasta.splitFasta(file:true) ]
    //         }
    //         .transpose()
    //         .set { ch_samplesheet }
    // }
    ch_samplesheet.view()
    println "................test\n\n"
    FASTA_TO_ALPHAFOLD3_JSON(ch_samplesheet)
    ch_versions       = ch_versions.mix(FASTA_TO_ALPHAFOLD3_JSON.out.versions)

    if (alphafold3_mode == 'standard') {
        //
        // SUBWORKFLOW: Run Alphafold2 standard mode
        //
        RUN_ALPHAFOLD3 (
            FASTA_TO_ALPHAFOLD3_JSON.out.json,
            // full_dbs, // TODO remove now only small bfd is used
    //         alphafold2_model_preset,
            ch_alphafold3_params,
    //         ch_bfd,
            ch_small_bfd,
            ch_mgnify,
            // ch_pdb70,
            ch_pdb_mmcif,
    //         ch_uniref30,
            ch_uniref90,
            ch_pdb_seqres,
            ch_uniprot
        )

    //     RUN_ALPHAFOLD2
    //         .out
    //         .multiqc
    //         .map { it[1] }
    //         .toSortedList()
    //         .map { [ [ "model": "alphafold2" ], it.flatten() ] }
    //         .set { ch_multiqc_report }

    //     ch_pdb            = ch_pdb.mix(RUN_ALPHAFOLD2.out.pdb)
    //     ch_top_ranked_pdb = ch_top_ranked_pdb.mix(RUN_ALPHAFOLD2.out.top_ranked_pdb)
    //     ch_msa            = ch_msa.mix(RUN_ALPHAFOLD2.out.msa)
    //     ch_versions       = ch_versions.mix(RUN_ALPHAFOLD2.out.versions)

    }

    // ch_top_ranked_pdb
    //     .map { [ it[0]["id"], it[0], it[1] ] }
    //     .set { ch_top_ranked_pdb }

    // ch_pdb
    //     .join(ch_msa)
    //     .map {
    //         it[0]["model"] = "alphafold2"
    //         it
    //     }
    //     .set { ch_pdb_msa }

    // emit:
    // top_ranked_pdb = ch_top_ranked_pdb // channel: [ id, /path/to/*.pdb ]
    // pdb_msa        = ch_pdb_msa        // channel: [ meta, /path/to/*.pdb, /path/to/*_coverage.png ]
    // multiqc_report = ch_multiqc_report // channel: /path/to/multiqc_report.html
    // versions       = ch_versions       // channel: [ path(versions.yml) ]
    
    emit:
    top_ranked_pdb = [] // channel: [ id, /path/to/*.pdb ]
    pdb_msa        = []      // channel: [ meta, /path/to/*.pdb, /path/to/*_coverage.png ]
    multiqc_report = [] // channel: /path/to/multiqc_report.html
    versions       = []      // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
