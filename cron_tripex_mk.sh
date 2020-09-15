#!/bin/bash
#Markus: modified script for running pamtra on sensitivity experiments

source /home/dori/.bashrc
export OPENBLAS_NUM_THREADS=1

NP=4

ICON_PATH=/data/optimice/ICON_output/ #/data/inscape/icon/experiments/juelich/testbed/testbed_
ROOT_PATH=/home/mkarrer/Dokumente/Doripamtra_ICON/tripex-pol_NEWprop/
DATA_PATH=${ROOT_PATH}data/
PLOT_PATH=${ROOT_PATH}plots/
CODE_PATH=/home/mkarrer/Dokumente/pamtra-icon/

declare -a hydro_combo=("all_hydro")
declare -a radar_names=("Joyrad10" "Joyrad35" "Grarad94")
#declare -a radar_names=("Joyrad10")

newdata=0
newpassive=0
for DAY in '20181124' '20190130' '20190210' # 2 3 4 5 .. N
#for DAY in '20181110' 
do 
for EXPERIMENT in "default" "colMix2_Akernel" "colMix2_Dkernel" "colMix2_Akernel_qnssub"
#for EXPERIMENT in "colMix2_Dkernel" "needMix2_Akernel" "colMix2_Akernel_LinCot" "colMix2narrow_Akernel" "colMix2_Akernel_qnssub" "colbroadMix2_Akernel" "colMix2broad_Akernel" #"default" "colMix2_Akernel" 
do
        #select descriptor file base on experiment name
        if [ $EXPERIMENT == "default" ]; then
            dfSetup='SB062mom'
        elif [[ $EXPERIMENT == "colMix2narrow"* ]]; then
            dfSetup='SB062momColMix2narrow'
        elif [[ $EXPERIMENT == "colMix2broad"* ]]; then
            dfSetup='SB062momColMix2broad'
        elif [[ $EXPERIMENT == "colbroadMix2"* ]]; then
            dfSetup='SB062momColbroadMix2'
        elif [[ $EXPERIMENT == "colMix2"* ]]; then
            dfSetup='SB062momColMix2'
        elif [[ $EXPERIMENT == "needMix2"* ]]; then
            dfSetup='SB062momNeedMix2'
        else
            echo "no descriptor file found for " $EXPERIMENT  
        fi
        echo ${ICON_PATH}${DAY}_110km_${EXPERIMENT}

	# Check if there is ICON output
	ICON_file=${ICON_PATH}${DAY}_110km_${EXPERIMENT}/METEOGRAM_patch001_joyce.nc
	if [ -f ${ICON_file} ]; then
		echo ${DAY}
		passiveFile=${DATA_PATH}${DAY}hatpro.nc
		plotFile=${PLOT_PATH}${DAY}hatpro.png
		#if [ -f $passiveFile ]; then
		#	echo "passive "${DAY}" already done"
		#else
	        #	python3 ${CODE_PATH}run_pamtra.py -i ${ICON_file} -sp ${passiveFile} -hy all_hydro -r hatpro -np ${NP} > ${CODE_PATH}pamtra${DAY}_hatpro.out
		#	newpassive=1
		#fi
		#if [ "$newpassive" -eq "1" ]; then
		#	python ${CODE_PATH}plot_hatpro.py -s ${plotFile} -p ${passiveFile} -i ${ICON_file}
		#fi
		for hydro in "${hydro_combo[@]}"; do
			mkdir -p ${DATA_PATH}/${hydro}
			mkdir -p ${PLOT_PATH}/${hydro}
			for radar in "${radar_names[@]}"; do
				radarFile=${DATA_PATH}${hydro}/${DAY}${hydro}_mom_${radar}_${EXPERIMENT}.nc
				#if [ -f ${radarFile}  ]; then
				#	echo "Already processed " ${DAY} ${hydro} ${radar}
				#else
					echo "Running "${DAY} ${hydro} ${radar}
					python3 ${CODE_PATH}run_pamtra.py -i ${ICON_file} -sp ${radarFile} -df ${dfSetup} -hy ${hydro} -r ${radar} -np ${NP} > ${CODE_PATH}pamtra${DAY}_${hydro}_${radar}.out
					newdata=1
				#fi
			done
			if [ "$newdata" -eq "1" ]; then
				plotFile=${PLOT_PATH}/${hydro}/${DAY}${hydro}${EXPERIMENT} # plotfilename is completed by the python script, several plots are done
				echo "Newdata ... plotting"
				radarX=${DATA_PATH}${hydro}/${DAY}${hydro}_mom_Joyrad10_${EXPERIMENT}.nc
				radarK=${DATA_PATH}${hydro}/${DAY}${hydro}_mom_Joyrad35_${EXPERIMENT}.nc
				radarW=${DATA_PATH}${hydro}/${DAY}${hydro}_mom_Grarad94_${EXPERIMENT}.nc
				python ${CODE_PATH}plot_tripex_radars.py -s ${plotFile} -rx ${radarX} -rk ${radarK} -rw ${radarW}
				newdata=0
			fi
		done
	else
		echo "no ICON data for "${DAY}
	fi
done #experiment
done #day
