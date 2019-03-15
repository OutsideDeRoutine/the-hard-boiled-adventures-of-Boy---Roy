using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessing_Pixi : MonoBehaviour {

    [SerializeField]
    Material material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination,material);
    }

}
