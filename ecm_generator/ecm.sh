#!/bin/bash

#ECM generation script
#Usage: ./ecm.sh "application model" "machine model"

kernel="$1"
machine="$2"

function readFromFile() {
    string=$1
    file=$2
    retVal=0
    val=$(grep "${string} =" ${file} | cut -d"=" -f2)
    if [ ! -z "$val" ]; then
        retVal=$(echo ${val})
    fi
    echo ${retVal}
}

rd=$(readFromFile "Read-only" "${kernel}")
wr=$(readFromFile "Write-only" "${kernel}")
rd_wr=$(readFromFile "Read-Write" "${kernel}")


#output in cy/CL
function getCycles() {
    cache=$1
    #get machine bandwidth for the cache
    read_bw=$(readFromFile "${cache}_read_bw" "${machine}")
    write_bw=$(readFromFile "${cache}_write_bw" "${machine}")
    shared_bw=$(readFromFile "${cache}_shared_bw" "${machine}")
    wa=$(readFromFile "${cache}_WA" "${machine}")
    cl_size=$(readFromFile "CL_size" "${machine}")
    victim=$(readFromFile "${cache}_VICTIM" "${machine}")

    read_cy=0
    write_cy=0
    shared_cy=0
    #convert to cy
    if [[ ${victim} == 0 ]]; then
        read_cy=$(echo "(${rd}+${rd_wr}+(${wr}*${wa}))*${cl_size}/${read_bw}" | bc -l)
        write_cy=$(echo "(${wr}+${rd_wr})*${cl_size}/${write_bw}" | bc -l)
        if [[ ${shared_bw} != 0 ]]; then
            shared_cy=$(echo "(${rd}+${wr}+2*${rd_wr})*${cl_size}/${shared_bw}" | bc -l)
        fi
    else
        read_cy=0
        write_cy=$(echo "(${rd}+${wr}+${rd_wr})*${cl_size}/${write_bw}" | bc -l)
        if [[ ${shared_bw} != 0 ]]; then
            shared_cy=$(echo "(${rd}+${wr}+2*${rd_wr})*${cl_size}/${shared_bw}" | bc -l)
        fi
    fi

    #AGU cycle will be 0 for all but cache, except L1 if provided limit
    echo "${read_cy},${write_cy},${shared_cy}"
}

function replaceStr() {
    str=$1
    src_str=$2
    dest_str=$3

    retStr=$(echo ${str} | sed -e "s@${src_str}@${dest_str}@g")
    echo "${retStr}"
}

function evalECM() {
    rd_wr_cy_arr=("$@")
    #echo ${rd_wr_cy_arr}
    ecmHypothesis=$(readFromFile "ECM_hypothesis" "${machine}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L1_read_cy" "${rd_wr_cy_arr[0]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L1_write_cy" "${rd_wr_cy_arr[1]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L1_shared_cy" "${rd_wr_cy_arr[2]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L2_read_cy" "${rd_wr_cy_arr[3]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L2_write_cy" "${rd_wr_cy_arr[4]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L2_shared_cy" "${rd_wr_cy_arr[5]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L3_read_cy" "${rd_wr_cy_arr[6]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L3_write_cy" "${rd_wr_cy_arr[7]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "L3_shared_cy" "${rd_wr_cy_arr[8]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "MEM_read_cy" "${rd_wr_cy_arr[9]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "MEM_write_cy" "${rd_wr_cy_arr[10]}")
    ecmHypothesis=$(replaceStr "${ecmHypothesis}" "MEM_shared_cy" "${rd_wr_cy_arr[11]}")
    echo "${ecmHypothesis}" | bc max.bc -l
}

L1_read_cy=$(getCycles "L1" | cut -d"," -f1)
L1_write_cy=$(getCycles "L1" | cut -d"," -f2)
L1_shared_cy=$(getCycles "L1" | cut -d"," -f3)

L2_read_cy=$(getCycles "L2" | cut -d"," -f1)
L2_write_cy=$(getCycles "L2" | cut -d"," -f2)
L2_shared_cy=$(getCycles "L2" | cut -d"," -f3)

L3_read_cy=$(getCycles "L3" | cut -d"," -f1)
L3_write_cy=$(getCycles "L3" | cut -d"," -f2)
L3_shared_cy=$(getCycles "L3" | cut -d"," -f3)

MEM_read_cy=$(getCycles "MEM" | cut -d"," -f1)
MEM_write_cy=$(getCycles "MEM" | cut -d"," -f2)
MEM_shared_cy=$(getCycles "MEM" | cut -d"," -f3)

#print ECM results
#set current array
rd_wr_arr=(0 0 0 0 0 0 0 0 0 0 0 0)
idx=0
prevSize=0
hierarchies="L1 L2 L3 MEM"
for cache in ${hierarchies}; do
    cur_read="${cache}_read_cy"
    read_cy=${!cur_read}

    cur_write="${cache}_write_cy"
    write_cy=${!cur_write}

    cur_shared="${cache}_shared_cy"
    shared_cy=${!cur_shared}

    victim=$(readFromFile "${cache}_VICTIM" "${machine}")
    #if data fits in L3 cache and its victim
    if [[ ${victim} == 1 ]]; then
        if [[ ${read_cy} != 0 ]]; then
            echo "ecm.sh: Error with victim cache handling"
        fi
        read_cy=${write_cy}
    fi

    rd_wr_arr[$idx]=${read_cy}
    let idx=$idx+1
    rd_wr_arr[$idx]=${write_cy}
    let idx=$idx+1
    rd_wr_arr[$idx]=${shared_cy}
    let idx=$idx+1

    # evalECM "${rd_wr_arr[@]}"
    curECM=$(evalECM "${rd_wr_arr[@]}")
    size=$(readFromFile "${cache}_size" "${machine}")

    echo $((prevSize+1)), ${curECM}
    echo ${size}, ${curECM}

    prevSize=${size}
done

