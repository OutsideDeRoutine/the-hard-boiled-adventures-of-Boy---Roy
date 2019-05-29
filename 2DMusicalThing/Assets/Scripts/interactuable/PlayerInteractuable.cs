using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInteractuable : AbstractInteractuable
{
    GameObject interactuacion;

    public override void interact()
    {
        base.interact();
        Debug.Log("hace cosas el player");

        interactuacion.GetComponent<NPCInteractuable>().conversacion();
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.gameObject.tag == "NPC")
        {
            interactuacion = col.gameObject;
            interact();
        }
    }
}
