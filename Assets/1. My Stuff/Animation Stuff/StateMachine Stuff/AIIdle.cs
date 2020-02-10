using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIIdle : SceneLinkedSMB<AIBehaviour>
{
    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        //m_MonoBehaviour.rb.detectCollisions = false;
        //m_MonoBehaviour.rb.useGravity = false;

        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal != null)
        {
            m_MonoBehaviour.animator.SetBool("Ground", true);

            //Calculate my rotation dot and pass that into the Animator's Rotation float
            m_MonoBehaviour.MonitorRotation(groundNormal.Value);
        }
    }

    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

        //Put the rigidbody to sleep so it doesn't mess with our AI when it's on my hands
        //m_MonoBehaviour.rb.Sleep();

        //When I am in the IDLE state, I'm just monitoring the ground's slope and my own rotation
        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal != null)
        {
            m_MonoBehaviour.animator.SetBool("Ground", true);

            //Set steepness of slope
            m_MonoBehaviour.SetSteepness(groundNormal.Value);

            //Calculate my rotation dot and pass that into the Animator's Rotation float
            m_MonoBehaviour.MonitorRotation(groundNormal.Value);

            //Check for an edge in the direction I'm looking *at all times*
            m_MonoBehaviour.animator.SetBool("Edge", m_MonoBehaviour.IsApproachingAnEdge(m_MonoBehaviour.groundCheckDistance, m_MonoBehaviour.edgeCheckDistance, m_MonoBehaviour.collisionMask));
        }
        else
        {
            m_MonoBehaviour.animator.SetBool("Ground", false);
        }
    }
}
