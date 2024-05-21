rule select_reads:
    input:
        control_bam = 'data/control.bam',
        control_bai = 'data/control.bam.bai',
        native_bam = 'data/native.bam',
        native_bai = 'data/native.bam.bai',
    output:
        control_read_file = 'results/splited_data/{depth}/{ratio}_{replicate}/control_reads.txt',
        native_read_file = 'results/splited_data/{depth}/{ratio}_{replicate}/native_reads.txt',
    conda:
        '../envs/pysam.yaml'
    script:
        "../scripts/select_reads.py"

# rule select_blow5:
#     input:
#         tag = 'results/splited_data.tag'
#     output:
#         tag = 'results/splited_data.tag'