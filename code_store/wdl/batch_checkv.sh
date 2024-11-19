version 1.0

workflow CheckV_EndToEnd {
  input {
    Array[File] FASTA = ["/Files/ResultData/Notebook/hantao/marine/difference_compare_data/difference_base_sequence/in_all_vOTU_not_in_vOTU_LabGovImgvrBGI_name_fasta_to_8000/result/*"]
    Int threads = 16
    String checkv_db="/data2/checkv-db-v1.5"
    String prefix       = "default"
  }

  scatter (oneFile in FASTA) {
    call runCheckV {
      input:
        fasta_file = oneFile,
        threads = threads,
        checkv_db = checkv_db
    }
  }
  call tar {
    input:
      prefix  = prefix,
      foos    = runCheckV.checkv_output
  }
  
  output {
    File tar_result = tar.tar
  }
}
 
task runCheckV {
  input {
    File fasta_file
    Int threads
    String checkv_db
    String ID  = "${(basename(fasta_file, '.fasta')}"
  }
  command {
    checkv end_to_end -t ${threads} -d ${checkv_db} ${fasta_file} checkv_output_${ID}
    && tar -czf checkv_output${ID}.tar.gz checkv_output_${ID}
  }
  output {
    File checkv_output = "checkv_output${ID}.tar.gz"
  }

  runtime {
    docker: "public-library/limin5_48e6e2ac90bf4aca8b316b7c05436857_public:latest"
    cpu: 8
    memory: "32Gi"
  }
}

task tar
{
    input {
        String prefix
        Array[File] foos
    }
    
    command {
        tar -czf ${prefix}.tar.gz ${sep=" " foos}
    }
    
    output {
        File tar = "${prefix}.tar.gz"
    }
    runtime {
        docker_url: "stereonote_hpc/fangchao_7c7cccd13a7e4625a34c64fc253bff6a_private:latest"
        req_cpu: 1
        req_memory: "2Gi"
    }
}
