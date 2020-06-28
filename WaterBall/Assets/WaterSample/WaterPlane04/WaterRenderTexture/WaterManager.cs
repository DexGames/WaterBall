using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WaterManager : MonoBehaviour
{
    [SerializeField]
    private Camera waterCamera = null;

    [SerializeField]
    private RenderTexture[] mrtTexture = null;

    [SerializeField]
    private RawImage[] mrtDebugImage = null;

    private void Start()
    {
        if (waterCamera != null && 
            mrtTexture != null && 
            mrtTexture.Length > 2)
        {
            waterCamera.SetTargetBuffers(
                new RenderBuffer[3] { mrtTexture[0].colorBuffer, mrtTexture[1].colorBuffer, mrtTexture[2].colorBuffer }, 
                mrtTexture[0].depthBuffer);

            mrtDebugImage[0].texture = mrtTexture[0];
            mrtDebugImage[1].texture = mrtTexture[1];
            mrtDebugImage[2].texture = mrtTexture[2];
        }
    }

    private void Update()
    {
#if UNITY_EDITOR
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            foreach (var image in mrtDebugImage)
            {
                image.gameObject.SetActive(!image.gameObject.activeSelf);
            }
        }
#endif
    }
}
