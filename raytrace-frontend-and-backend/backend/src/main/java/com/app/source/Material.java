package com.app.source;

import java.io.Serializable;

public interface Material extends Serializable {
    Vector scatter(Vector input, Vector normal);

    Vector albedo();
}
