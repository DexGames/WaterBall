using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MakeWater : MonoBehaviour
{
    private Material material = null;

    void Start()
    {
        this.material = GetComponent<MeshRenderer>().material;
        material.SetFloat("_Add", 1.0f);
    }

    void Update()
    {
        material.SetFloat("_Add", 0.0f);
    }
}
