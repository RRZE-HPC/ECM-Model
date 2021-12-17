#!/bin/sh

#Usage ./bench_scan_size.sh <config_file>

#benches="load_avx512 load copy_avx512 copy_mem_avx512 copy daxpy_avx512_fma stream_avx512_fma stream_mem_avx512 triad_avx512_fma triad_mem_avx512_fma update_avx512"
benches=`cat $1 | grep BENCHES | cut -d "=" -f 2-`
postfix=`cat $1 | grep POSTFIX | cut -d "=" -f 2-`
# bytes="8 8 24 16 24 24 32 24 40 32 16"
folder=`cat $1 | grep FOLDER | cut -d "=" -f 2-`
rawFolder="${folder}/raw"
clock=`cat $1 | grep CLOCK | cut -d "=" -f 2-`
tmpFile="${folder}/tmp.txt"
endSize=`cat $1 | grep END_SIZE | cut -d "=" -f 2-`

#TODO check freq also in check-state
./check-state.sh $1
mc_state=$(echo $?)

if [[ ${mc_state} == 1 ]]; then
    echo "Hardware not configured properly"
    exit 1
fi

mkdir -p ${rawFolder}
#store machine config
./machine-state.sh > "${rawFolder}/mc-state.txt"
for bench in $benches; do
    benchName="${bench}${postfix}"
    outFile="${folder}/${benchName}.txt"
    rawFile="${rawFolder}/${benchName}.txt"
    printf "%10s, %14s, %16s, %16s, %16s, %16s\n" "Size(KB)" "Bw(MB/s)" "nominal_clock" "actual_clock" "cy_nominal/LUP" "cy/LUP" > ${outFile}
    size=5
    while [[ ${size} -lt ${endSize} ]]; do
        likwid-bench -t ${benchName} -w S0:${size}kB:1:1:2 2 > ${tmpFile}
        cat ${tmpFile} >> ${rawFile}
        bw=$(cat ${tmpFile} | grep "MByte/s:" | cut -d":" -f2)
        nominalClock_hz=$(cat ${tmpFile} | grep "CPU Clock:" | cut -d":" -f2)
        nominalClock=$(echo "${nominalClock_hz}*0.000000001" | bc -l)
        cy_nominal=$(cat ${tmpFile} | grep "Cycles per update:" | cut -d":" -f2) #this is at nominal clock
        cy=$(echo "${cy_nominal}*${clock}/${nominalClock}" | bc -l)
        printf "%10d, %14.4f, %16.8f, %16.8f, %16.8f, %16.8f\n" ${size} ${bw} ${nominalClock} ${clock} ${cy_nominal} ${cy} >> ${outFile}
        size_float=$(echo "${size}*1.2" | bc -l)
        size=$(printf "%.0f" ${size_float})

        #monitor with LIKWID too
    done
done

rm -rf ${tmpFile}

cd ${folder}
tar -czvf raw.tar.gz raw
rm -rf raw
cd -
