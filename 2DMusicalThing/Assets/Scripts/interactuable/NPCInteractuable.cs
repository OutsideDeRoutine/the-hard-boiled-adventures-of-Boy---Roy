using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NPCInteractuable :MonoBehaviour
{
    public void conversacion()
    {
        Debug.Log("Menuda conversacion mas interesante");
    }

}

/**
public class NPCInteractuable : AbstractInteractuable
{
    public override void interact()
    {
        base.interact();
        Debug.Log("hace cosas el npc");
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.gameObject.tag == "Player")
        {
            interact();
        }
    }

}

**/