using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace AQ
{
	public class BlitTextureCombiner : MonoBehaviour
	{
        public List<SkinnedMeshCombinerHolder> combineHolderList;
        public RenderTexture outTexture;
        public Texture2D[] texture2s;
        public Text text;

        void Start()
        {
            
        }

        public void StartCombine()
        {
            Blit();
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


        float totalScale = 1f;
        int MaxAtlasSize = 512;
        public Material rendererMaterial;
        public Rect[] rects;



        void Blit()
        {
            SSTimer ss = new SSTimer("合图Blit方式");

            outTexture = new RenderTexture(512, 512, 0, RenderTextureFormat.ARGB32);
            outTexture.name = "blit___texture_512X512";
            outTexture.useMipMap = true;

            var lastTarget = RenderTexture.active;
            RenderTexture.active = outTexture;

            GL.Clear(true, true, Color.clear);
            Vector4 textST = new Vector4();
            for(int i = 0; i < rects.Length; i++)
            {
                Rect r = rects[i];
                float tw = texture2s[i].width * totalScale;
                float th = texture2s[i].height * totalScale;
                textST.x = MaxAtlasSize / tw;
                textST.y = MaxAtlasSize / th;
                textST.z = -r.x / MaxAtlasSize * textST.x;
                textST.w = -r.y / MaxAtlasSize * textST.y;
                rendererMaterial.SetVector("_Tex_ST", textST);
                textST.x = textST.y = r.width / tw / 2;
                textST.z = textST.w = r.height / th / 2;
                rendererMaterial.SetVector("_Rect", textST);
                r.Set(r.x / MaxAtlasSize, r.y / MaxAtlasSize, tw / MaxAtlasSize, th / MaxAtlasSize);
                //rects[i] = r;
                rendererMaterial.mainTexture = texture2s[i];
                Graphics.Blit(texture2s[i], rendererMaterial);
            }
            RenderTexture.active = lastTarget;
            ss.Dispose();
        }
    }

}