import pyslow5
import os
import sys

log = open(snakemake.log[0], "w")
sys.stderr = log
sys.stdout = log

control_read_file = snakemake.input.control_read_file
native_read_file = snakemake.input.native_read_file
merge_blow5 = snakemake.input.merge_blow5

control_blow5_dir=snakemake.params.control_blow5_dir
native_blow5_dir=snakemake.params.native_blow5_dir

threads = snakemake.threads


def get_select_reads_from_blow5(merge_blow5,output,read_file,threads=threads):
    print(f'Extracting reads from {merge_blow5} using {read_file}')
    reads = [i.strip() for i in open(read_file)]
    slow5 = pyslow5.Open(merge_blow5, 'r')
    write_slow5 = pyslow5.Open(output, 'w')

    selected_reads = slow5.get_read_list_multi(reads, threads=threads)

    header_original = slow5.get_all_headers()
    header, end_reason_labels = slow5.get_empty_header(aux=True)

    new_end_reason_labels = ['unknown', 'partial', 'mux_change', 'unblock_mux_change',
                             'data_service_unblock_mux_change', 'signal_positive', 'signal_negative']

    for i in header_original:
        if i in header:
            if header_original[i] is None:
                continue
            else:
                header[i] = header_original[i]
    write_slow5.write_header(header,end_reason_labels=new_end_reason_labels)
    for read in selected_reads:
        if read is not None:
            record, aux = write_slow5.get_empty_record(aux=True)
            for i in read:
                if i in record:
                    record[i] = read[i]
                if i in aux:
                    aux[i] = read[i]
                # write the record
            write_slow5.write_record(record, aux)

    slow5.close()
    write_slow5.close()





os.makedirs(control_blow5_dir, exist_ok=True)
os.makedirs(native_blow5_dir, exist_ok=True)


get_select_reads_from_blow5(merge_blow5,snakemake.output.control_blow5,control_read_file)
get_select_reads_from_blow5(merge_blow5,snakemake.output.native_blow5,native_read_file)