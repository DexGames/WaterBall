using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    private Camera mainCamera = null;

    void Start()
    {
        this.mainCamera = GetComponent<Camera>();
    }
}
