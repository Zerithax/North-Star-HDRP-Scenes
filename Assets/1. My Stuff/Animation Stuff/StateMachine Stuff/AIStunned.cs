using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIStunned : SceneLinkedSMB<AIBehaviour>
{
    public override void OnSLStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateEnter(animator, stateInfo, layerIndex);

        //Just to be safe (and technically realistic) I'm going to revert my awareness of my surroundings so I don't try to act while I'm stunned!
        //m_MonoBehaviour.AIController.Animator.SetBool("Ground", false);
        m_MonoBehaviour.AIController.Animator.SetBool("Edge", false);
        m_MonoBehaviour.AIController.Animator.SetFloat("FallTime", 0);
        m_MonoBehaviour.AIController.Animator.SetFloat("Steepness", 0);

        m_MonoBehaviour.AIController.Animator.SetBool("Stunned", true);
        m_MonoBehaviour.StartCoroutine("StunnedTime");
    }

    /*
    public override void OnSLStateNoTransitionUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnSLStateNoTransitionUpdate(animator, stateInfo, layerIndex);

    }
    */
}