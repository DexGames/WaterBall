using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Water : MonoBehaviour
{
    private float time = 0f;
    private Material material = null;
    private float height = 0f;
    private float width = 0f;

    void Start()
    {
        this.material = GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
        this.time += Time.deltaTime;
        this.height = Mathf.Sin(this.time) * 0.1f;
        //this.width = Mathf.Sin(this.time);

        material.SetFloat("_MyTime", time);
        material.SetFloat("_WaterHeight", this.height);
        material.SetFloat("_WaterWidth", this.width);
    }
}
