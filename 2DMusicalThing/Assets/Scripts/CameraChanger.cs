using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraChanger : MonoBehaviour {

    private Coroutine co;
    private Coroutine dontStop;
    private bool isRunning;

    private void Start()
    {
    }

    private void OnTriggerEnter(Collider other)
    {
        GameObject go = other.transform.gameObject;
        if (go.tag == "Player")
        {
            if (go.transform.position.z < this.transform.position.z)
            {
                if (isRunning)
                {
                    isRunning = false;
                }
                co = StartCoroutine(RotateTowardsY(go, 270, -Vector3.up,70));
                dontStop = StartCoroutine(MoveMe(go, 1));
            }
            else
            {
                if (isRunning)
                {
                    isRunning = false;
                }
                co = StartCoroutine(RotateTowardsY(go, 0, Vector3.up,70));
                dontStop = StartCoroutine(MoveMe(go, -1));
            }
            
        }
    }

    private void OnTriggerExit(Collider other)
    {
        StopCoroutine(dontStop);
    }

    IEnumerator MoveMe(GameObject go, float input)
    {
        while (true)
        {
            yield return new WaitForFixedUpdate();

            go.GetComponent<Move>().MakeMyMove(input,0);

            
        }
    }

    IEnumerator RotateTowardsY(GameObject go,float angle, Vector3 axis, float vel) 
    {
        if (!isRunning) yield return new WaitForEndOfFrame();
        isRunning = true;
        while (go.transform.rotation.eulerAngles.y != angle && isRunning)     
        {
            if (Mathf.Abs(go.transform.rotation.eulerAngles.y - angle) < 5f)
            {
                go.transform.Rotate(axis, Mathf.Abs(go.transform.rotation.eulerAngles.y - angle));
                isRunning = false;
            }
            else
            {
                go.transform.Rotate(axis, vel * Time.deltaTime);
            }
            

            yield return null;  
        }
        isRunning = false;
    }

}
