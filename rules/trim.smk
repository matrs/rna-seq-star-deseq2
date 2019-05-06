def get_fastq(wildcards):
    return units.loc[(wildcards.sample, wildcards.unit), ["fq1", "fq2"]].dropna()

#ruleorder: cutadapt > cutadapt_pe
#rule cutadapt_pe:
#    input:
#        get_fastq
#    output:
#        fastq1="trimmed/{sample}-{unit}.1.fastq.gz",
#        fastq2="trimmed/{sample}-{unit}.2.fastq.gz",
#        qc="trimmed/{sample}-{unit}.qc.txt"
#    params:
#        "-a {} {}".format(config["adapter"], config["params"]["cutadapt-pe"])
#    log:
#        "logs/cutadapt/{sample}-{unit}.log"
#    wrapper:
#        "file:snakemake-wrappers/bio/cutadapt/pe"

rule bbduk_trim_pe:
    input:
        get_fastq 
    output:
        fastq1="trimmed-bbduk/{sample}-{unit}.1.fastq.gz",
        fastq2="trimmed-bbduk/{sample}-{unit}.2.fastq.gz",
        #stats="log/bbduk/{sample}-{unit}.stats"
        stats="trimmed/{sample}-{unit}.qc.txt"
    params:
        ref="{adapters}",
        extra="tpe tbo"
    shell:
        "bbdusk.sh {input} out1={output.fastq1} out1={output.fastq2} ref={params.ref}"
        "stats={output.stats}"
        "ktrim=r k=23 mink=11 hdist=1 {params.extra}"

#rule cutadapt:
#    input:
#        get_fastq
#    output:
#        fastq="trimmed/{sample}-{unit}.fastq.gz",
#        qc="trimmed/{sample}-{unit}.qc.txt"
#    params:
#        "-a {} {}".format(config["adapter"], config["params"]["cutadapt-se"])
#    log:
#        "logs/cutadapt/{sample}-{unit}_se.log"
#    wrapper:
#        "file:snakemake-wrappers/bio/cutadapt/se"
