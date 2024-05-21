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



test_times = int(config['test_times'])
iter_n = range(test_times)

test_depth = [int(i) for i in config['depth']]


def get_output_list_for_one_sample():
    [f'results/depth_{depth}/data/control.{i}/fastq/pass.fq.gz' for depth in test_depth for i in iter_n]

    return [
        # f"data/{sample}/fastq/pass.fq.gz",
        # f"data/{sample}/blow5/nanopore.blow5",
    ]

def get_final_output():
    final_output = []
    for sample in samples.keys():
        final_output += get_output_list_for_one_sample(sample)
    return final_output


