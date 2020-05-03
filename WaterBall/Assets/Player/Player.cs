using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    // 水面関連
    /// <summary>水面オブジェクト</summary>
    [SerializeField]
    GameObject MWPObj;
    /// <summary>水面用マテリアル</summary>
    Material MWPMat;
    /// <summary>水面MeshRenderer</summary>
    MeshRenderer MWPMeshRenderer;



    // Start is called before the first frame update
    void Awake()
    {
        // 各コンポーネント取得
        MWPMeshRenderer = MWPObj.GetComponent<MeshRenderer>();
        MWPMat = MWPMeshRenderer.sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        Vector2 xzVtx = new Vector2(transform.position.x, transform.position.z);
        Vector4 steepness = MWPMat.GetVector("_Steepness");
        Vector4 amp = MWPMat.GetVector("_Amplitude");
        Vector4 freq = MWPMat.GetVector("_Frequency");
        Vector4 speed = MWPMat.GetVector("_Speed");
        Vector4 dirAB = MWPMat.GetVector("_DirectionA");
        Vector4 dirCD = MWPMat.GetVector("_DirectionB");
        Vector3 ofs = GerstnerOffset4(xzVtx, steepness, amp, freq, speed, dirAB, dirCD);
        transform.position = ofs * 0.5f;

    }

    Vector3 GerstnerOffset4(Vector2 xzVtx, Vector4 steepness, Vector4 amp, Vector4 freq, Vector4 speed, Vector4 dirAB, Vector4 dirCD)
    {
        float t = Time.timeSinceLevelLoad;
        Vector4 _Time = new Vector4(t / 20, t, t * 2, t * 3);
        Vector3 offsets;

        Vector4 AB = Vector4.Scale(Vector4.Scale(xxyy(steepness), xxyy(amp)), dirAB); //steepness.xxyy * amp.xxyy * dirAB.xyzw;
        Vector4 CD = Vector4.Scale(Vector4.Scale(zzww(steepness), zzww(amp)), dirCD); //steepness.zzww * amp.zzww * dirCD.xyzw;

        Vector4 dotABCD = Vector4.Scale(freq, new Vector4(
            Vector2.Dot(new Vector2(dirAB.x, dirAB.y), xzVtx),
            Vector2.Dot(new Vector2(dirAB.z, dirAB.w), xzVtx),
            Vector2.Dot(new Vector2(dirCD.x, dirCD.y), xzVtx),
            Vector2.Dot(new Vector2(dirCD.z, dirCD.w), xzVtx)
        )); //freq.xyzw * half4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));
        Vector4 TIME = Vector4.Scale(Vector4.one * _Time.y, speed); //_Time.yyyy * speed;

        Vector4 COS = new Vector4(
            Mathf.Cos(dotABCD.x + TIME.x),
            Mathf.Cos(dotABCD.y + TIME.y),
            Mathf.Cos(dotABCD.z + TIME.z),
            Mathf.Cos(dotABCD.w + TIME.w)
        ); //cos (dotABCD + TIME);
        Vector4 SIN = new Vector4(
            Mathf.Sin(dotABCD.x + TIME.x),
            Mathf.Sin(dotABCD.y + TIME.y),
            Mathf.Sin(dotABCD.z + TIME.z),
            Mathf.Sin(dotABCD.w + TIME.w)
        ); //sin (dotABCD + TIME);

        offsets.x = Vector4.Dot(COS, new Vector4(AB.x, AB.z, CD.x, CD.z)); // dot(COS, Vector4(AB.xz, CD.xz));
        offsets.z = Vector4.Dot(COS, new Vector4(AB.y, AB.w, CD.y, CD.w)); // dot(COS, Vector4(AB.yw, CD.yw));
        offsets.y = Vector4.Dot(SIN, amp); // dot(SIN, amp);

        return offsets;
    }

    Vector4 xxyy(Vector4 _in) { return new Vector4(_in.x, _in.x, _in.y, _in.y); }
    Vector4 zzww(Vector4 _in) { return new Vector4(_in.z, _in.z, _in.w, _in.w); }
}
