using System;
using System.Linq;
using UnityEngine;

namespace SSR.Rendering.Editor
{
    //按 ArmReach、ArmRig 和 ArmGripper 的待机规则设置导出模型。
    internal static class MechanicalArmBlueprintPose
    {
        //夹爪张开并停在运行时待机点，关节角由实际骨骼尺寸求得。
        internal static void Apply(GameObject root)
        {
            Transform[] transforms = root.GetComponentsInChildren<Transform>(true);
            Transform Bone(string name) => transforms.Single(t => t.name == name && !t.GetComponent<Renderer>());
            Transform[] joints = { Bone("BaseYaw"), Bone("Shoulder"), Bone("Elbow"), Bone("WristPitch") };
            Transform grip = Bone("Grip");
            grip.position = (JawTip(root, Bone("Jaw_L")) + JawTip(root, Bone("Jaw_R"))) * .5f;

            //ArmReach.IdlePoint 的地图点经六十度投影还原到模型空间。
            Vector3 goal = new Vector3(.35f, 1.35f, (.95f - 1.35f * .5f) / .8660254f);
            Quaternion inverse = Quaternion.Inverse(joints[0].rotation);
            Vector3 shoulderOffset = inverse * (joints[1].position - joints[0].position);
            Vector3 upper = inverse * (joints[2].position - joints[1].position);
            Vector3 forearm = inverse * (joints[3].position - joints[2].position);
            Vector3 local = inverse * (goal - joints[0].position);
            Vector3 hand = Quaternion.Inverse(joints[3].rotation) * (grip.position - joints[3].position);
            float lateral = shoulderOffset.z + upper.z + forearm.z + hand.z;
            float forwardSquared = local.x * local.x + local.z * local.z - lateral * lateral;
            if (forwardSquared < 0) throw new InvalidOperationException("机械臂待机点过于靠近底座转轴。");
            float forward = Mathf.Sqrt(forwardSquared);
            float yaw = Mathf.DeltaAngle(0, (Mathf.Atan2(local.x, local.z) - Mathf.Atan2(forward, lateral)) * Mathf.Rad2Deg);

            Vector2 target = new Vector2(forward - shoulderOffset.x + hand.x, local.y - shoulderOffset.y + hand.y);
            float a = new Vector2(upper.x, upper.y).magnitude;
            float b = new Vector2(forearm.x, forearm.y).magnitude;
            float cosine = (target.sqrMagnitude - a * a - b * b) / (2 * a * b);
            if (cosine < -1 || cosine > 1) throw new InvalidOperationException("机械臂骨骼无法到达待机点。");
            float elbow = -Mathf.Acos(cosine);
            float upperRest = Mathf.Atan2(upper.y, upper.x);
            float forearmRest = Mathf.Atan2(forearm.y, forearm.x);
            float shoulder = Mathf.Atan2(target.y, target.x) - Mathf.Atan2(b * Mathf.Sin(elbow), a + b * Mathf.Cos(elbow));
            float shoulderAngle = (shoulder - upperRest) * Mathf.Rad2Deg;
            float elbowAngle = (elbow + upperRest - forearmRest) * Mathf.Rad2Deg;
            float wristAngle = Mathf.DeltaAngle(0, 180 - shoulderAngle - elbowAngle);
            if (shoulderAngle < -75 || shoulderAngle > 75 || elbowAngle < -145 || elbowAngle > 5
                || wristAngle < -150 || wristAngle > 150)
                throw new InvalidOperationException("机械臂待机姿势超出运行时关节限制。");

            float[] angles = { yaw, shoulderAngle, elbowAngle, wristAngle };
            for (int i = 0; i < joints.Length; i++)
                joints[i].localRotation *= Quaternion.AngleAxis(angles[i], i == 0 ? Vector3.up : Vector3.forward);

            if ((grip.position - goal).sqrMagnitude > .0064f)
                throw new InvalidOperationException("机械臂蓝图的夹爪位置与运行时待机点不一致。");
            Debug.Log("SSR_ARM_BLUEPRINT_POSE angles=" + string.Join(",", angles.Select(a => a.ToString("F4")))
                + " grip=" + grip.position.ToString("F6") + " goal=" + goal.ToString("F6"));
        }

        //从刚性蒙皮绑定矩阵读取爪尖，与运行时张开状态的抓取点一致。
        private static Vector3 JawTip(GameObject root, Transform bone)
        {
            SkinnedMeshRenderer skin = root.GetComponentsInChildren<SkinnedMeshRenderer>().Single(r => r.name == bone.name);
            int index = Array.IndexOf(skin.bones, bone);
            if (index < 0) throw new InvalidOperationException("夹爪网格未绑定到对应骨骼：" + bone.name);
            Matrix4x4 bind = skin.sharedMesh.bindposes[index];
            Vector3[] vertices = skin.sharedMesh.vertices.Select(bind.MultiplyPoint3x4).Distinct().ToArray();
            float end = vertices.Max(v => v.y);
            Vector3[] tips = vertices.Where(v => v.y >= end - .001f).ToArray();
            Vector3 tip = tips.Aggregate(Vector3.zero, (sum, vertex) => sum + vertex) / tips.Length;
            return bone.TransformPoint(tip);
        }
    }
}
