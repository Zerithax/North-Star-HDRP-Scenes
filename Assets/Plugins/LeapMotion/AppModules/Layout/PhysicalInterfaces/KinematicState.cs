﻿using UnityEngine;

namespace Leap.Unity.PhysicalInterfaces {

  public struct KinematicState {

    public Pose pose;
    public Movement movement;

    public KinematicState(Pose pose, Movement movement) {
      this.pose = pose;
      this.movement = movement;
    }


    public void Integrate(float deltaTime) {
      pose = pose.Integrated(movement, deltaTime);
    }

    public void Integrate(Vector3 linearAcceleration,
                          float deltaTime) {
      movement.Integrate(linearAcceleration, deltaTime);
      pose = pose.Integrated(movement, deltaTime);
    }

    public void Integrate(Vector3 linearAcceleration,
                          Vector3 angularAcceleration,
                          float deltaTime) {
      movement.Integrate(linearAcceleration, angularAcceleration, deltaTime);
      pose = pose.Integrated(movement, deltaTime);
    }

  }

}
