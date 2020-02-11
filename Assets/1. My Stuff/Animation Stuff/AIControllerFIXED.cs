using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIControllerFIXED : MonoBehaviour
{
    [SerializeField] private Transform deathPoint;
    [SerializeField] private Transform respawnPoint;

    [SerializeField] private LayerMask collisionMask;
    [SerializeField] private float groundCheckDistance = 0.02f;
    [SerializeField] private float moveSpeed = 2f;

    [SerializeField] private float getupSpeed = 1f;
    [SerializeField] private float getupDelay;
    [SerializeField] private float slopeThreshold;

    [SerializeField] private bool hasFallenOver = false;
    [SerializeField] private bool falling = false;
    [SerializeField] private bool walk;
    [SerializeField] private bool edge = false;

    private Vector3 slopeDirection;

    //private bool onGround = false;
    private Vector3? slopeUp = null;

    [SerializeField] private bool logDebugs = false;

    void Start()
    {
        //slopeUp = transform.up;
    }

    private void FixedUpdate()
    {
        if (walk)
        {
            gameObject.GetComponent<Rigidbody>().MovePosition(transform.position + (slopeDirection * moveSpeed * Time.deltaTime) / 100);
        }
    }

    void Update()
    {
        if (logDebugs) Debug.Log("slope up is " + slopeUp);
        if (transform.position.y < deathPoint.position.y) transform.position = respawnPoint.position;


        //GROUND DETECTION CODE
        //Create a sphereRadius using half of the current X scale (it's a 1:1:1 cube, so this is fine!)
        float groundSphereRadius = transform.localScale.x / 2;

        Ray ray = new Ray(new Vector3(transform.position.x, transform.position.y + 0.01f, transform.position.z), Vector3.down);
        if (logDebugs)
        {
            Debug.DrawRay(new Vector3(transform.position.x - groundSphereRadius, transform.position.y, transform.position.z), Vector3.down * groundCheckDistance, Color.red);
            Debug.DrawRay(new Vector3(transform.position.x + groundSphereRadius, transform.position.y, transform.position.z), Vector3.down * groundCheckDistance, Color.red);
            Debug.DrawRay(new Vector3(transform.position.x, transform.position.y, transform.position.z - groundSphereRadius), Vector3.down * groundCheckDistance, Color.red);
            Debug.DrawRay(new Vector3(transform.position.x, transform.position.y, transform.position.z + groundSphereRadius), Vector3.down * groundCheckDistance, Color.red);
        }

        if (Physics.SphereCast(ray, groundSphereRadius, out RaycastHit hit, groundCheckDistance, collisionMask))
        {
            slopeUp = hit.normal;
            Debug.DrawRay(transform.position, slopeUp.Value, Color.green);
        }
        else
        {
            slopeUp = null;
        }


        if (slopeUp == null)
        {
            falling = true;
        }
        else
        {
            //WALKING CODE
            //Set current up to slope's up direction...hopefully removes requirement of "flip back over" code?
            if (!falling && !hasFallenOver)
            {
                if (Vector3.Dot(transform.up, slopeUp.Value) < 0.9) transform.up = slopeUp.Value;

                //The direction the player will move (running up the slope)
                Vector3 cross = Vector3.Cross(Vector3.up, slopeUp.Value);
                slopeDirection = Vector3.Cross(-cross, slopeUp.Value).normalized;
                Debug.DrawRay(transform.position, slopeDirection, Color.blue);

                //If the slope is greater than a threshold, start running up the slope
                if (Mathf.Abs(cross.x) + Mathf.Abs(cross.y) + Mathf.Abs(cross.z) > slopeThreshold && !edge)
                {
                    walk = true;
                }
                else
                {
                    walk = false;
                }
            }
            else
            {
                walk = false;
            }


            //FALLEN OVER CODE
            //Get the dot product of the up direction of the slope and the current up direction
            float dot = Vector3.Dot(slopeUp.Value, transform.up);

            if (logDebugs) Debug.Log("Dot between current up of " + transform.up + " and slope of " + slopeUp + " is " + dot);

            if (falling && !hasFallenOver)
            {
                StartCoroutine(setFallenOver());
            }
            
            if (dot < 0.9 && hasFallenOver)
            {
                Quaternion q = Quaternion.FromToRotation(transform.up, Vector3.up) * transform.rotation;
                transform.Translate(new Vector3(0, 0.1f, 0) * Time.deltaTime, Space.World);
                transform.rotation = Quaternion.Slerp(transform.rotation, q, Time.deltaTime * getupSpeed);
            }
            //I'm upright now, so hasFallenOver = false
            else
            {
                hasFallenOver = false;
            }


            //EDGE DETECTION CODE
            //Using transform.scale.x instead of edgeDistance to try and get the size of the cube as a distance in front of the cube
            Vector3 edgeCheck = transform.position + (slopeDirection * (transform.localScale.x + transform.localScale.x / 4));
            edgeCheck.y += 0.01f;

            //Create a sphereRadius using half of the current X scale (it's a 1:1:1 cube, so this is fine!)
            float edgeSphereRadius = transform.localScale.x / 2;

            Ray edgeRay = new Ray(edgeCheck, Vector3.down);
            if (logDebugs)
            {
                Debug.DrawRay(new Vector3(edgeCheck.x - edgeSphereRadius, edgeCheck.y, edgeCheck.z), Vector3.down * (groundCheckDistance), Color.yellow);
                Debug.DrawRay(new Vector3(edgeCheck.x + edgeSphereRadius, edgeCheck.y, edgeCheck.z), Vector3.down * (groundCheckDistance), Color.yellow);
                Debug.DrawRay(new Vector3(edgeCheck.x, edgeCheck.y, edgeCheck.z - edgeSphereRadius), Vector3.down * (groundCheckDistance), Color.yellow);
                Debug.DrawRay(new Vector3(edgeCheck.x, edgeCheck.y, edgeCheck.z + edgeSphereRadius), Vector3.down * (groundCheckDistance), Color.yellow);
            }

            edge = !Physics.SphereCast(edgeRay, edgeSphereRadius, groundCheckDistance, collisionMask);
        }
    }

    private IEnumerator setFallenOver()
    {
        Debug.Log("I've fallen over! Starting getupDelay...");
        yield return new WaitForSeconds(getupDelay);
        if (slopeUp != null)
        {
            hasFallenOver = true;
            walk = false;
            falling = false;
        }
    }
}