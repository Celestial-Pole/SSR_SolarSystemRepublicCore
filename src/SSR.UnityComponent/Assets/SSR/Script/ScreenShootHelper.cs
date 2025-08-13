using UnityEditor;
using UnityEngine;


namespace SSR.UnityComponent
{

#if UNITY_EDITOR
    public class ScreenShootHelper : MonoBehaviour
    {
        public Camera targetCamera;
        public string folder = "./Screenshots";
        public int width = 512;
        public int height = 512;

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.F12))
            {
                TakeScreenshot();
            }
        }

        public void TakeScreenshot()
        {
            if (!System.IO.Directory.Exists(folder))
            {
                System.IO.Directory.CreateDirectory(folder);
            }
            var rt = RenderTexture.GetTemporary(width, height, 24, RenderTextureFormat.ARGB32);
            targetCamera.targetTexture = rt;
            targetCamera.Render();

            var prev = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D screenShot = new Texture2D(width, height, TextureFormat.ARGB32, false);
            screenShot.ReadPixels(new Rect(0, 0, width, height), 0, 0);
            screenShot.Apply();
            RenderTexture.active = prev;

            var bytes = screenShot.EncodeToPNG();
            var filename = $"{folder}/screen_{System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss")}.png";
            System.IO.File.WriteAllBytes(filename, bytes);
            Debug.Log($"Took screenshot to: {filename}");

            targetCamera.targetTexture = null;
            RenderTexture.ReleaseTemporary(rt);
        }
    }
#endif
}
