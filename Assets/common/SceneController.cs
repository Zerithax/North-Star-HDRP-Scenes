using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneController : MonoBehaviour
{
    public List<string> sceneNames;
    private KeyCode[] keys;

    private void Start()
    {
        this.keys = new KeyCode[] {
            KeyCode.Alpha1, KeyCode.Alpha2, KeyCode.Alpha3, KeyCode.Alpha4, KeyCode.Alpha5,
            KeyCode.Alpha6, KeyCode.Alpha7, KeyCode.Alpha8, KeyCode.Alpha9, KeyCode.Alpha0
        };
    }

    void Update()
    {
        if (this.sceneNames.Count > this.keys.Length) { return;  }

        for (int i = 0; i < this.sceneNames.Count; i++)
        {
            if (Input.GetKeyUp(this.keys[i])) {
                this.ChangeScene(this.sceneNames[i]);
            }
        }
    }

    public void ChangeScene(string sceneName)
    {
        if (sceneName == "") { return; }
        if (SceneManager.GetActiveScene().name == sceneName) { return; }
        SceneManager.LoadScene(sceneName);
    }
}