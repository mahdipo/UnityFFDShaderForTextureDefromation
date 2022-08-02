using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class shaderController : MonoBehaviour
{
    public List<GameObject> controllPoints;
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
        Debug.LogError(planSize);
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


        mat.SetVector("_ffd12", new Vector4(startvals[0].x, startvals[0].z, startvals[1].x, startvals[1].z));
        mat.SetVector("_ffd34", new Vector4(startvals[2].x, startvals[2].z, startvals[3].x, startvals[4].z));
        mat.SetVector("_ffd56", new Vector4(startvals[4].x, startvals[4].z, startvals[5].x, startvals[5].z));
        mat.SetVector("_ffd78", new Vector4(startvals[6].x, startvals[6].z, startvals[7].x, startvals[7].z));
        mat.SetVector("_ffd910", new Vector4(startvals[8].x, startvals[8].z, startvals[9].x, startvals[9].z));
        mat.SetVector("_ffd1112", new Vector4(startvals[10].x, startvals[10].z, startvals[11].x, startvals[11].z));
    }
    public void resetShader()
    {
        if (mat == null)
            return;
    }

    Vector3 getStartValue(string cptName, Transform trs, Vector3 planSize, int numRows = 3, int numCols = 4)
    {
        int index = int.Parse(cptName);
        int raw = (index / 10);
        int col = (index % 10);

        float x = raw * (planSize.x / (numCols - 1)) / planSize.x;
        float z = col * (planSize.y / (numRows - 1)) / planSize.y;

        Debug.LogError("planSize:" + planSize + "   localpos: " + trs.localPosition);
        float u = (trs.localPosition.x + (planSize.x / 2)) / planSize.x;
        float v = (trs.localPosition.z + ((int)planSize.y / 2)) / planSize.y;

        Debug.LogError(cptName + " :  " + x + " : " + u + "      " + z + " : " + v);

        return new Vector3(u - x, 0, v - z);
    }
}
