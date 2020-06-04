using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace AQ
{
    [Serializable]
    public class SkinnedMeshCombinerHolder
    {
        public CharacterCombine.StringHolder stringHolder;
        public Mesh mesh;
        public Material material;
    }

    public class PackTextureCombiner : MonoBehaviour
	{
        public List<SkinnedMeshCombinerHolder> combineHolderList;
        public Texture2D[] texture2s;
        public Text text;

        void Start()
        {
            
        }

        public void StartCombine()
        {
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
        bool allowUsageOfLocalCache = false;
        string COMBINE_DIFFUSE_TEXTURE = "_MainTex";
        static int maxnumsize = 1024;


        /** 合并蒙皮，合并纹理
         *  纹理需要打开读写
         */
        void CombineObject(GameObject skeleton, int combine_size)
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
            Texture2D newDiffuseTex = null;

            SSTimer ss = new SSTimer("合图Pack方式");
            newDiffuseTex = new Texture2D(combine_size, combine_size, format, true);
            newDiffuseTex.name = "packtexture__texture_512X512";
            newMaterial.mainTexture = newDiffuseTex;
            Rect[]uvs = newDiffuseTex.PackTextures(Textures.ToArray(), 0, maxnumsize, true);
            ss.Dispose();
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
    }

}