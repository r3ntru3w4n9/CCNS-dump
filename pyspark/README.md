# PySpark

```Python
assert Python @ Spark == PySpark
```

## [GitHub - b06901038/computer-security-hw4: assert Python @ Spark == PySpark](https://github.com/b06901038/computer-security-hw4)

## Spark in Machine Learning

Spark has branded itself as *The unified analytics engine for Big Data*, so it must have quite some features and performance to offer . Indeed, there is an abundance of tooling present in `spark.mllib` and its claims to be 100ish faster than its kin, hadoop, while being much more flexible and richer with features, seems to be alright. This raises the question, how `spark` stacks up to its competing tooling in machine learning tooling,`numpy` and `torch`? We are about to find out in the following paragraphs.

### Running

Running files with spark can be a little tricky, since `hadoop` and a lot of other things have to be provided for spark to work. My solution is to pass in a lot of environment variables which is listed as follows:
  - `JAVA_HOME`: `java`'s path
  - `HADOOP_HOME`: `hadoop`'s path
  - `SPARK_HOME`: `spark`'s home
  - `PYSPARK_PYTHON`: `python`'s path (please use `python3`
  - `PYSPARK_SUBMIT_ARGS`: Your important flags including spark master's location
  - `DATA`: I'm too lazy to parse flags, so data is passed in as an environment variable.
Please remember to start `spark` before you want to use it!
  - `./sbin/start-master.sh`
  - nativate to `localhost:8080`
  - copy the address "Spark Master at `address`"
  - `./sbin/start-slave.sh -h adress` to run the slave in local mode.
Please set these enviroment variables before running the programs below. Also, `python` requires a few packages:
  - `numpy`: for obvious purposes
  - `torch`: for obvious purposes
  - `pandas`: for coworking with `spark`'s `DataFrame` API
  - `tqdm`: we all love progress bars, don't we?
  - `py4j`: I have no idea why this is needed
Please run the following programs with
```bash
# For spark programs: 1, 2
env 'ENVIRONMENT=$VARIABLES' $SPARK_HOME/bin/spark-submit $DIRECTORY/run-spark.py
# For non-spark programs: 3, 4
env 'ENVIRONMENT=$VARIABLES' python3 run-PROGRAM.py
```

### 1. A reference implementation of logistic regression implemented with spark's in house solution.

Code can be found in `reference/run-spark.py`. It utilizes `spark`'s native `LogisticRegressionWithSGD`, which is implmented completely in `scala`. The source code can be found here: [spark/LogisticRegression.scala at master · apache/spark · GitHub](https://github.com/apache/spark/blob/master/mllib/src/main/scala/org/apache/spark/mllib/classification/LogisticRegression.scala). The code runs relatively well without major problems (except for black-box concerns as all parameters are never configured), completing in 1-2 seconds. The result is shown in the screenshot below. Error rate is ok, at 0.04446

![Screenshot from 2020-11-26 01-41-24.png](assets/Screenshot%20from%202020-11-26%2001-41-24.png)

### 2. A `pyspark` solution that processes data directly inside `python`.

Code can be found in `inhouse/run-spark.py`.  The solution uses `spark`'s `DataFrame`, which means we should get all benefits of spark's distributed file system, but processes data in python with `numpy`, which means we should get all `numpy`'s eye-boggling speed and ease of use. However its this version that is the trickiest to profile. Running only 10000 iterations take a whopping 7 minues. With user time only consuming 24 seconds, the program seems to be heavily I/O bound, which I'm not certain as more detailed analysis would take more time and frankly, with the program running so slow, I don't have the time. Screenshot attached below. Error rate is quite bad, at 0.07799

![Screenshot from 2020-11-26 01-40-39.png](assets/Screenshot%20from%202020-11-26%2001-40-39.png)

### 3. A `numpy` solution that's entirely handcrafted.

Code can be found in `inhouse/run-numpy.py`. The program runs exceptionally well (this is also a compliment to myself), and fast. Really fast especially compared to the `pyspark` solution, running 200000 iterations under 5 seconds. Wow! The accuracy seems to be the best a linear model could do, as `torch` version also scored the same accuracy, so nothing to complain here. Screenshot:

![Screenshot from 2020-11-26 01-41-51.png](assets/Screenshot%20from%202020-11-26%2001-41-51.png)

### 4. A `torch` version that is fool proof.

Code can be found at `inhouse/run-torch.py`. The program utilizes the ever popular `torch`'s `autograd` package behind the scenes (that means it's not even written out in the program!) to calculate gradients automatically. Read this if you don't already know yet: [Autograd: Automatic Differentiation — PyTorch Tutorials 1.7.0 documentation](https://pytorch.org/tutorials/beginner/blitz/autograd_tutorial.html). The code runs ok, executing 10000 cycles under a second while providing optimal result does not seem to be too bad. Screenshot here:

![Screenshot from 2020-11-26 01-42-09.png](assets/Screenshot%20from%202020-11-26%2001-42-09.png)

### Conclusion

All in all, it seems that there's no point writing algorithms implemented in `spark` again in `python` for finetuning purpose, apache's `spark` having a lot of finetuning and `jvm` should render your effort to out compute the default useless, and rewriting would probably cause a lot of suffering as it never is fun to debug wrapper functions. 
