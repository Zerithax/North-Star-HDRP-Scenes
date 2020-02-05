using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateBoundsV2 : MonoBehaviour
{
    public GameObject interactionManager;

    public enum Hand
    {
        Both,
        Left,
        Right
    }

    public Hand hand = Hand.Both;

    private int lastChildCount = 0;
    private List<Collider> handColliders = new List<Collider>();

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
        //a new hand object was added!
        if (interactionManager.transform.childCount != lastChildCount)
        {
            handColliders.Clear();
            GameObject leftHandObject = GameObject.Find(interactionManager.name + "/Left Interaction Hand Contact Bones");
            GameObject rightHandObject = GameObject.Find(interactionManager.name + "/Right Interaction Hand Contact Bones");
            Collider[] leftHandColliders = leftHandObject?.GetComponentsInChildren<Collider>() ?? null;
            Collider[] rightHandColliders = rightHandObject?.GetComponentsInChildren<Collider>() ?? null;
            switch (hand)
            {
                case Hand.Both:
                    if (leftHandColliders != null)
                        handColliders.AddRange(leftHandColliders);
                    if (rightHandColliders != null)
                        handColliders.AddRange(rightHandColliders);
                    break;
                case Hand.Left:
                    if (leftHandColliders != null)
                        handColliders.AddRange(leftHandColliders);
                    break;
                case Hand.Right:
                    if (rightHandColliders != null)
                        handColliders.AddRange(rightHandColliders);
                    break;
            }
            lastChildCount = interactionManager.transform.childCount;
        }

        if (handColliders.Count > 0)
        {
            Bounds bounds = new Bounds(); // Creates a new bounds at (0,0,0) with a size of (0,0,0)

            bounds.center = handColliders[0].gameObject.transform.position; // Center the bounds to the first point so we can start encapsulating
            foreach (var col in handColliders)
            {
                bounds.Encapsulate(col.bounds);
            }
            BoxCollider thisCollider = gameObject.GetComponent<BoxCollider>();
            thisCollider.size = bounds.size;
            thisCollider.center = bounds.center;
        }
    }
}