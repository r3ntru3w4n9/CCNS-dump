# Add Spark Python Files to Python Path

import operator
import os
import sys

from tqdm import tqdm

SPARK_HOME = os.environ["SPARK_HOME"]  # Add Spark path
# os.environ["SPARK_LOCAL_IP"] = "127.0.0.1:80"  # Set Local IP
sys.path.append(SPARK_HOME + "/python")  # Add python files to Python Path

print(sys.path)

import numpy as np
from numpy import random
from pyspark import SparkConf, SparkContext
from pyspark.ml.feature import VectorAssembler
from pyspark.mllib.linalg import Vectors
from pyspark.mllib.random import RandomRDDs
from pyspark.sql.session import SparkSession
from pyspark.sql.types import DoubleType

spark = SparkSession(
    SparkContext(
        conf=(
            SparkConf()
            .setMaster("local[*]")  # run on local
            .setAppName("Logistic Regression")  # Name of App
            .set("spark.executor.memory", "1g")
        )  # Set 1 gig of memory
    )
)
spark.sparkContext.setLogLevel("ERROR")

size = 4
FEAT = "features"
ANS = "ans"
names = [*map(str, range(size)), ANS]

# Load and parse the data
data = (
    spark.read.format("csv")
    .option("header", False)
    .load(os.environ["DATA"])
    .toDF(*names)
)

print(names)

length = data.count()

assert data.columns == names

feats = data.columns[:-1]
ans = data.columns[-1]


for n in names:
    data = data.withColumn(n, data[n].cast(DoubleType()))


assembler = VectorAssembler(inputCols=feats, outputCol=FEAT)
traindata = assembler.transform(data).drop(*feats)

print(traindata.toPandas())

weight_bias = Vectors.dense(random.randn(size + 1))

print(weight_bias)


iterations = 10000
lr = 1e-2


traindata.rdd.map(lambda x: x.asDict()).map(print).collect()


def model(feat):
    out = feat @ weight_bias[:-1] + weight_bias[-1]
    assert out.size == 1
    return out.item()


def grad(row):
    dct = row.asDict()
    feat = dct[FEAT]
    ans = dct[ANS]

    out = model(feat)
    diff = out - ans
    square = diff ** 2

    g = np.zeros([size + 1])

    # weight
    for i in range(size - 1):
        g[i] = 2 * diff * feat[i]

    # bias
    g[-1] = 2 * diff

    return g


def sigmoid(x):
    return 1 / (1 + np.exp(x))


def errc(row):
    dct = row.asDict()
    feat = dct[FEAT]
    ans = dct[ANS]

    return int(round(model(feat))) == int(round(ans))


for iter in tqdm(range(iterations)):
    weight_bias -= traindata.rdd.map(grad).reduce(operator.add) * lr / length


trainErr = traindata.rdd.map(errc).map(lambda x: int(not x)).reduce(operator.add)
print("Error Rate =", trainErr / length)
