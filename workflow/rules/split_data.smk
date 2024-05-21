rule select_reads:
    input:
        control_bam = 'data/control.bam',
        control_bai = 'data/control.bam.bai',
        native_bam = 'data/native.bam',
        native_bai = 'data/native.bam.bai',
    output:
        outdir=directory('results/splited_data/'),
        tag = 'results/splited_data.tag'
        # read_name_files = expand('results/splited_data/{depth}_{ratio}_{replicate}/{condition}_reads.txt',
        #     depth=depths, ratio=ratios, replicate=replicates, condition=['control','native']),
    params:
        depths = depths,
        ratios = ratios,
        replicates = replicates,
    conda:
        '../envs/pysam.yaml'
    script:
        "../scripts/select_reads.py"

# rule select_blow5:
#     input:
