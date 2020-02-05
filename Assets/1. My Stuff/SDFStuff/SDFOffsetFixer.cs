using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFOffsetFixer : MonoBehaviour
{
    public MeshToSDF SDF;

    void Update()
    {
        Vector3 position = this.transform.position;
        SDF.offset = new Vector3(0.5f - position.x, 0.5f - position.y, 0.5f - position.z);
    }
}
