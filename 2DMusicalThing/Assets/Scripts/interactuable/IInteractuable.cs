using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IInteractuable
{
     void interact();
}

public abstract class AbstractInteractuable : MonoBehaviour, IInteractuable
{
    public virtual void interact()
    {
        Debug.Log("papito hace cosas");
    }
}
