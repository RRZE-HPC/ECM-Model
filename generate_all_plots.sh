#kernels="load load2 load4 init init2 init4 copy daxpy stream triad"

#kernels=$(ls ../size_scan)
folder=$1
cd ${folder}
kernels=$(ls *.txt)
cd -
for kernel in ${kernels}; do
    kernel_name_tmp=$(basename "${kernel}" ".txt")
    kernel_name=$(basename "${kernel_name_tmp}" ".config")
    echo "check $kernel_name"
#    cd ecm_generator
#    ./ecm.sh ${kernel_name}
#    cd -
    ./generate_plot.sh ${kernel_name} ${folder}
done

cd ${folder}/plots
rm -rf ecm.pdf
pdfunite *.pdf ecm.pdf
cd -
