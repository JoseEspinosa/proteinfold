process MMSEQS_TSV2EXPROFILEDB {
    tag "$db"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://athbaltzis/mmseqs_proteinfold:v0.1' :
        'athbaltzis/mmseqs_proteinfold:v0.1' }"

    input:
    path db

    output:
    path(db), emit: db_exprofile

    script:
    def args = task.ext.args ?: ''
    """
    cd ${db}
    mmseqs tsv2exprofiledb \\
        "${db}" \\
        "${db}_db"
    """

    stub:
    """
    touch ${db}/${db}_exprofile
    """
}