package com.app.source;

import java.io.Serializable;

public interface Hittable extends Serializable {
    HitData hit(Vector source, Vector towards);

    Box bounds();
}
