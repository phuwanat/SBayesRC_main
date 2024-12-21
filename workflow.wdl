version 1.0

workflow SBayesRC_main {

    meta {
	author: "Phuwanat"
        email: "phuwanat.sak@mahidol.edu"
        description: "SBayesRC Main"
    }

     input {
        Directory ld_folder
        File annot
        Int memSizeGB = 96
        Int threadCount = 4
        Int diskSizeGB = 200
	    String out_prefix
    }

    call run_checking { 
			input: ld_folder = ld_folder, annot=annot, memSizeGB=memSizeGB, threadCount=threadCount, diskSizeGB=diskSizeGB, out_prefix=out_prefix
	}

    output {
        Array[File] out_files = run_checking.out_files
    }

}

task run_checking {
    input {
        Directory ld_folder
        File annot
        Int memSizeGB
        Int threadCount
        Int diskSizeGB
	    String out_prefix
    }
    
    command <<<
    Rscript -e "SBayesRC::sbayesrc(mafile='~{out_prefix}_imp.ma', LDdir='~{ld_folder}', outPrefix='~{out_prefix}_sbrc', annot='~{annot}', log2file=TRUE)"
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