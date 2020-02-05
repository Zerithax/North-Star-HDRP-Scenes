using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIGettingUp : SceneLinkedSMB<AIBehaviour>
{
    private bool onGround = false;
    private Vector3? groundNormal;

    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal != null)
        {
            onGround = true;
        }
    }

    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

        if (onGround)
        {
            //Get back up
            groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
            m_MonoBehaviour.FixRotation(m_MonoBehaviour.getupSpeed, groundNormal.GetValueOrDefault(Vector3.up));
        }
        else
        {
            m_MonoBehaviour.AIController.Animator.SetBool("Ground", false);
        }
    }
}