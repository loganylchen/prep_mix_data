import pysam
import os
import json




control_bam = snakemake.input.control_bam
native_bam = snakemake.input.native_bam
all_reads_file = snakemake.input.all_reads

output = snakemake.output.read_type

with open(all_reads_file, 'r') as f:
    all_reads = [read.strip() for read in f]





def extract_reads(control_bam_file, native_bam_file):
    reads_dict= dict
    with pysam.AlignmentFile(control_bam_file, "rb") as control_bam, pysam.AlignmentFile(native_bam_file, "rb") as native_bam:
        transcripts = set(control_bam.references).intersection(set(native_bam.references))
        for transcript in transcripts:
            control_reads = list({read.query_name for read in control_bam.fetch(transcript)}.intersection(all_reads))
            native_reads = list({read.query_name for read in native_bam.fetch(transcript)}.intersection(all_reads))
            for read in control_reads:
                reads_dict[read] = 'control'
            for read in native_reads:
                reads_dict[read] = 'native'
    return reads_dict


os.makedirs(os.path.dirname(output), exist_ok=True)

reads_dict = extract_reads(control_bam, native_bam)

with open(output, 'w') as f:
    json.dump(reads_dict, f, indent=4)

