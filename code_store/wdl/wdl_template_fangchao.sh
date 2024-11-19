version 1.0

workflow iphop_predict
{
  input {
    Array[File] FAs     = [
        "/Files/ReferenceData/iphop/test/test_input_phages.fna",
        "/Files/ReferenceData/iphop/test/demo_input_phages.fna.gz"]
    String iphop_db_dir = "/hwfssz5/ST_HEALTH/P20Z10200N0206/share/public_database/iphop/Test_db_rw/"
    String prefix       = "default"
    String options      = " "
    Int num_threads     = 8
    Int Gi_memories     = 16  
  }
  
  scatter (FA in FAs)
  {
    call iphop
    {
      input:
        Seqfile      = FA,
        db_dir       = iphop_db_dir,
        options      = options,
        num_threads  = num_threads,
        memory       = Gi_memories
    }
  }

  call tar {
    input:
      prefix  = prefix,
      foos    = iphop.outtar
  }
  
  
  output {
    File tar_result = tar.tar
  }
}

task iphop {
    input {
        File Seqfile
        String db_dir
        String options
        Int num_threads
        Int memory
        String ID  = "${basename(basename(basename(basename(Seqfile, '.gz'), '.fasta'), '.fa'), '.fna')}"
    }
    command {
        # if Seqfile end with .gz, then decompress it
        bash -c "
          if [[ ${Seqfile} == *.gz ]]; then
            gunzip -c ${Seqfile} > ${ID}.fna
          else
            ln -s ${Seqfile} ${ID}.fna
          fi
        "

        ln -s ${db_dir} iphop_db_rw

        micromamba run -n iphop iphop predict \
          --fa_file ${ID}.fna \
          --db_dir iphop_db_rw \
          --out_dir iphop_${ID} \
          --num_threads ${num_threads} ${options} \
        && tar -czf iphop_${ID}.tar.gz iphop_${ID} 
    }
    output {
      File outtar = "iphop_${ID}.tar.gz"
    }

    runtime {
        docker_url: "stereonote_hpc/fangchao_7c7cccd13a7e4625a34c64fc253bff6a_private:latest"
        req_cpu: num_threads
        req_memory: "~{memory}Gi"
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