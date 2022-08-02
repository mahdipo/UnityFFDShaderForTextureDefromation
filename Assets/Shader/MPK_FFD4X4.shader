Shader "Custom/MPK_FFD4X4"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

         _FFD4x3(" Use FFD4x3------------------------------------", int) = 0
         _ffd12("FFD p1_2",vector) = (0,0,0,0)
         _ffd34("FFD p3_4",vector) = (0,0,0,0)
         _ffd56("FFD p5_6",vector) = (0,0,0,0)
         _ffd78("FFD p7_8",vector) = (0,0,0,0)
         _ffd910("FFD p9_10",vector) = (0,0,0,0)
        _ffd1112("FFD p11_12",vector) = (0,0,0,0)

    }
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int _FFD4x3;
            vector _ffd12;
            vector _ffd34;
            vector _ffd56;
            vector _ffd78;
            vector _ffd910;
            vector _ffd1112;

            float power(float x, float y)
            {
                float p = 1;
                for (int i = 0; i < y; i++) {
                    p *= x;
                }
                return p;
            }

            float facto(int n) {
                float fac = 1;
                for (int i = n; i > 0; i--)
                    fac *= i;
                return fac;
            }


            // Returns the Bernstein polynomial in one parameter, u.
            float bernsteinP(int n, int k, float u) {
                // Binomial coefficient
                float coeff = facto(n) / ((facto(k) * facto(n - k)));
                return coeff * power(1.0 - u, n - k) * power(u, k);
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.uv;

                if (_FFD4x3 == 1)
                {

                    /*
                         3       6       9      12

                         2       5       8      11

                         1       4       7      10
                    */

                    float2 pt1 = float2(0.0, 0.0) - _ffd12.xy;
                    float2 pt2 = float2(0.0, 0.5) - _ffd12.zw;
                    float2 pt3 = float2(0.0, 1.0) - _ffd34.xy;

                    float2 pt4 = float2(0.33, 0.0) - _ffd34.zw;
                    float2 pt5 = float2(0.33, 0.5) - _ffd56.xy;
                    float2 pt6 = float2(0.33, 1.0) - _ffd56.zw;

                    float2 pt7 = float2(0.66, 0.0) - _ffd78.xy;
                    float2 pt8 = float2(0.66, 0.5) - _ffd78.zw;
                    float2 pt9 = float2(0.66, 1.0) - _ffd910.xy;

                    float2 pt10 = float2(1.0, 0.0) - _ffd910.zw;
                    float2 pt11 = float2(1.0, 0.5) - _ffd1112.xy;
                    float2 pt12 = float2(1.0, 1.0) - _ffd1112.zw;

                    float4x3 pointsX = { pt1.x,pt2.x, pt3.x, pt4.x, pt5.x, pt6.x, pt7.x, pt8.x, pt9.x, pt10.x, pt11.x,pt12.x };
                    float4x3 pointsY = { pt1.y,pt2.y, pt3.y, pt4.y, pt5.y, pt6.y, pt7.y, pt8.y, pt9.y, pt10.y, pt11.y,pt12.y };


                    float4x3 pointsXOrginal = { 0,0,0
                                               ,0.33,0.33,0.33
                                               ,0.66,0.66,0.66
                                               ,1,1,1 };

                    float4x3 pointsYOrginal = { 0,0.5,1
                                                ,0,0.5,1
                                                ,0,0.5,1
                                                ,0,0.5,1 };

                    int l = 4;
                    int m = 3;

                    float2 ts = float2(0, 0);
                    for (int i = 0; i < l; i++)//0-4
                    {
                        float2 tm = float2(0, 0);
                        for (int j = 0; j < m; j++)//0-3
                        {
                            tm += bernsteinP(m - 1, j, uv.y) * float2(pointsX[i][j], pointsY[i][j]);
                        }
                        ts += bernsteinP(l - 1, i, uv.x) * tm;
                    }
                    uv = ts;


                }
                o.uv = -uv;              
                return o;
            }

          

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, (i.uv+ _MainTex_ST.zw)* _MainTex_ST.xy);
                // just invert the colors
                col.rgb =col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
