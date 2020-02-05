using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIIdle : SceneLinkedSMB<AIBehaviour>
{
    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal != null)
        {
            m_MonoBehaviour.AIController.Animator.SetBool("Ground", true);

            //Calculate my rotation dot and pass that into the Animator's Rotation float
            m_MonoBehaviour.MonitorRotation(groundNormal.Value);
        }
    }

    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

        //When I am in the IDLE state, I'm just monitoring the ground's slope and my own rotation
        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal != null)
        {
            m_MonoBehaviour.AIController.Animator.SetBool("Ground", true);

            //Set steepness of slope
            m_MonoBehaviour.SetSteepness(groundNormal.Value);

            //Draw a ray showing the direction the ground's normals are pointing right now
            //if (m_MonoBehaviour.debugLines) Debug.DrawRay(m_MonoBehaviour.transform.position, groundNormal.Value, Color.green);

            //Calculate my rotation dot and pass that into the Animator's Rotation float
            m_MonoBehaviour.MonitorRotation(groundNormal.Value);

            /*
            //Calculate the slope and pass that into the Animator's Slope float
            Vector3 cross = Vector3.Cross(Vector3.up, groundNormal.Value);
            Vector3 slopeDirection = Vector3.Cross(-cross, groundNormal.Value).normalized;
            if (m_MonoBehaviour.debugLines) Debug.DrawRay(m_MonoBehaviour.transform.position, slopeDirection, Color.blue);
            m_MonoBehaviour.AIController.Animator.SetFloat("Steepness", Mathf.Abs(cross.x) + Mathf.Abs(cross.y) + Mathf.Abs(cross.z));

            //Rotate to look toward slope
            m_MonoBehaviour.SetSteepness();
            */

            //Check for an edge in the direction I'm looking *at all times*
            m_MonoBehaviour.AIController.Animator.SetBool("Edge", m_MonoBehaviour.IsApproachingAnEdge(m_MonoBehaviour.groundCheckDistance, m_MonoBehaviour.edgeCheckDistance, m_MonoBehaviour.collisionMask));
        }
        else
        {
            m_MonoBehaviour.AIController.Animator.SetBool("Ground", false);
        }
    }
}
