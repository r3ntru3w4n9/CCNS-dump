# Apache Hadoop Streaming

#### Where can I find the source codes online?

[GitHub - b06901038/computer-security-hw3: Computer security homework 3](https://github.com/b06901038/computer-security-hw3)

#### I want to run the package

```bash
# To get the access_log from a predetermin#ed URL or defined URL
make wget
make wget URL=$CUSTOM_URL

# To clean up the input and output directory
make
make INPUT=$INPUT OUTPUT=$OUTPUT

# To run hadoop in streaming mode
make streaming
make streaming INPUT=$INPUT OUTPUT=$OUTPUT


# To build a jar file that can be fed to hadoop
make build_jar
make build_jar JAR=$JAR_DESTINATION INPUT=$INPUT OUTPUT=$OUTPUT

# To build a jar file and run it immediatedly
make jar
make jar JAR=$JAR_DESTINATION INPUT=$INPUT OUTPUT=$OUTPUT
```

#### What I've done in the homework?

The homework wants 2 things

1. To process the files with Hadoop streaming with python scripts.

2. To process the files with native Hadoop (Java with Hadoop library.)

Both tasks are done.

#### Source codes?

1. Python
   
   - Can be found in `streaming/` folder
   
   - requirements: `apache_log_parser` package installed on every machine in the Hadoop cluster.

2. Java
   
   - Can be found in `native/` folder
   
   - requirements: Gradle is needed for compiling the project to a jar file.

#### How the code works. Please explain.

1. Python
   
   - Mapper:
     
     - Using `apache_log_parser` to parse each line of log.
     
     - Hash the time according to its date and hour (discards minutes and seconds).
   
   - Reducer:
     
     - Simply count the number of logs associated with each hash (date and hour).

2. Java
   
   - Mapper:
     
     - Using regex and splitting to parse each line of log.
     
     - Hash the time according to its date and hour (discards minutes and seconds).
   
   - Reducer:
     
     - Counting the number of entries associated with each key with `google guava Iterables.size`.

#### What I've learnt in the homework

1. Hadoop is pretty fun to write in if we're talking about its streaming mode. For better performance you should sacrifice a bit of fun. Not that Java is dull to write in, but the lack of quality documentation (really bad compared to say, Gson) and obscure error messages makes it a pain to learn.

2. Hadoop is difficult to setup (relatively). There are no explainations whatsoever about why we should use ssh even when running on a local machine (because in distributed mode that's how you contact the namenode) and why local files **do** appear in the hdfs (in standalone mode). I used the standalone mode after all because it's the most strait forward.

3. It's awesome that you could use `cat input | map | sort | reduce > output` to test your streaming program!
