using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
    	float random_move = Random.value;
        if (random_move < 0.25f)
        {
            transform.Translate(0f, 0f, 0.1f);
        }
        else if ((0.25f <= random_move) && (random_move < 0.5f))
        {
            transform.Translate(0f, 0f, -0.1f);
        }
        else if ((0.5f <= random_move) && (random_move < 0.75f))
        {
            transform.Translate(-0.1f, 0f, 0f);
        }
        else
        {
            transform.Translate(0.1f, 0f, 0f);
        }
        
    }
}
