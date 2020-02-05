using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIWalking : SceneLinkedSMB<AIBehaviour>
{
    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        //Check for an edge in the direction I'm walking *at all times*
        m_MonoBehaviour.AIController.Animator.SetBool("Edge", m_MonoBehaviour.IsApproachingAnEdge(m_MonoBehaviour.groundCheckDistance, m_MonoBehaviour.edgeCheckDistance, m_MonoBehaviour.collisionMask));
    }

    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal != null)
        {
            //Set steepness of slope
            m_MonoBehaviour.SetSteepness(groundNormal.Value);

            //Draw a ray showing the direction the ground's normals are pointing right now
            //if (m_MonoBehaviour.debugLines) Debug.DrawRay(m_MonoBehaviour.transform.position, groundNormal.Value, Color.green);

            //Calculate my rotation dot and pass that into the Animator's Rotation float
            m_MonoBehaviour.MonitorRotation(groundNormal.Value);

            //Check for an edge in the direction I'm walking *at all times*
            m_MonoBehaviour.AIController.Animator.SetBool("Edge", m_MonoBehaviour.IsApproachingAnEdge(m_MonoBehaviour.groundCheckDistance, m_MonoBehaviour.edgeCheckDistance, m_MonoBehaviour.collisionMask));
        }
        else
        {
            m_MonoBehaviour.AIController.Animator.SetBool("Ground", false);
            m_MonoBehaviour.AIController.Animator.SetFloat("Steepness", 0);
        }
    }

    /*
    public override void OnSLStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateExit(animator, stateInfo, layerIndex);
        
    }
    */
}