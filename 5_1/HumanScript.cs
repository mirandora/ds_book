using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HumanScript : MonoBehaviour
{
    LineRenderer radarLine;
    Queue<Vector3> sphere_pos_queue = new Queue<Vector3>(); 
    Vector3 sphere_pos;
    Vector3 human_pos = new Vector3(0f, 1.85f, 0.0f);
    Color32 ray_color = new Color32(220, 12, 12, 64);


    // Start is called before the first frame update
    void Start()
    {
		sphere_pos = GameObject.Find("SphereTarget").gameObject.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
		sphere_pos = GameObject.Find("SphereTarget").gameObject.transform.position;
		sphere_pos_queue.Enqueue(sphere_pos);

		if (sphere_pos_queue.Count > 10){
			Vector3 tmp_pos = sphere_pos_queue.Dequeue();			

			Ray ray = new Ray(human_pos, tmp_pos-human_pos);
			RaycastHit hit = new RaycastHit();
			if(Physics.Raycast(ray ,out hit, 3)){
				print("see!");
			}
			else{
				print("not see!");
			}
			Debug.DrawRay(ray.origin, ray.direction*3, ray_color, 1.0f, false);
		}
    }
}
