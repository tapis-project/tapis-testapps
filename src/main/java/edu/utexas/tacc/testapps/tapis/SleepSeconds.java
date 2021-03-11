package edu.utexas.tacc.testapps.tapis;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Map;
import java.util.TreeMap;

/** This application can be used to test that a job's inputs and outputs are transfered 
 * as expected.  The application will perform the following:
 * 
 *  - Open an output file in the job's exec system output directory.
 *  - Write some JVM properties to standard out and to the output file.
 *  - Write all environment variables to standard out and to the output file.
 *  - Write the input directory file listing to standard out and to the output file.
 *  - Write the exec directory file listing to standard out and to the output file (if different than input).
 *  - Sleep the prescribed number of seconds.
 *  - Write the output directory file listing to standard out and to the output file.
 *  - Write a completion message to standard out and to the output file.
 * 
 * If a command line parameter is provide, it should be an integral number of seconds that the
 * application should sleep.  If no parameter is provided, a default sleep duration is used.
 * 
 * @author rcardone
 */
public class SleepSeconds 
{
    // -------- Constants.
    private static final int DEFAULT_SLEEP_SECS = 20;
    private static final String OUT_FILE = "SleepSeconds.out";
    
    // Tapis environment variable names.
    private static final String INPUT_DIR_VARIABLE  = "_tapisExecSystemInputDir"; 
    private static final String OUTPUT_DIR_VARIABLE = "_tapisExecSystemOutputDir";
    private static final String EXEC_DIR_VARIABLE   = "_tapisExecSystemExecDir";
    
    // The container directories that correspond to the environment variable directories.
    private static final String INPUT_DIR  = "/JobInput";
    private static final String OUTPUT_DIR = "/JobOutput";
    private static final String EXEC_DIR   = "/JobExec";

    // -------- Fields.
    private BufferedOutputStream   _outFile;
    
    // -------- Public methods.
    public static void main(String[] args) 
     throws Exception
    {
        // Determine the amount of time to sleep.
        int sleepSecs;
        if (args.length > 0) 
            try {sleepSecs = Integer.parseInt(args[0]);}
                catch (Exception e) {
                    String s = "Error: " + e.getMessage();
                    s += "\n\n  Pass in the number of seconds this application should sleep or " +
                         "accept the default sleep time of " + DEFAULT_SLEEP_SECS + " seconds.";
                    System.out.println(s);
                    throw e;
                }
        else sleepSecs = DEFAULT_SLEEP_SECS;
        
        // Execute the application.
        var app = new SleepSeconds();
        app.execute(sleepSecs);
    }
    
    // -------- Private methods.
    private void execute(int sleepSeconds) 
      throws IOException, InterruptedException
    {
        try {
            // Open the output file.
            var envMap = getEnv();
            _outFile = openOutFile(envMap);
            
            // Populate a map of JVM properties.
            var jvmProps = getJvmProperties();
            tee("\nJVM PROPERTIES\n--------------\n");
            tee(jvmProps);
            
            // Print the environment variable values.
            tee("\nENVIRONMENT VARIABLES\n---------------------\n");
            tee(envMap);
            
            tee("\nSLEEP SECONDS: " + sleepSeconds + "\n");
            
            // Print the input directory listings.
            printPreDirectories(envMap);
            
            // Pretend to work the prescribed amount of milliseconds.
            Thread.sleep(sleepSeconds * 1000);
            
            // Print the output directory listings.
            printPostDirectories(envMap);
            
            // Exit message.
            tee("\nEXECUTION COMPLETED\n");
        }
        finally {
            if (_outFile != null) 
                try {_outFile.close();} catch (Exception e2) {}
        }
    }
    
    private TreeMap<String,String> getJvmProperties()
    {
        var map = new TreeMap<String,String>();
        map.put("java.version", System.getProperty("java.version"));
        map.put("os.name", System.getProperty("os.name"));
        map.put("os.version", System.getProperty("os.version"));
        map.put("user.name", System.getProperty("user.name"));
        map.put("user.home", System.getProperty("user.home"));
        map.put("user.dir", System.getProperty("user.dir"));
        return map;
    }
    
    private TreeMap<String,String> getEnv() 
    {
        var map = System.getenv();
        var sortedMap = new TreeMap<String,String>(map);
        return sortedMap;
    }
    
    private BufferedOutputStream openOutFile(Map<String,String> envMap) throws IOException
    {
        if (envMap.get(OUTPUT_DIR_VARIABLE) == null) return null;
        var file = new File(OUTPUT_DIR, OUT_FILE);
        file.createNewFile();
        return new BufferedOutputStream(new FileOutputStream(file));
    }
    
    // Write a string as-is to stdout and to output file.
    private void tee(String s) throws IOException
    {
        System.out.write(s.getBytes());
        if (_outFile != null) _outFile.write(s.getBytes());
    }
    
    // Write to stdout and to output file.
    private void tee(Map<String,String> map) throws IOException
    {
        printEnv(map, System.out);
        if (_outFile != null) printEnv(map, _outFile);
    }

    private void printEnv(Map<String,String> map, OutputStream out) 
     throws IOException
    {
        // Write each map entry in the natural order of keys.
        for (var entry : map.entrySet()) {
            String s = entry.getKey() + "=" + entry.getValue() + "\n";
            out.write(s.getBytes());
        }
        out.flush();
    }
    
    private void printPreDirectories(Map<String,String> envMap) throws IOException
    {
        // Get the directory assignment from the application's environment.
        String inputDir = envMap.get(INPUT_DIR_VARIABLE) == null ? null : INPUT_DIR;
        String execDir  = envMap.get(EXEC_DIR_VARIABLE)  == null ? null : EXEC_DIR;
        
        if (inputDir != null) {
            var dir = new File(inputDir);
            tee("\nINPUT DIRECTORY: " + dir.getAbsolutePath());
            var files = dir.list();
            for (var f : files) tee("\n  " + f);
            tee("\n");
        } else tee("\nINPUT DIRECTORY: null\n");
        
        if (execDir != null) {
            var dir = new File(execDir);
            tee("\nEXEC DIRECTORY: " + dir.getAbsolutePath());
            
            if (!execDir.equals(inputDir)) {
                var files = dir.list();
                for (var f : files) tee("\n  " + f);
            }
            tee("\n");
        } else tee("\nEXEC DIRECTORY: null\n");
    }
    
    private void printPostDirectories(Map<String,String> envMap) throws IOException
    {
        // Get the directory assignment from the application's environment.
        String outputDir = envMap.get(OUTPUT_DIR_VARIABLE) == null ? null : OUTPUT_DIR;
        
        if (outputDir != null) {
            var dir = new File(outputDir);
            tee("\nOUTPUT DIRECTORY: " + dir.getAbsolutePath());
            var files = dir.list();
            for (var f : files) tee("\n  " + f);
            tee("\n");
        } else tee("\nOUTPUT DIRECTORY: null\n");
    }
}
