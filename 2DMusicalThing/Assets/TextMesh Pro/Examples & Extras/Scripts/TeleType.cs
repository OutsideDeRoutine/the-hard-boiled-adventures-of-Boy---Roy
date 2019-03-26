using UnityEngine;
using System.Collections;
using TMPro;
using System;

public class TeleType : MonoBehaviour
    {
    //SACAR DE AQUI CUANDO YA NO HAGA FALTA
    public bool update=true;

        public string text = "";

        private TMP_Text m_textMeshPro;


        private bool writing;


        void Awake()
        {
            // Get Reference to TextMeshPro Component
            m_textMeshPro = GetComponent<TMP_Text>();
            m_textMeshPro.enableWordWrapping = true;
            m_textMeshPro.alignment = TextAlignmentOptions.Top;

        }


    //SACAR DE AQUI CUANDO YA NO HAGA FALTA
    void Update()
    {
            
        if (update)
        {
            if (writing) StopCoroutine("Write");
            StartCoroutine("Write");
            update = false;
        }

    }

        public void WriteMeThis(string text)
        {
            this.text = text;

            if (writing) StopCoroutine("Write");
            StartCoroutine("Write");
        }


        IEnumerator Write()
        {
            m_textMeshPro.text = text;
            writing = true;
            // Force and update of the mesh to get valid information.
            m_textMeshPro.ForceMeshUpdate();


            int totalVisibleCharacters = m_textMeshPro.textInfo.characterCount; // Get # of Visible Character in text object
            int counter = 0;
            int visibleCount = 0;

            while (visibleCount < totalVisibleCharacters)
            {
                visibleCount = counter % (totalVisibleCharacters + 1);

                m_textMeshPro.maxVisibleCharacters = visibleCount; // How many characters should TextMeshPro display?

                counter += 1;

                yield return new WaitForSeconds(0.05f);
            }
            writing = false;
        }

    }