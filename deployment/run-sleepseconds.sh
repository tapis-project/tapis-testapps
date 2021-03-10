#!/usr/bin/env bash

# Volume mount and environment command strings.
envdirs=""
vmounts=""

# Each of the distinguished tapis job directories gets mounted in the container's
# root directory with a different but hardcoded value.  The directories may need 
# to be cleaned out between runs.

if [ ! -z "${_tapisExecSystemInputDir}" ]
then 
    # Have to use --env because of stupid bash parsing.
    envdirs+=" --env _tapisExecSystemInputDir=${_tapisExecSystemInputDir}"
    vmounts+=" --mount type=bind,source="${_tapisExecSystemInputDir}",target=/JobInput,readonly"
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

# We run as the logged on user, which hopefully is not root.  Here's the final command that runs.
echo
echo "docker run --name SleepSeconds -u $(id -u):$(id -g) --rm ${vmounts} ${envdirs} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main"
echo ""

# Run the container.
docker run --name SleepSeconds --rm -u "$(id -u):$(id -g)" ${vmounts} ${envdirs} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main