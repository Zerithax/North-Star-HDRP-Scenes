﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Leap.Unity.UI {

  [CreateAssetMenu(fileName = "NewColorPalette", menuName = "Color Palette", order = 310)]
  public class ColorPalette_Old : ScriptableObject {

    [SerializeField]
    public Color[] colors;

    public Color this[int index] {
      get {
        return colors[index];
      }
      set {
        colors[index] = value;
      }
    }

  }

}
