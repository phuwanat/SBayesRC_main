version 1.0

workflow SBayesRC_main {

    meta {
        author: "Phuwanat"
        email: "phuwanat.sak@mahidol.edu"
        description: "SBayesRC Main"
    }

     input {
        File ld
        File annot
        Int memSizeGB = 96
        Int threadCount = 4
        Int diskSizeGB = 200
	    String out_prefix
    }

    call run_checking { 
			input: ld = ld, annot=annot, memSizeGB=memSizeGB, threadCount=threadCount, diskSizeGB=diskSizeGB, out_prefix=out_prefix
	}

    output {
        Array[File] out_files = run_checking.out_files
    }

}

task run_checking {
    input {
        File ld
        File annot
        Int memSizeGB
        Int threadCount
        Int diskSizeGB
	    String out_prefix
        String ld_name = basename(ld, ".tar.xz")
    }
    
    command <<<
    tar -xf ~{ld}
    Rscript -e "SBayesRC::sbayesrc(mafile='~{out_prefix}_imp.ma', LDdir='~{ld_name}/', outPrefix='~{out_prefix}_sbrc', annot='~{annot}', log2file=TRUE)"
    >>>

    output {
        Array[File] out_files = glob("*_sbrc*")
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "zhiliz/sbayesrc:0.2.6" 
        preemptible: 1
    }

}
