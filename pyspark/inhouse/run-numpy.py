import os

import numpy as np
from numpy import random
from tqdm import tqdm

from load import load_name

(label, feat) = load_name(os.environ["DATA"])

weight = random.randn(feat.shape[1])
bias = random.randn()

print(weight, bias)


def model(feat):
    return feat @ weight + bias


LR = 1e-2

for i in tqdm(range(200000)):
    pred = model(feat)
    diff = pred - label
    square = diff ** 2
    err = square.sum()

    grad_w = 2 * diff @ feat
    grad_b = 2 * diff.sum()

    assert grad_w.shape == weight.shape, (grad_w.shape, weight.shape)

    weight -= LR * grad_w / len(label)
    bias -= LR * grad_b / len(label)

    # print(weight, bias)


pred = model(feat)
err = ((pred > 0.5).astype(int) != label).sum() / len(label)

print("Error Rate =", err)
