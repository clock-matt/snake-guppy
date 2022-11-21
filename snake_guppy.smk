configfile: "g-test.yaml"

def get_read_directory(wildcards):
    return config["samples"][wildcards.sample]

rule all:
    input:
        DSSinput=expand("DSSinput/{sample}.dss", sample=config["samples"]),
        tldrinput=expand("tldr/bams/{sample}_sorted_mappings.bam.bai", sample=config["samples"])

rule fast2pod:
    input:
        fast5_dir = get_read_directory
    output:
        pod5 = directory("pod5s/{sample}/")
    log:
        "logs/fast2pod/{sample}.log"
    benchmark:
        "benchmarks/fast2pod/{sample}.txt"
    conda: "pod5"
    threads: 8
    shell:
        "(pod5-convert-from-fast5 -r --force-overwrite {input.fast5_dir}/ {output.pod5}/) >{log} 2>&1"

rule run_guppy:
    input:
        pod5s = "pod5s/{sample}/"
    output:
        guppy_out_bam = "guppy_out/{sample}.bam",
        guppy_out_bam_index = "guppy_out/{sample}.bam.bai"
    params:
        guppy_bin = "ont-guppy/bin",
        guppy_config = "",
        reference = ""
    shell:
       "{params.guppy_bin}/./guppy_basecaller -i {input.pod5s} -s {output.save_path} "
       "-c {params.guppy_config} -x auto --verbose_logs --recursive"
        