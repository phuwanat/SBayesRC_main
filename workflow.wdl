version 1.0

workflow SBayesRC_main {

    meta {
        author: "Phuwanat"
        email: "phuwanat.sak@mahidol.edu"
        description: "SBayesRC Main"
    }

     input {
        File ld
        File ma
        File annot
        Int memSizeGB = 96
        Int threadCount = 16
        Int diskSizeGB = 2000
	    String out_prefix
    }

    call run_checking { 
			input: ld = ld, ma=ma, annot=annot, memSizeGB=memSizeGB, threadCount=threadCount, diskSizeGB=diskSizeGB, out_prefix=out_prefix
	}

    output {
        Array[File] out_files = run_checking.out_files
    }

}

task run_checking {
    input {
        File ld
        File annot
        File ma
        Int memSizeGB
        Int threadCount
        Int diskSizeGB
	    String out_prefix
        String ld_name = basename(ld, ".tar.xz")
        String annot_name = basename(annot, ".zip")
    }
    
    command <<<
    export OMP_NUM_THREADS=~{threadCount}
    mkdir /cromwell_root/ref
    echo "start"
    tar -xf ~{ld} -C /cromwell_root/ref/
    echo "tar finished"
    unzip ~{annot} -d /cromwell_root/ref/
    echo "unzip finished"
    Rscript -e "SBayesRC::sbayesrc(mafile='~{ma}', LDdir='/cromwell_root/ref/~{ld_name}/', outPrefix='~{out_prefix}_sbrc', annot='/cromwell_root/ref/~{annot_name}.txt', log2file=TRUE)"
    >>>

    output {
        Array[File] out_files = glob("*_sbrc*")
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " HDD"
        docker: "phuwanat/sbayesrcmain:v1"  #"zhiliz/sbayesrc:0.2.6"
        preemptible: 1
    }

}
