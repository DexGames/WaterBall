using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterPlane02 : MonoBehaviour
{
    private Material material = null;

    void Start()
    {
        this.material = GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
    }
}
