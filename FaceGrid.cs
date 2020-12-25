using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceGrid : MonoBehaviour
{
    public float width;
    public float height;
    public float xMin;
    public float yMin;
    public GameObject Face;

    // Start is called before the first frame update
    void Start()
    {
        Mesh myMesh = GetComponent<MeshFilter>().mesh;
        Vector3 mySize = myMesh.bounds.size;
        width = mySize.x;
        height = mySize.y;
        xMin = gameObject.transform.position.x - (width / 2.0f);
        yMin = gameObject.transform.position.y - (height / 2.0f);

        Debug.Log("width = " + width);
        Debug.Log("xMin = " + xMin);

        // Set the Shader Values
        //Material faceMat = Face.GetComponent<Material>();
        Material faceMat = gameObject.GetComponent<Renderer>().material;
        // something else
        Shader faceShader = faceMat.shader;
        faceMat.SetFloat("_Width", width);
        faceMat.SetFloat("_Height", height);
        faceMat.SetFloat("_xMin", xMin);
        faceMat.SetFloat("_yMin", yMin);
    }

}
