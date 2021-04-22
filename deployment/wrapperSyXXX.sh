#!/bin/bash

# Since the tapis directories are not assigned in environment variables, no files will be written during execution.
singularity instance start --env "MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSecondsSy" --env "JOBS_PARMS=120" SleepSecondsSy.sif XXX
