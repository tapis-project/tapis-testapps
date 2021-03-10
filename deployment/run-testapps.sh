#!/usr/bin/env bash

# Volume mount command string.
vmounts=""

if [ ! -z "${_tapisExecSystemInputDir}" ]
then 
    vmounts+=" --mount type=bind,source="${_tapisExecSystemInputDir}",target=/JobInput,readonly"
fi

if [ ! -z "${_tapisExecSystemOutputDir}" ]
then 
    vmounts+=" --mount type=bind,source="${_tapisExecSystemOutputDir}",target=/JobOutput"
fi

if [ ! -z "${_tapisExecSystemExecDir}" ]
then 
    vmounts+=" --mount type=bind,source="${_tapisExecSystemExecDir}",target=/JobExec"
fi

echo $vmounts

#docker run --name SleepSeconds --rm ${vmounts} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main