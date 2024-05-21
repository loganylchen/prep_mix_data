import glob
import pandas as pd
import sys
from snakemake.utils import validate
from snakemake.logging import logger



'''
SampleName Condition
sample1    Control
sample2    Native
'''
# samples = pd.read_csv(config['samples'], sep="\t", dtype={"SampleName": str}).set_index("SampleName", drop=False).sort_index()




replicates = range(int(config['test_times']))
depths = [int(i) for i in config['depths']]
ratios=[float(i) for i in config['ratios']]




def get_final_output():
    # final_output = expand('results/splited_data/{depth}_{ratio}_{replicate}/{condition}_reads.txt',
    #         depth=depths, ratio=ratios, replicate=replicates, condition=['control','native'])
    final_output = ['results/splited_data.tag']
    return final_output


