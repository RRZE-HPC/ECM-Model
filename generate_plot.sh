kernel=$1
folder=$2
#cd ../ecm_generator
#./ecm_mem_r_no_op.sh ${kernel}
#./ecm.sh ${kernel}
#cd -
outFolder="${folder}/plots"
mkdir -p ${outFolder}
outFile="${outFolder}/${kernel}.tex"
cp template.tex "tmp_${kernel}.tex"
sed -e "s#@kernel@#${kernel}#g" "tmp_${kernel}.tex" > "tmp_tmp${kernel}.tex"
kernel_title=$(echo ${kernel} | sed -e "s#_#-#g")
sed -e "s#@title@#${kernel_title}#g" "tmp_tmp${kernel}.tex" > "${outFile}"
rm -rf "tmp_${kernel}.tex"
rm -rf "tmp_tmp_${kernel}.tex"
cd ${outFolder}
pdflatex "${kernel}.tex"
rm -rf *.aux *.log *.synctex.gz
cd -
