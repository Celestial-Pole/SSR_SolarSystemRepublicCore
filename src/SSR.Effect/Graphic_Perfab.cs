using UnityEngine;
using Verse;


namespace SSR.Effect
{
    public class Graphic_Perfab : Graphic_Single
    {
        public override void DrawWorker(Vector3 loc, Rot4 rot, ThingDef thingDef, Thing thing, float extraRotation)
        {
            CompPerfabDrawer compUnityGameObject = thing.TryGetComp<CompPerfabDrawer>();
            if(compUnityGameObject != null && compUnityGameObject.Transform != null)
            {
                loc += DrawOffset(rot);
                if(compUnityGameObject.MaskTransform)
                {
                    compUnityGameObject.MaskTransform.localPosition = new Vector3(0,loc.y,0);
                    compUnityGameObject.Transform.position = new Vector3(loc.x,0,loc.z);
                }
                else
                {
                    compUnityGameObject.Transform.position = loc;
                }
                compUnityGameObject.Transform.localScale = new Vector3(drawSize.x,1.0f,drawSize.y);
                compUnityGameObject.Transform.rotation = Quaternion.Euler(0,extraRotation + rot.AsAngle,0);
                compUnityGameObject.ShowInNextFrame();
            }
            else base.DrawWorker(loc, rot, thingDef, thing, extraRotation);
        }

        public override Graphic GetColoredVersion(Shader newShader, Color newColor, Color newColorTwo)
        {
            return this;
        }
    }
}