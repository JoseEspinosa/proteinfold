//
// Download with aria2 and uncompress the data if needed
//
include { UNTAR           } from '../../modules/nf-core/untar/main'
include { GUNZIP          } from '../../modules/nf-core/gunzip/main'
include { ARIA2           } from '../../modules/nf-core/aria2/main'
include { ZSTD_DECOMPRESS } from '../../modules/local/zstd_decompress/main.nf'

workflow ARIA2_UNCOMPRESS {
    take:
    source_url // url

    main:
    ARIA2 (
        [
            [:],
            source_url
        ]
    )
    ch_db = Channel.empty()

    if (source_url.toString().endsWith('.tar') || source_url.toString().endsWith('.tar.gz') || source_url.toString().endsWith('.tar.zst')) {
        ch_db = UNTAR (ARIA2.out.downloaded_file).untar.map{ it[1] }
    } else if (source_url.toString().endsWith('.gz')) {
        ch_db = GUNZIP (ARIA2.out.downloaded_file).gunzip.map { it[1] }
    } else if (source_url.toString().endsWith('.zst')) {
        ch_db = ZSTD_DECOMPRESS (ARIA2.out.downloaded_file).decompressed.map { it[1] }
    }

    emit:
    db       = ch_db              // channel: [ db ]
    versions = ARIA2.out.versions // channel: [ versions.yml ]
}

