using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
	int collision_ct = 0;
	void OnCollisionEnter(Collision collision)
	{
		if (collision.gameObject.name != "Plane"){
			collision_ct++;
	    	Debug.Log("衝突回数：" + collision_ct);
	    }
	}        

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
            transform.Translate(0f, 0f, 1.0f);
        }
        else if ((0.25f <= random_move) && (random_move < 0.5f))
        {
            transform.Translate(0f, 0f, -1.0f);
        }
        else if ((0.5f <= random_move) && (random_move < 0.75f))
        {
            transform.Translate(-1.0f, 0f, 0f);
        }
        else
        {
            transform.Translate(1.0f, 0f, 0f);
        }              
    }
}
