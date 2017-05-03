#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          pyRAD2PartitionFinder v1.0, May 2017                          #
#   SHELL SCRIPT FOR RUNNING PartitionFinder ON SNP DNA PARTITIONS OUTPUT FROM pyRAD     #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: May 3, 2017.  #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

echo "
##########################################################################################
#                          pyRAD2PartitionFinder v1.0, May 2017                          #
##########################################################################################"

############ STEP #1: MODIFY pyRAD DATAFILE FOR PartitionFinder
MY_PYRAD_PARTITION=./*.partitions           				## Assign "partition" files in current directory to variable.
MY_PHYLIP_FILE=./*.phy                      				## Assign PHYLIP SNP datafiles in current directory to variable.

###### FORMAT pyRAD PARTITION FILE FOR PartitionFinder: 
(
	for i in $MY_PYRAD_PARTITION; do               					## Look in the current directory for partition scheme files output by pyRAD.
		echo $i
		sed 's/^DNA..//g' ${i} > ${i}_1.tmp					## Reformatting using nested for loops.
			for j in ${i}_1.tmp; do
				echo $j
				sed 's/$/;/' ${j} > ${j}.PFparts.txt 
			done
		for k in *.partitions_1.tmp.PFparts.txt; do
			mv $k ${k/.partitions_1.tmp.PFparts.txt/.newPartitions.txt}
		done						## Line above renames the output.
	done
)
	rm ./*_1.tmp	## Remove unnecessary files.


############ STEP #2: PREPARE PartitionFinder CONFIGURATION FILE
MY_PHYLIP_FILENAME="$(echo ./*.phy | sed -n 's/.\///p')"	## Get name of PHYLIP file with our data. Assumes only one PHYLIP file in working directory corresponding to pyRAD output of SNP/RAD assembly in phylip format.

echo "## ALIGNMENT FILE ##
	alignment = $MY_PHYLIP_FILENAME;

	## BRANCHLENGTHS: linked | unlinked ##
	branchlengths = linked;

	## MODELS OF EVOLUTION for PartitionFinder: all | raxml | mrbayes | beast | <list> ##
	##              for PartitionFinderProtein: all_protein | <list> ##
	models = all;

	# MODEL SELECCTION: AIC | AICc | BIC #
	model_selection = BIC;

	## DATA BLOCKS: see manual for how to define ##
	[data_blocks]" > PF_top.tmp

echo "## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
	[schemes]
	search = greedy;

	#user schemes go here if search=user. See manual for how to define.#
	" > PF_bottom.tmp

	cat ./PF_top.tmp ./*.newPartitions.txt ./PF_bottom.tmp > partition_finder.cfg  	## Make PartitionFinder configuration file.
	rm ./PF_top.tmp ./PF_bottom.tmp;  						## Remove unnecessary files.


############ STEP #3: RUN PartitionFinder ON THE DATA IN WORKING DIRECTORY
###### Find path to PartitionFinder and assign to variable:
	MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py' |  \
	sed -n 's/.://p')"

	python $MY_PATH_TO_PARTITIONFINDER .

#
#
#
######################################### END ############################################

exit 0
