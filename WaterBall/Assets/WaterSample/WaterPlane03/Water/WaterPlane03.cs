using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterPlane03 : MonoBehaviour
{
    private Material material = null;

    void Start()
    {
        this.material = GetComponent<MeshRenderer>().material;
    }

    void OnDestroy()
    {
    }

    void Update()
    {
    }
}
