using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIControllerM : MonoBehaviour
{
    public Animator Animator;

    public LayerMask collisionMask;
    public float groundCheckDistance;
    public float moveSpeed = 1f;
    public float slopeThreshold;

    public float getupSpeed = 1f;
    public float getupDelay;
    //private bool hasFallenOver = false;
    //private bool onGround = false;

    public bool logDot = false;

    public string currentState = "";

    void Update()
    {
        /*
        Vector3? groundNormal = GetGroundNormal(groundCheckDistance);
        if (groundNormal != null)
        {
            //Set 'standing' (NEUTRAL) state
            currentState = "Standing on ground";

            //Draw a ray showing the direction the ground's normals are pointing right now
            Debug.DrawRay(transform.position, groundNormal.Value, Color.green);

            //Check to see if I've fallen over and will need to get up
            MonitorRotation(groundNormal.Value);

            if (hasFallenOver == false)
            {
                ClimbSlope(groundNormal.Value, slopeThreshold);
            }
        }
        else
        {
            //Set 'falling' state
            currentState = "Falling/tumbling";
        }
        */
    }

    /*
    private IEnumerator SetFallenOver()
    {
        Debug.Log("I've fallen over! Starting getupDelay...");
        yield return new WaitForSeconds(getupDelay);
        if (onGround == true)
        {
            hasFallenOver = true;
        }
    }

    private Vector3? GetGroundNormal(float distance)
    {
        RaycastHit hit;
        Ray ray = new Ray(transform.position, Vector3.down);
        Debug.DrawRay(transform.position, Vector3.down * distance, Color.red);

        if (Physics.Raycast(ray, out hit, distance, collisionMask))
        {
            return hit.normal;
        }
        else
        {
            return null;
        }
    }

    private void FixRotation(float speed, Vector3 slopeUp)
    {
        Quaternion newRotation = Quaternion.FromToRotation(transform.up, slopeUp) * transform.rotation;
        transform.Translate(new Vector3(0, 0.15f, 0) * Time.deltaTime, Space.World);
        transform.rotation = Quaternion.Slerp(transform.rotation, newRotation, Time.deltaTime * speed);
    }

    private void MonitorRotation(Vector3 slopeUp)
    {
        //Set current up direction to check against
        Vector3 currentUp = transform.up;

        //Get the dot product of the up direction of the slope and the current up direction
        float dot = Vector3.Dot(slopeUp, currentUp);

        if (logDot) Debug.Log("Dot between current up of " + currentUp + " and slope of " + slopeUp + " is " + dot);

        //If that dot product is less than 0.4 and I haven't already fallen over, set hasFallenOver = true
        if (dot < 0.4 && hasFallenOver == false)
        {
            //Set 'fallen over' state
            currentState = "Fallen over";

            StartCoroutine(SetFallenOver());
        }
        //Now that hasFallenOver = true, fix rotation until dot product is greater than 0.9 (mostly upright)
        else if (dot < 0.9 && hasFallenOver == true)
        {
            //Set 'getting up' state
            currentState = "Getting up...";

            FixRotation(getupSpeed, slopeUp);
        }
        //I'm upright now, so hasFallenOver = false
        else
        {
            //Set 'standing' state
            currentState = "Standing on ground";

            hasFallenOver = false;
        }
    }

    private void ClimbSlope(Vector3 slopeUp, float threshold)
    {
        //Get (and draw) the direction I will move (running up the slope)
        Vector3 cross = Vector3.Cross(Vector3.up, slopeUp);
        Vector3 slope = Vector3.Cross(-cross, Vector3.up).normalized;
        Debug.DrawRay(transform.position, slope, Color.blue);

        //If the slope is greater than a threshold, start running up the slope
        if (Mathf.Abs(cross.x) + Mathf.Abs(cross.y) + Mathf.Abs(cross.z) > threshold)
        {
            //Set 'walking' state (walking is a substate of standing/on ground)
            currentState = "Walking";

            gameObject.transform.position += slope * moveSpeed / 1000;
        }
    }
    */

}
