﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Leap.Unity.Geometry {

  [System.Serializable]
  public struct LocalSphere {

    public Vector3 center;
    public float radius;

    public LocalSphere(Vector3 center, float radius) {
      this.center = center;
      this.radius = radius;
    }

    public Sphere With(Transform t) {
      return new Sphere(this, t);
    }

    public static LocalSphere Default() {
      return new LocalSphere(default(Vector3), 1f);
    }

  }

}
