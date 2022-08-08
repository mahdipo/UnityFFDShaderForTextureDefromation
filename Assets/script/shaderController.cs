using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class shaderController : MonoBehaviour
{
    public List<GameObject> controllPoints;
    List<Vector3> cpt_DefaultPos;

    public GameObject plan;

    Material mat;
    Vector3 planSize;

    private void Start()
    {
        var mr = GetComponent<MeshRenderer>();
        if (mr)
        {
            mat = mr.material;
        }

        planSize = plan.GetComponent<MeshRenderer>().bounds.size;       

        cpt_DefaultPos = new List<Vector3>();
        foreach (var i in controllPoints)
            cpt_DefaultPos.Add(i.transform.localPosition);

        updateShader();

        
    }
    public void updateShader()
    {
        if (controllPoints == null || controllPoints.Count != 12 || mat == null)
            return;

        List<Vector3> startvals = new List<Vector3>();
        foreach (var i in controllPoints)
        {
            Vector3 s = getStartValue(i.name, i.transform, planSize);
            startvals.Add(s);
        }

        int n = 1;
        for (int i = 0; i < startvals.Count; i+=2)
        {
            string param_name = "_ffd" + n + (n + 1);
            mat.SetVector(param_name, new Vector4(startvals[i].x, startvals[i].z, startvals[i+1].x, startvals[i+1].z));           
            n += 2;
        }        
    }   

    Vector3 getStartValue(string cptName, Transform trs, Vector3 planSize, int numRows = 3, int numCols = 4)
    {
        int index = int.Parse(cptName);
        int raw = (index / 10);
        int col = (index % 10);

        float x = raw * (planSize.x / (numCols - 1)) / planSize.x;
        float z = col * (planSize.y / (numRows - 1)) / planSize.y;
       
        float u = (trs.localPosition.x + (planSize.x / 2)) / planSize.x;
        float v = (trs.localPosition.z + (planSize.y / 2)) / planSize.y;
       
        return new Vector3(u - x, 0, v - z);
    }

    public void resetCpts()
    {
        for (int i = 0; i < controllPoints.Count; i++)
        {
            controllPoints[i].transform.localPosition = cpt_DefaultPos[i];
        }
        updateShader();
    }
}
