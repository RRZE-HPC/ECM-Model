kernel=$1
folder=$2
#cd ../ecm_generator
#./ecm_mem_r_no_op.sh ${kernel}
#./ecm.sh ${kernel}
#cd -
outFolder="${folder}/plots"
mkdir -p ${outFolder}
outFile="${outFolder}/${kernel}.tex"
cp template.tex "tmp.tex"
sed -e "s#@kernel@#${kernel}#g" "tmp.tex" > "tmp_tmp.tex"
kernel_title=$(echo ${kernel} | sed -e "s#_#-#g")
sed -e "s#@title@#${kernel_title}#g" "tmp_tmp.tex" > "${outFile}"
rm -rf "tmp.tex"
rm -rf "tmp_tmp.tex"
mv ecm_tmp.tmp ${outFolder}/.
cd ${outFolder}
pdflatex "${kernel}.tex"
rm -rf *.aux *.log *.synctex.gz
cd -
