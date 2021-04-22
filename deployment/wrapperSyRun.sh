#!/bin/bash

# This writes both stdout and stderr to junk.out, which keep nohup from writing any messages out.
nohup singularity run --env "MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSecondsSy" --env "JOBS_PARMS=120" SleepSecondsSy.sif > tapisjob.out 2>&1 &

pid=$!
echo $pid
