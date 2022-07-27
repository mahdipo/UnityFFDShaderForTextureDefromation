Shader "testuv"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

	    _SKEW_DLX("Skew Down Left X",Float) = 0
		_SKEW_DLY("Skew Down Left Y",Float) = 0
		_SKEW_DRX("Skew Down Right X",Float) = 0
		_SKEW_DRY("Skew Down Right Y",Float) = 0
		_SKEW_ULX("Skew UP LEFT X",Float) = 0
		_SKEW_ULY("Skew UP LEFT Y",Float) = 0
		_SKEW_URX("Skew UP RIGHT X",Float) = 0
		_SKEW_URY("Skew UP RIGHT Y",Float) = 0

	     _wp12("warp p1_2",vector) = (0,0,0,0)
		 _wp34("warp p3_4",vector) = (0,0,0,0)
		 _wp56("warp p5_6",vector) = (0,0,0,0)
		 _wp78("warp p7_8",vector) = (0,0,0,0)
		 _wp910("warp p9_10",vector) = (0,0,0,0)
		 _wp1112("warp p11_12",vector) = (0,0,0,0)


		 _temp("temp",vector) = (0,0,0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			// vertex input: position, UV
		 struct appdata {
			 float4 vertex : POSITION;
			 float2 uv : TEXCOORD0;
		 };

		 struct v2f {
			 float4 vertex : SV_POSITION;
			 float2 uv : TEXCOORD0;
		 };

			float2 berneshtine(float2 p0, float2 p1, float2 p2, float2 p3, float t)
			{
				/*linePoints[i] = (Mathf.Pow(1 - t, 3) * points[0].transform.position) +
									(3*t * Mathf.Pow(1 - t, 2) * points[1].transform.position) +
									(3*(t*t) * (1 - t)* points[2].transform.position) +
									((t * t * t) * points[3].transform.position);
								*/

				return (pow(1 - t, 3) * p0) +
					(3 * t * pow(1 - t, 2) * p1) +
					(3 * (t * t) * (1 - t) * p2) +
					(pow(t, 3) * p3);

			}

						

			float2 QuadLerp(float2 ul, float2 ur, float2 dl, float2 dr, float x, float y)
			{
				float2 ulr = lerp(ul, ur, x);
				float2 dlr = lerp(dl, dr, x);
				return lerp(ulr, dlr, y);
			}
			

			//VB SAMPLE
			float2 perspectiveTRS2(float2 p0, float2 p1, float2 p2, float2 p3, float x, float y) {
				float b = (p1.x - p0.x);
				float d = p0.x;
				float c = (p2.x - p0.x);
				float a = (p3.x - (1) * c - d - (1) * b);
				float x2 = x * (y * a + b) + y * c + d;

				float b2 = (p2.y - p0.y) ;
				float d2 = p0.y;
				float c2 = (p1.y - p0.y) ;
				float a2 = (p3.y - (1) * b2 - (1) * c2 - d2) ;
				float y2 = y * (x * a2 + b2) + x * c2 + d2;

				return float2(x2, y2);
			}


			float2 projectiveTransformation(float xI,float yI, float2 sp0, float2 sp1, float2 sp2, float2 sp3,float2 dp0, float2 dp1, float2 dp2, float2 dp3)//sp and dp= source point and destenation points
			{
				float ADDING = 0.0001; // to avoid dividing by zero
				dp0.x += 0.00000001;
				
				float xA = sp0.x;
				float yA = sp0.y;

				float xC = sp2.x;
				float yC = sp2.y;

				float xAu = dp0.x;
				float yAu = dp0.y;

				float xBu = dp1.x;
				float yBu = dp1.y;

				float xCu = dp2.x;
				float yCu = dp2.y;

				float xDu = dp3.x;
				float yDu = dp3.y;

				// Calcultations
				// if points are the same, have to add a ADDING to avoid dividing by zero
				if (xBu == xCu) xCu += ADDING;
				if (xAu == xDu) xDu += ADDING;
				if (xAu == xBu) xBu += ADDING;
				if (xDu == xCu) xCu += ADDING;
				float kBC = (yBu - yCu) / (xBu - xCu);
				float kAD = (yAu - yDu) / (xAu - xDu);
				float kAB = (yAu - yBu) / (xAu - xBu);
				float kDC = (yDu - yCu) / (xDu - xCu);

				if (kBC == kAD) kAD += ADDING;
				float xE = (kBC * xBu - kAD * xAu + yAu - yBu) / (kBC - kAD);
				float yE = kBC * (xE - xBu) + yBu;

				if (kAB == kDC) kDC += ADDING;
				float xF = (kAB * xBu - kDC * xCu + yCu - yBu) / (kAB - kDC);
				float yF = kAB * (xF - xBu) + yBu;

				if (xE == xF) xF += ADDING;
				float kEF = (yE - yF) / (xE - xF);

				if (kEF == kAB) kAB += ADDING;
				float xG = (kEF * xDu - kAB * xAu + yAu - yDu) / (kEF - kAB);
				float yG = kEF * (xG - xDu) + yDu;

				if (kEF == kBC) kBC += ADDING;
				float xH = (kEF * xDu - kBC * xBu + yBu - yDu) / (kEF - kBC);
				float yH = kEF * (xH - xDu) + yDu;

				float rG = (yC - yI) / (yC - yA);
				float rH = (xI - xA) / (xC - xA);

				float xJ = (xG - xDu) * rG + xDu;
				float yJ = (yG - yDu) * rG + yDu;

				float xK = (xH - xDu) * rH + xDu;
				float yK = (yH - yDu) * rH + yDu;

				if (xF == xJ) xJ += ADDING;
				if (xE == xK) xK += ADDING;
				float kJF = (yF - yJ) / (xF - xJ); //23
				float kKE = (yE - yK) / (xE - xK); //12

				float xKE;
				if (kJF == kKE) kKE += ADDING;
				float xIu = (kJF * xF - kKE * xE + yE - yF) / (kJF - kKE);
				float yIu = kJF * (xIu - xJ) + yJ;

				
				float2 b =float2(xIu, yIu);
				//b.x = round(b.x);
				//b.y = round(b.y);
			
				return b;
			}



			float2 bilinearInterPolation(float2 p1, float2 p2, float2 p3, float2 p4, float x, float y) {
				return (1 - x)* ((1 - y) * p1 + y * p2) + x * ((1 - y) * p3 + y * p4);
			}

						
			float _SKEW_DLX, _SKEW_DLY;
			float _SKEW_DRX, _SKEW_DRY;
			float _SKEW_ULX, _SKEW_ULY;
			float _SKEW_URX, _SKEW_URY;

			vector _wp12;
			vector _wp34;
			vector _wp56;
			vector _wp78;
			vector _wp910;
			vector _wp1112;

			vector _temp;
			
			float4x4 unity_Projector;
			float4x4 unity_ProjectorClip;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				
				//warp 4corner 12 point bezier rectangle
					/*    p10(0,1)----p9(0.3,1)----p8(0.7,1)----p7(1,1)
							|                                      |
						  p11(0,0.7)                            p6(1,0.7)
							|                                      |
						  p12(0,0.3)  					        p5(1,0.3)
							|                                      |
						  p1(0,0)-----p2(0.3,0)----p3(0.7,0)----p4(1,0)
					*/

				float2 uv = v.uv;
				float2 p1 = _wp12.xy + float2(0, 0);
				float2 p2 = _wp12.zw + float2(0.3, 0);
				float2 p3 = _wp34.xy + float2(0.7, 0);
				float2 p4 = _wp34.zw + float2(1, 0);
				float2 p5 = _wp56.xy + float2(1, 0.3);
				float2 p6 = _wp56.zw + float2(1, 0.7);
				float2 p7 = _wp78.xy + float2(1, 1);
				float2 p8 = _wp78.zw + float2(0.7, 1);
				float2 p9 = _wp910.xy + float2(0.3, 1);
				float2 p10 = _wp910.zw + float2(0, 1);
				float2 p11 = _wp1112.xy + float2(0, 0.7);
				float2 p12 = _wp1112.zw + float2(0, 0.3);

				float2 brx = berneshtine(p1, p2, p3, p4, uv.x);
				float2 brx2 = berneshtine(p7, p8, p9, p10, 1 - uv.x);

				float2 bry = berneshtine(p4, p5, p6, p7, uv.y);
				float2 bry2 = berneshtine(p10, p11, p12, p1, 1 - uv.y);

				float2 xl = lerp(brx, brx2, uv.y);
				float2 yl = lerp(bry, bry2, 1 - uv.x);

				uv = lerp(xl, yl,uv-0.5);	 	
				//uv = lerp(xl, yl, uv);	 
				
				/*float2 ul = float2(0, 1) ;
				float2 ur = float2(1, 1) ;
				float2 dl = float2(0, 0) ;
				float2 dr = float2(1, 0) ;

				float2 sTop = lerp(ul, ur,  uv.x);
				float2 sBot = lerp(dl, dr,  uv.x);
				float2 uv1 = lerp(sBot, sTop, uv.y);

				float2 ul2 = float2(0, 1) - float2(_SKEW_ULX, _SKEW_ULY);
				float2 ur2 = float2(1, 1) - float2(_SKEW_URX, _SKEW_URY);
				float2 dl2 = float2(0, 0) - float2(_SKEW_DLX, _SKEW_DLY);
				float2 dr2 = float2(1, 0) - float2(_SKEW_DRX, _SKEW_DRY);							

				float2 sTop2 = lerp(ul2, ur2, uv.x);
				float2 sBot2 = lerp(dl2, dr2, uv.x);
				float2 uv2 = lerp(sBot2, sTop2, uv.y);					


				float2 t3 = lerp(sTop, sTop2,  uv.x);
				float2 b3 = lerp(sBot, sBot2,  uv.x);
				uv = lerp(t3, b3, 1-uv.y);*/
				//uv = lerp(uv1, uv2,  uv);

				/*
				float2 ul = float2(0, 1) - float2(_SKEW_ULX, _SKEW_ULY);
				float2 ur = float2(1, 1) - float2(_SKEW_URX, _SKEW_URY);
				float2 dl = float2(0, 0) - float2(_SKEW_DLX, _SKEW_DLY);
				float2 dr = float2(1, 0) - float2(_SKEW_DRX, _SKEW_DRY);							

				float2 sTop = lerp(ul, ur, 1-uv.x);
				float2 sBot = lerp(dl, dr, 1-uv.x);
				uv = lerp(sBot, sTop, 1-uv.y);		
				
				*/

				float minx = 0; float miny = 0;
				float maxx = 1; float maxy = 1;

					float2 ul = float2(minx, maxy) - float2(_SKEW_ULX, _SKEW_ULY);
					float2 ur = float2(maxx, maxy) - float2(_SKEW_URX, _SKEW_URY);
					float2 dl = float2(minx, miny) - float2(_SKEW_DLX, _SKEW_DLY);
					float2 dr = float2(maxx, miny) - float2(_SKEW_DRX, _SKEW_DRY);

					float2 sTop = lerp(ul, ur, maxx - uv.x);
					float2 sBot = lerp(dl, dr, maxx - uv.x);
					uv = lerp(sBot, sTop, maxy - uv.y);
				

				//SKEW 4 CORNER
					//UL Point
					//uv.x -= 1 - (1 / ((uv.y) * (1 - uv.x) * _SKEW_ULX + 1));
					//uv.y -= 1 - (1 / ((1 - uv.x) * (uv.y) * _SKEW_ULY + 1));				    
					//UR Point
					//uv.x *= (1 / (uv.y * _SKEW_URX + 1));
					//uv.y *= 1 / (uv.x * _SKEW_URY + 1);
					//DL Point
					//uv.x -= 1 - (1 / ((1 - uv.y) * (1 - uv.x) * _SKEW_DLX + 1));
					//uv.y -= 1 - (1 / ((1 - uv.x) * (1 - uv.y) * _SKEW_DLY + 1));
					//DR Point
					//uv.x *= (1 / ((1 - uv.y) * _SKEW_DRX + 1));
					//uv.x *= (1 / ((1 - uv.y) * _SKEW_DRX + 1));
					//uv.y *= 1 / (uv.x * _SKEW_DRY + 1);
					//uv.y -= 1 - (1 / ((uv.x) * (1 - uv.y) * _SKEW_DRY + 1));
					
				//if ((uv.x > 0.2 && uv.x < 0.8) || (uv.y > 0.3 && uv.y < 0.6))
					//uv = QuadLerp(ul, ur, dl, dr, uv.x, uv.y);
				//uv = projectiveTransformation(uv.y, uv.x, float2(0, 0), float2(0, 1), float2(1, 1), float2(1, 0), dl, ul, ur, dr);

				//uv = bilinearInterPolation(dl, ul, dr, ur, uv.x, uv.y);




                o.uv = uv;	

				
                return o;
            }

            sampler2D _MainTex;
			float4 _MainTex_ST;

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                fixed4 col = tex2D(_MainTex, uv);

                // just invert the colors
                col.rgb = col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
