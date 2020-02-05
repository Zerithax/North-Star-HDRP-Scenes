using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateBoundsFromHand : MonoBehaviour
{
    public GameObject interactionManager;

    public enum Hand
    {
        Both,
        Left,
        Right
    }

    public Hand hand = Hand.Both;

    private GameObject leftHand;
    private GameObject rightHand;
    
    void Start()
    {
        switch (hand)
        {
            case Hand.Both:
                Debug.Log("Both hands chosen");
                break;
            case Hand.Left:
                Debug.Log("Left hand chosen");
                break;
            case Hand.Right:
                Debug.Log("Right hand chosen");
                break;
        }
        
    }

    void Update()
    {
        Collider[] colliders = new Collider[0];
        Vector3 palmNormal = Vector3.zero;

        if (hand == Hand.Left)
        {
            if (!leftHand)
            {
                leftHand = GameObject.Find(interactionManager.name + "/Left Interaction Hand Contact Bones");
            }
            else
            {
                palmNormal = GameObject.Find(interactionManager.name + "/" + leftHand.name + "/Contact Palm Bone").transform.up;
                colliders = leftHand.GetComponentsInChildren<Collider>();

                SetColliderBounds(colliders, palmNormal);
            }
        }
        else if (hand == Hand.Right)
        {
            if (!rightHand)
            {
                rightHand = GameObject.Find(interactionManager.name + "/Right Interaction Hand Contact Bones");
            }
            else
            {
                palmNormal = GameObject.Find(interactionManager.name + "/" + rightHand.name + "/Contact Palm Bone").transform.up;
                colliders = leftHand.GetComponentsInChildren<Collider>();

                SetColliderBounds(colliders, palmNormal);
            }
        }
        else if (hand == Hand.Both)
        {
            if (!leftHand)
            {
                leftHand = GameObject.Find(interactionManager.name + "/Left Interaction Hand Contact Bones");
            }
            if (!rightHand)
            {
                rightHand = GameObject.Find(interactionManager.name + "/Right Interaction Hand Contact Bones");
            }

            Collider[] collidersLeft = leftHand.GetComponentsInChildren<Collider>();
            Collider[] collidersRight = rightHand.GetComponentsInChildren<Collider>();
            var tempCollidersList = new List<Collider>();
            tempCollidersList.AddRange(collidersLeft);
            tempCollidersList.AddRange(collidersRight);
            colliders = tempCollidersList.ToArray();

            SetColliderBounds(colliders, palmNormal);
        }
    }

    private void SetColliderBounds(Collider[] collidersArray, Vector3 palmNormal)
    {
        Bounds bounds = new Bounds(); // Creates a new bounds at (0,0,0) with a size of (0,0,0)

        bounds.center = collidersArray[0].gameObject.transform.position; // Center the bounds to the first point so we can start encapsulating
        foreach (var col in collidersArray)
        {
            bounds.Encapsulate(col.bounds);
        }
        BoxCollider thisCollider = gameObject.GetComponent<BoxCollider>();
        thisCollider.size = bounds.size;
        thisCollider.center = bounds.center;

        if (palmNormal != Vector3.zero) thisCollider.gameObject.transform.up = palmNormal;
        //Debug.Log(palmNormal);
    }
}