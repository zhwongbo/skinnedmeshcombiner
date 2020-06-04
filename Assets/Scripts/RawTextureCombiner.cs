using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace AQ
{
	public class RawTextureCombiner : MonoBehaviour
	{
        public List<SkinnedMeshCombinerHolder> combineHolderList;
        public Texture2D outTexture;
        public Texture2D[] texture2s;
        public Text text;

        void Start()
        {

        }

        public void StartCombine()
        {
            RawTexture();
            CombineObject(this.gameObject, 512);
        }

        List<string> ExcludeList = new List<string>() { "wing_", "hand_" };
        void CollectionTransforms(Transform transform, ref List<Transform> list)
        {
            var name = transform.name;
            for (int i = 0; i < ExcludeList.Count; i++)
            {
                if (name.StartsWith(ExcludeList[i]))
                {
                    return;
                }
            }

            list.Add(transform);
            for (int i = 0; i < transform.childCount; i++)
            {
                CollectionTransforms(transform.GetChild(i), ref list);
            }
        }
        string COMBINE_DIFFUSE_TEXTURE = "_MainTex";


        /** 合并蒙皮，合并纹理
         *  纹理需要打开读写
         */
        public void CombineObject(GameObject skeleton, int combine_size)
        {
            if (combineHolderList == null || combineHolderList.Count == 0)
            {
                return;
            }

            List<Transform> transforms = new List<Transform>();
            CollectionTransforms(skeleton.transform, ref transforms);

            List<Transform> bones = new List<Transform>();

            string flag = "hair-?_clothes-?_pants-?_shoes-?";

            Material newMaterial = null;
            
            Mesh shaderMesh = null;
            List<CombineInstance> combineInstances = new List<CombineInstance>();
            List<Vector2[]> oldUV = new List<Vector2[]>();
            List<Material> materials = new List<Material>();
            SkinnedMeshCombinerHolder holder = null;
            for (int i = 0; i < combineHolderList.Count; i++)
            {
                holder = combineHolderList[i];
                CombineInstance ci = new CombineInstance();
                ci.mesh = holder.mesh;
                ci.subMeshIndex = 0;
                combineInstances.Add(ci);
                materials.Add(holder.material);

                for (int j = 0; j < holder.stringHolder.content.Length; j++)
                {
                    int tBase = 0;
                    for (tBase = 0; tBase < transforms.Count; tBase++)
                    {
                        if (holder.stringHolder.content[j].Equals(transforms[tBase].name))
                        {
                            bones.Add(transforms[tBase]);
                            break;
                        }
                    }
                }
            }

            List<Texture2D> Textures = new List<Texture2D>();
            TextureFormat format = TextureFormat.RGBA32;
            for (int i = 0; i < materials.Count; i++)
            {
                Textures.Add(materials[i].GetTexture(COMBINE_DIFFUSE_TEXTURE) as Texture2D);
            }
            format = Textures[0].format;
            newMaterial = UnityEngine.Object.Instantiate(materials[0]);
            newMaterial.name = flag;

            Rect[] uvs = new Rect[4];
            newMaterial.mainTexture = outTexture;
            uvs[0] = new Rect(0, 0, 0.5f, 0.5f);
            uvs[1] = new Rect(0.5f, 0, 0.5f, 0.5f);
            uvs[2] = new Rect(0, 0.5f, 0.5f, 0.5f);
            uvs[3] = new Rect(0.5f, 0.5f, 0.5f, 0.5f);

            Vector2[] uva, uvb;
            for (int j = 0; j < combineInstances.Count; j++)
            {
                uva = (Vector2[])(combineInstances[j].mesh.uv);
                uvb = new Vector2[uva.Length];
                for (int k = 0; k < uva.Length; k++)
                {
                    uvb[k] = new Vector2((uva[k].x * uvs[j].width) + uvs[j].x, (uva[k].y * uvs[j].height) + uvs[j].y);
                }
                oldUV.Add(combineInstances[j].mesh.uv);
                combineInstances[j].mesh.uv = uvb;
            }
            shaderMesh = new Mesh();
            shaderMesh.CombineMeshes(combineInstances.ToArray(), true, false);
            shaderMesh.name = flag;
            for (int i = 0; i < combineInstances.Count; i++)
            {
                combineInstances[i].mesh.uv = oldUV[i];
            }

            GameObject body = new GameObject("body");

            body.layer = skeleton.layer;
            body.transform.parent = skeleton.transform;
            body.transform.localPosition = Vector3.zero;
            body.transform.eulerAngles = Vector3.zero;

            SkinnedMeshRenderer skr = body.AddComponent<SkinnedMeshRenderer>();
            skr.sharedMesh = shaderMesh;
            skr.bones = bones.ToArray();
            skr.sharedMaterial = newMaterial;
        }

        void RawTexture()
        {
            int xyMax = 512;
            SSTimer ss = new SSTimer("合图raw方式");
            Rect[] rec = new Rect[4];
            rec[0].xMin = 0; rec[0].xMax = 0.5f; rec[0].yMin = 0; rec[0].yMax = 0.5f;
            rec[1].xMin = 0.5f; rec[1].xMax = 1f; rec[1].yMin = 0f; rec[1].yMax = 0.5f;
            rec[2].xMin = 0f; rec[2].xMax = 0.5f; rec[2].yMin = 0.5f; rec[2].yMax = 1f;
            rec[3].xMin = 0.5f; rec[3].xMax = 1; rec[3].yMin = 0.5f; rec[3].yMax = 1f;
            //mergeTxMgr.Instance.getBlcokBytes(texture2s[0], 512);
            //mergeTxMgr.Instance.getBlcokBytes(texture2s[1], 512);
            //mergeTxMgr.Instance.getBlcokBytes(texture2s[2], 512);
            int blockByte = mergeTxMgr.Instance.getBlcokBytes(texture2s[3], 512);
            mergeTxMgr.Instance.getByteInTx(rec[0].xMin, rec[0].yMin, mergeTxMgr.Instance.data, blockByte, xyMax, texture2s[0]);
            mergeTxMgr.Instance.getByteInTx(rec[1].xMin, rec[1].yMin, mergeTxMgr.Instance.data, blockByte, xyMax, texture2s[1]);
            mergeTxMgr.Instance.getByteInTx(rec[2].xMin, rec[2].yMin, mergeTxMgr.Instance.data, blockByte, xyMax, texture2s[2]);
            mergeTxMgr.Instance.getByteInTx(rec[3].xMin, rec[3].yMin, mergeTxMgr.Instance.data, blockByte, xyMax, texture2s[3]);
            ss.Dispose();
            outTexture = new Texture2D(xyMax, xyMax, texture2s[0].format, false);
            outTexture.name = "raw__texture__512X512";
            outTexture.LoadRawTextureData(mergeTxMgr.Instance.data);
            outTexture.Apply(false, true);
        }
    }

}