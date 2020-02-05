using System.Collections;
using System.Collections.Generic;
using UnityEngine;

enum AXIS
{
    X, Y, Z
};

[ExecuteInEditMode]
public class UVGenerator : MonoBehaviour
{
    void Start()
    {
        this.SimpleSmartUVMapping();
    }

    public void SimpleSmartUVMapping()
    {
        Mesh mesh = this.GetComponent<MeshFilter>().sharedMesh;
        Vector2[] uv = new Vector2[mesh.vertices.Length];
        float scale = 0.2f;
        //Debug.Log("uv: " + mesh.vertices.Length);
        //Debug.Log("normal: " + mesh.normals.Length);
        Vector3[] axis_vecs = new Vector3[] { Vector3.left, Vector3.right, Vector3.up, Vector3.down, Vector3.forward, Vector3.back };
        AXIS[] axises = new AXIS[] { AXIS.X, AXIS.X, AXIS.Y, AXIS.Y, AXIS.Z, AXIS.Z };

        for (var mi = 0; mi < mesh.vertices.Length; mi++)
        {
            Vector3 v = mesh.vertices[mi];
            Vector3 normal = mesh.normals[mi];
            float min_angle = 360f;
            AXIS hit_axis = AXIS.X; //Axis which the nomal vector looks at.

            for (int ai = 0; ai < axises.Length; ai++)
            {
                float angle = Vector3.Angle(normal, axis_vecs[ai]);
                if (angle < min_angle)
                {
                    min_angle = angle;
                    hit_axis = axises[ai];
                }
            }

            //UV mapping based on direction of normal map
            if (hit_axis == AXIS.X)
            {
                uv[mi] = new Vector2(v.y, v.z) * scale;
            }
            else if (hit_axis == AXIS.Y)
            {
                uv[mi] = new Vector2(v.x, v.z) * scale;
            }
            else if (hit_axis == AXIS.Z)
            {
                uv[mi] = new Vector2(v.x, v.y) * scale;
            }
        }
        this.GetComponent<MeshFilter>().sharedMesh.uv = uv;
    }
}