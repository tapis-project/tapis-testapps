#!/usr/bin/env bash

# Initialize all command line options passed to docker run.
envdirs=""
vmounts=""
jobparms=""

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

# If the caller passed in the number of seconds to sleep, then we set the
# environment variable defined in the dockerfile for application parms. 
if [ ! -z $1 ]
then 
    jobparms=" --env JOBS_PARMS=$1"
fi

# Debugging.
#echo $envdirs
#echo $vmounts
#echo $jobparms

# Remove the container id file if it exists.
rm ${PWD}/SleepSeconds.cid

# We run as the logged on user, which hopefully is not root.  Here's the final command that runs.
echo
echo "docker run --name SleepSeconds --rm -u $(id -u):$(id -g) --cidfile ${PWD}/SleepSeconds.cid ${vmounts} ${envdirs} ${jobparms} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main" $1
echo ""

# Run the container.
docker run --name SleepSeconds --rm -u "$(id -u):$(id -g)" --cidfile ${PWD}/SleepSeconds.cid ${vmounts} ${envdirs} ${jobparms} -e 'MAIN_CLASS=edu.utexas.tacc.testapps.tapis.SleepSeconds' tapis/testapps:main 