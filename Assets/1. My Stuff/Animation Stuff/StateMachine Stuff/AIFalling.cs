using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIFalling : SceneLinkedSMB<AIBehaviour>
{
    private float initialTime;

    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        initialTime = Time.time;
    }

    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal == null)
        {
            m_MonoBehaviour.AIController.Animator.SetFloat("FallTime", Time.time - initialTime);
        }
        else
        {
            m_MonoBehaviour.AIController.Animator.SetBool("Ground", true);
        }
    }
}