/*

/// Beier-Neely-Feature-Based-Image-Warp
			float2 Perpendicular(float2 vector2)
			{
				return float2(-vector2.y, vector2.x);
			}
			float2 CalculateUV(float2 lineStartPt,float2 lineEndPt, float2 X)
			{
				float u =length( dot((X - lineStartPt), (lineEndPt - lineStartPt)) / (lineEndPt - lineStartPt));// .sqrMagnitude;
				float v = length( dot((X - lineStartPt), Perpendicular(lineEndPt - lineStartPt)) / (lineEndPt - lineStartPt)) ;//  .magnitude;

				return float2(u, v);
			}


			float2 warpFreePoints(float2 uv,  List<Line> sourceLines, List<Line> destinationLines, int width, int height)
			{
				float2 xPixel = uv;
				float2 xPrimePixel;

				// DSUM = (0,0)
				// weightsum = 0
				float2 DSUM ;
				float weightSum = 0.0f;

				int lineIndex = 0;

				// Foreach Line in Pi Qi
				for (int i = 0; i < destinationLines.Count; i++)
				{
					// Calculate u,v based on Pi Qi
					UV uv = CalculateUV(destinationLines[i], xPixel);
					// Calculate Xi' based on u,v and Pi' Qi'
					xPrimePixel = CalculateXPrime(uv, sourceLines[lineIndex]);
					// Calculate displacement Di = Xi' - Xi for this line
					Vector2 Di = xPrimePixel - xPixel;
					// dist = shortest distance from X to PiQi
					float dist = 0;

					if (0 < uv.u && uv.u < 1)
					{
						dist = Mathf.Abs(uv.v);
					}
					else if (uv.u < 0)
					{
						dist = Vector2.Distance(xPixel, destinationLines[i].P());
					}
					else if (uv.u > 1)
					{
						dist = Vector2.Distance(xPixel, destinationLines[i].Q());
					}

					// weight = (length^p / (a + dist)))^b
					float weight = Mathf.Pow((Mathf.Pow(destinationLines[i].Length(), p) / (a + dist)), b);
					// DSUM += Di * weight
					DSUM += Di * weight;
					// weightSum += weight;
					weightSum += weight;

					lineIndex++;
				}


				// X' = X + DSUM / weightsum
				xPrimePixel = xPixel + DSUM / weightSum;

				// Lerp from the old source pixel to the destination
				destinationTexture.SetPixel(x, y, srcSprite.texture.GetPixel((int)Vector2.Lerp(xPixel, xPrimePixel, 0.5f).x, (int)Vector2.Lerp(xPixel, xPrimePixel, 0.5f).y));
			}

*/