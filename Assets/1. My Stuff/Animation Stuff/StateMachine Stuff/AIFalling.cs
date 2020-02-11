using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Bindings;
using UnityEngine.Internal;
using UnityEngine.Scripting;

public class AIFalling : SceneLinkedSMB<AIBehaviour>
{
    private float initialTime;

    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        //m_MonoBehaviour.rb.detectCollisions = true;
        //m_MonoBehaviour.rb.useGravity = true;
        
        initialTime = Time.time;
    }

    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

        Vector3? groundNormal = m_MonoBehaviour.GetGroundNormal(m_MonoBehaviour.groundCheckDistance);
        if (groundNormal == null)
        {
            m_MonoBehaviour.animator.SetFloat("FallTime", Time.time - initialTime);
        }
        else
        {
            m_MonoBehaviour.animator.SetBool("Ground", true);
        }
    }
}