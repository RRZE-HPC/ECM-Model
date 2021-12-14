#!/bin/bash

#USAGE: ./generate_all_plots.sh ${folder_with_Results} ${mcName}

#kernels="load load2 load4 init init2 init4 copy daxpy stream triad"
#kernels=$(ls ../size_scan)

folder=$1
mc_name=$2
cd ${folder}
kernels=$(ls *.txt)
cd -
for kernel in ${kernels}; do
    kernel_name_tmp=$(basename "${kernel}" ".txt")
    kernel_name=$(basename "${kernel_name_tmp}" ".config")
    kernel_wo_simdType=$(echo ${kernel_name%%_*})
    curPath=${PWD}
    echo "check $kernel_name"
    cd ecm_generator
    ./ecm.sh "application_model/${kernel_wo_simdType}.config" "machine_model/${mc_name}.config" > ${curPath}/ecm_tmp.tmp
    cd -
    ./generate_plot.sh ${kernel_name} ${folder}
    rm -f ${curPath}/ecm_tmp.tmp
done

cd ${folder}/plots
rm -rf ecm.pdf
pdfunite *.pdf ecm.pdf
cd -
