#!/bin/bash

#USAGE: ./generate_all_plots.sh ${folder_with_Results} ${mc_file}

#kernels="load load2 load4 init init2 init4 copy daxpy stream triad"
#kernels=$(ls ../size_scan)

folder=$1
mc_file=$2
cd ${folder}
kernels=$(ls *.txt)
cd -
for kernel in ${kernels}; do
    kernel_name_tmp=$(basename "${kernel}" ".txt")
    kernel_name=$(basename "${kernel_name_tmp}" ".config")
    kernel_wo_simdType=$(echo ${kernel_name%%_*})
    curPath=${PWD}
    template="template_wo_ecm.tex"
    echo "generating plots for $kernel_name"
    fullPath_mcFile=$(realpath "${mc_file}")
    if [[ ${mc_file} != -1 ]]; then
        cd ecm_generator
        ./ecm.sh "application_model/${kernel_wo_simdType}.config" "${fullPath_mcFile}" > ${curPath}/ecm_tmp.tmp
        cd -
        template="template_w_ecm.tex"
    fi
    echo $template
    ./generate_plot.sh ${kernel_name} ${folder} ${template}
    rm -f ${curPath}/ecm_tmp.tmp
done

cd ${folder}/plots
rm -rf ecm.pdf
pdfunite *.pdf ecm.pdf
cd -
