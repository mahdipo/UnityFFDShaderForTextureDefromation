using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class DragDrop : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler, IDropHandler
{
    Vector3 initPos;
    Vector3 deltaPos;

    bool isDragStart;
    bool isDraging;

    public UnityEvent onDrag;

    private void OnMouseDown()
    {
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out hit))
            {
                if (hit.collider.gameObject.tag.Contains("ControllerPoint"))
                {
                    isDragStart = true;
                    initPos = Input.mousePosition;// Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, transform.position.z));
                    Debug.LogError(hit.collider.name);
                }
            }
        }
    }

    private void OnMouseDrag()
    {
        if (Input.GetMouseButton(0))
        {

            if (isDragStart)
            {
                isDraging = true;
                Vector3 newPos = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, (transform.position - Camera.main.transform.position).z));
                deltaPos = Input.mousePosition - initPos;//  newPos - initPos;
                                                         // transform.localPosition += new Vector3(deltaPos.x, 0, deltaPos.z);
                transform.position = newPos;
                onDrag.Invoke();
                Debug.LogError(deltaPos);
            }
        }

    }

    private void OnMouseUp()
    {
        isDraging = false;
        isDragStart = false;
    }

    void UpdateShader()
    {

    }

    public void OnPointerDown(PointerEventData eventData)
    {

    }



    public void OnDrag(PointerEventData eventData)
    {


    }

    public void OnPointerUp(PointerEventData eventData)
    {

    }

    public void OnDrop(PointerEventData eventData)
    {

    }
}
