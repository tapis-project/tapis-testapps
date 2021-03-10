#!/usr/bin/env bash

# Volume mount command string.
envdirs=""
vmounts=""

if [ ! -z "${_tapisExecSystemInputDir}" ]
then 
    # Have to use --env because of stupid bash parsing
    envdirs+=" --env _tapisExecSystemInputDir=${_tapisExecSystemInputDir}"
    vmounts+=" --mount type=bind,source="${_tapisExecSystemInputDir}",target=/JobInput"
fi

if [ ! -z "${_tapisExecSystemOutputDir}" ]
then 
    envdirs+=" --env _tapisExecSystemOutputDir=${_tapisExecSystemOutputDir}"
    vmounts+=" --mount type=bind,source="${_tapisExecSystemOutputDir}",target=/JobOutput"
fi

if [ ! -z "${_tapisExecSystemExecDir}" ]
then 
    envdirs+=" --env _tapisExecSystemExecDir=${_tapisExecSystemExecDir}"
    vmounts+=" --mount type=bind,source="${_tapisExecSystemExecDir}",target=/JobExec"
fi

# Debugging.
#echo $envdirs
#echo $vmounts
echo
echo "docker run --name SleepSeconds --rm ${vmounts} ${envdirs} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main"
echo ""

docker run --name SleepSeconds --rm ${vmounts} ${envdirs} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main