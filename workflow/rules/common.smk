import glob
import pandas as pd
import sys
from snakemake.utils import validate
from snakemake.logging import logger






replicates = range(int(config['test_times']))
depths = [int(i) for i in config['depths']]
ratios=[float(i) for i in config['ratios']]




def get_final_output():
    final_output = ['results/splited_data/read_type.tsv']
    final_output += expand('results/splited_data/{depth}/{ratio}_{replicate}/{condition}_reads.txt',
            depth=depths, ratio=ratios, replicate=replicates, condition=['control','native'])
    final_output += expand('results/splited_data/{depth}/{ratio}/data/control_{replicate}/blow5/nanopore.blow5',
            depth=depths, ratio=ratios, replicate=replicates)
    final_output += expand('results/splited_data/{depth}/{ratio}/data/control_{replicate}/fastq/pass.fq.gz',
            depth=depths, ratio=ratios, replicate=replicates)
    # final_output = ['results/splited_data.tag']
    return final_output


