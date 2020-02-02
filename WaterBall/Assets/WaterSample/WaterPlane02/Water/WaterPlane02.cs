using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterPlane02 : MonoBehaviour
{
    [SerializeField]
    private CustomRenderTexture customTexture = null;

    private Material material = null;

    void Start()
    {
        this.material = GetComponent<MeshRenderer>().material;
        this.customTexture.Initialize();
    }

    void OnDestroy()
    {
        this.customTexture.Initialize();
    }

    void Update()
    {
        this.customTexture.Update();
    }
}
