process COMPARE_STRUCTURES {
    tag   "$meta.id-$meta.model"
    label 'process_single'

    conda "bioconda::multiqc:1.21"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/pip_biopython_matplotlib_plotly:e865101a15ad0014' :
        'community.wave.seqera.io/library/pip_biopython_matplotlib_plotly:4d51afeb4bb75495' }"

    input:
    tuple val(meta), path(pdb)
    tuple val(meta_msa), path(msa)
    tuple val(meta_plddt), path(plddt)
    path(template)

    output:
    tuple val(meta), path ("*report.html"), emit: report
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    generate_comparison_report.py --type ${output_type} \\
        --msa ${msa.join(' ')} \\
        --pdb ${pdb.join(' ')} \\
        --html_template ${template} \\
        --output_dir ./ \\
        --name ${meta.id} \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
        generate_comparison_report.py: \$(python3 --version)
    END_VERSIONS
    """

    stub:
    """
    touch test_alphafold2_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
        generate_comparison_report.py: \$(python3 --version)
    END_VERSIONS
    """
}
