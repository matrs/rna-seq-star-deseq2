def get_fastq(wildcards):
    return units.loc[(wildcards.sample, wildcards.unit), ["fq1", "fq2"]].dropna()

rule bbduk_trim_pe:
    input:
        get_fastq
    output:
        fastq1="trimmed/{sample}-{unit}.1.fastq.gz",
        fastq2="trimmed/{sample}-{unit}.2.fastq.gz",
        #stats="log/bbduk/{sample}-{unit}.stats"
        stats="trimmed/{sample}-{unit}.qc.txt"
    params:
        ref= config["adapter"],
        extra="tpe tbo",
        memory="-Xmx5g"
    log:
        "logs/bbduk/{sample}-{unit}.log" 
    #Aparently pigz causes crashes - related to threads, better to disable it
    threads:
        4
    shell:
        "bbduk.sh {params.memory} {input} out1={output.fastq1} out2={output.fastq2} ref={params.ref} "
        "stats={output.stats} ktrim=r k=23 mink=11 hdist=1 {params.extra} t={threads} " 
        "--overwrite pigz=f unpigz=f 2> {log}"
