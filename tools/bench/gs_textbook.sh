#!/bin/bash

ITERATIONS="30"
ORAM_TYPE="sqrt"
BENCH_PROG="bench_gs_textbook"
BENCH_PROG_ARGS=""
BENCH_PROG_VARIABLE_ARG="-n"
BENCH_PROG_VARIABLE_VALS=(4 8 16 32 64 128 256 512)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BENCH_PROG_FULL="$SCRIPT_DIR/../../build/tests/$BENCH_PROG"
RESULTS_DIR="$SCRIPT_DIR/../../results/bench/"
CLIENT=false

set -e

while getopts ":p:c:i:o:" opt; do
	case $opt in
		c)
			BENCH_PROG_ARGS+="-c $OPTARG "
			CLIENT=true
			;;
		p)
			BENCH_PROG_ARGS+="-p $OPTARG "
			;;
		o)
			ORAM_TYPE=$OPTARG
			;;
		i)
			ITERATIONS=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

SUMMARY_FILE="summary_gs_textbook_$ORAM_TYPE.txt"
SAMPLES_FILE="samples_gs_textbook_$ORAM_TYPE.txt"

if [ "$CLIENT" = false ] ; then
	mkdir -p $RESULTS_DIR
	rm -f "$RESULTS_DIR/$SUMMARY_FILE" "$RESULTS_DIR/$SAMPLES_FILE"
	echo `date` > "$RESULTS_DIR/$SUMMARY_FILE"
	echo "ORAM TYPE: $ORAM_TYPE" > "$RESULTS_DIR/$SUMMARY_FILE"
	echo "# `date`" > "$RESULTS_DIR/$SAMPLES_FILE"
	echo "# ORAM TYPE: $ORAM_TYPE" > "$RESULTS_DIR/$SAMPLES_FILE"
fi
	
for II in "${BENCH_PROG_VARIABLE_VALS[@]}"
do
	echo "Executing $ITERATIONS iterations with $II pairs of participants"
	if [ "$CLIENT" = false ] ; then 
		eval "$BENCH_PROG_FULL $BENCH_PROG_ARGS -i $ITERATIONS -o $ORAM_TYPE $BENCH_PROG_VARIABLE_ARG $II" 2>> $RESULTS_DIR/$SUMMARY_FILE >> $RESULTS_DIR/$SAMPLES_FILE
	else
		eval "$BENCH_PROG_FULL $BENCH_PROG_ARGS -i $ITERATIONS -o $ORAM_TYPE $BENCH_PROG_VARIABLE_ARG $II" &> /dev/null
	fi
	sleep 1
done