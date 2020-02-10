using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIStunned : SceneLinkedSMB<AIBehaviour>
{
    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        //m_MonoBehaviour.rb.detectCollisions = true;
        //m_MonoBehaviour.rb.useGravity = true;

        //Just to be safe (and technically realistic) I'm going to revert my awareness of my surroundings so I don't try to act while I'm stunned!
        //m_MonoBehaviour.AIController.Animator.SetBool("Ground", false);
        m_MonoBehaviour.animator.SetBool("Edge", false);
        m_MonoBehaviour.animator.SetFloat("FallTime", 0);
        m_MonoBehaviour.animator.SetFloat("Steepness", 0);

        m_MonoBehaviour.animator.SetBool("Stunned", true);
        m_MonoBehaviour.StartCoroutine("StunnedTime");
    }
}