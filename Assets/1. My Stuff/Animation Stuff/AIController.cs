using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIController : MonoBehaviour
{
    public Transform deathPoint;
    public Transform respawnPoint;

    [SerializeField]
    private LayerMask collisionMask;
    [SerializeField]
    private float groundCheckDistance = 0.02f;
    [SerializeField]
    private float moveSpeed = 1f;

    //private Vector3 surfaceNormal = new Vector3();
    private Vector3 playerDirection = new Vector3();

    [SerializeField]
    private float getupSpeed = 1f;
    [SerializeField]
    private float getupDelay;


    private bool hasFallenOver = false;
    private bool onGround = false;
    private Vector3 slopeUp;

    [SerializeField]
    private bool logDot = false;


    void Start()
    {
        slopeUp = transform.up;
    }

    void Update()
    {
         if (transform.position.y < deathPoint.position.y) transform.position = respawnPoint.position;

        //Raycast to see if I'm on ground. If true, get ground's normal.
        RaycastHit hit;
        Ray ray = new Ray(transform.position, Vector3.down);
        Debug.DrawRay(transform.position, Vector3.down * groundCheckDistance, Color.red);

        if (Physics.Raycast(ray, out hit, groundCheckDistance, collisionMask))
        {
            onGround = true;
            //surfaceNormal = hit.normal;
            slopeUp = hit.normal;
            Debug.DrawRay(transform.position, slopeUp, Color.green);
        }
        else
        {
            onGround = false;
        }

        //onGround state check
        //if (onGround)
        if (true)
        {
            //Set current up direction to check against
            Vector3 currentUp = transform.up;

            //Get the dot product of the up direction of the slope and the current up direction
            float dot = Vector3.Dot(slopeUp, currentUp);

            if (logDot) Debug.Log("Dot between current up of " + currentUp + " and slope of " + slopeUp + " is " + dot);

            //If that dot product is less than 0.4 and I haven't already fallen over, set hasFallenOver = true
            if (dot < 0.4 && !hasFallenOver)
            {
                //StartCoroutine(setFallenOver());
                hasFallenOver = true;
            }
            //Now that hasFallenOver = true, fix rotation until dot product is greater than 0.9 (mostly upright)
            else if (dot < 0.9 && hasFallenOver)
            {
                Quaternion q = Quaternion.FromToRotation(currentUp, Vector3.up) * transform.rotation;
                transform.Translate(new Vector3(0, 0.1f, 0) * Time.deltaTime, Space.World);
                transform.rotation = Quaternion.Slerp(transform.rotation, q, Time.deltaTime * getupSpeed);
            }
            //I'm upright now, so hasFallenOver = false
            else
            {
                hasFallenOver = false;
            }

            //If I'm not tipped over and I'm on ground
            //if (!hasFallenOver)
            if (onGround)
            {
                //The direction the player will move (running up the slope)
                Vector3 cross = Vector3.Cross(Vector3.up, slopeUp);
                Vector3 slope = Vector3.Cross(-cross, Vector3.up).normalized;
                Debug.DrawRay(transform.position, slope, Color.blue);

                //If the slope is greater than a threshold, start running up the slope
                if (Mathf.Abs(cross.x) + Mathf.Abs(cross.y) + Mathf.Abs(cross.z) > 0.2)
                {
                    gameObject.transform.position += (slope / 100 * (moveSpeed * 0.1f));
                }
            }

        }
    }

    private IEnumerator setFallenOver()
    {
        Debug.Log("I've fallen over! Starting getupDelay...");
        yield return new WaitForSeconds(getupDelay);
        if (onGround)
        {
            hasFallenOver = true;
        }
    }
}