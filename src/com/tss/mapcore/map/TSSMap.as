package com.tss.mapcore.map
{
	import com.esri.ags.Map;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMoveEvent;
	import com.tss.mapcore.events.TSSMapEvent;
	import com.tss.mapcore.map.TSSEsriMap;
	import com.tss.mapcore.map.TSSGoogleMap;
	import com.tss.mapcore.map.TSSGoogleMap3D;
	import com.tss.mapcore.util.PointTest;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	
	import spark.components.BorderContainer;
	import spark.components.Panel;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.VGroup;
	
	/*
	Top level map component that can be dropped in any layout.  This component extends the Canvas class
	and allows the developer to switch between an Esri Flex map, 2D Google map and 3D Google map
	*/
	public class TSSMap extends BorderContainer
	{
		private var masterMapLayout:VGroup;
		private var mapTypeGroup:RadioButtonGroup
		private var googleTypeButton:RadioButton;
		private var googleType3DButton:RadioButton;
		private var esriTypeButton:RadioButton;
		private var googleMap:TSSGoogleMap;
		private var googleMap3D:TSSGoogleMap3D;
		private var esriMap:TSSEsriMap;
		private var mType:Number = -1;
		private var spatialRef:Number;
		private var baseLayer:String;
		private var iMinx:Number;
		private var iMiny:Number;
		private var iMaxx:Number;
		private var iMaxy:Number;
		private var iX:Number;
		private var iY:Number;
		private var iLevel:Number;
		private var overlayLine:ArrayCollection;
		private var _overlayPolygons:ArrayCollection;
		private var polyArray:Array = new Array();
		private var gScaleList:ArrayList = new ArrayList();
		private var canvas:BorderContainer = new BorderContainer();
		private var hlcanvas:BorderContainer = new BorderContainer();
		private var selCounty:Number = -1;
		private var _assetList:Object = new Object();
		
		/*
		Constructor that sets up all of the internal components - No Arguments
		*/
		public function TSSMap()
		{
			super();
			masterMapLayout = new VGroup();
			//masterMapLayout.y = -29;
			//masterMapLayout.layout = "vertical";
			masterMapLayout.percentHeight = 100;
			masterMapLayout.percentWidth = 100;
			
			this.addElement(masterMapLayout);
			mapTypeGroup = new RadioButtonGroup();
			googleTypeButton = new RadioButton();
			googleType3DButton = new RadioButton();
			esriTypeButton = new RadioButton();
			googleTypeButton.label = "Google Maps";
			googleTypeButton.group = mapTypeGroup;
			googleTypeButton.right = 5;
			esriTypeButton.label = "Esri Maps";
			esriTypeButton.group = mapTypeGroup;
			esriTypeButton.right = 240;
			googleType3DButton.label = "3D Google Maps";
			googleType3DButton.group = mapTypeGroup;
			googleType3DButton.right = 110;
			googleType3DButton.addEventListener(MouseEvent.CLICK, setGoogle3DMap);
			googleTypeButton.addEventListener(MouseEvent.CLICK, setGoogleMap);
			esriTypeButton.addEventListener(MouseEvent.CLICK, setEsriMap);
			this.addElement(googleType3DButton);
			this.addElement(googleTypeButton);
			this.addElement(esriTypeButton);
			
			setMapTypeControlVisible(false);
			
			gScaleList.addItem(591657550.5);
			gScaleList.addItem(295828775.3);
			gScaleList.addItem(147914387.6);
			gScaleList.addItem(73957193.82);
			gScaleList.addItem(36978596.91);
			gScaleList.addItem(18489298.45);
			gScaleList.addItem(9244649.227);
			gScaleList.addItem(4622324.614);
			gScaleList.addItem(2311162.307);
			gScaleList.addItem(1155581.153);
			gScaleList.addItem(577790.5767);
			gScaleList.addItem(288895.2884);
			gScaleList.addItem(144447.644200);
			gScaleList.addItem(72223.822090);
			gScaleList.addItem(36111.911040);
			gScaleList.addItem(18055.95552);
			gScaleList.addItem(9027.977761);
			gScaleList.addItem(4513.98888);
			gScaleList.addItem(2256.99444);
			gScaleList.addItem(1128.49722);
			
			canvas.x=0;
			canvas.y=0;
			canvas.height=masterMapLayout.height;
			canvas.width=masterMapLayout.width;
			canvas.visible=true;
			canvas.setStyle("backgroundAlpha",0);
			canvas.setStyle("contentBackgroundAlpha",0);
			canvas.mouseEnabled = false;
			canvas.mouseChildren = false;
			
			hlcanvas.x=0;
			hlcanvas.y=0;
			hlcanvas.height=masterMapLayout.height;
			hlcanvas.width=masterMapLayout.width;
			hlcanvas.visible=true;
			hlcanvas.setStyle("backgroundAlpha",0);
			hlcanvas.setStyle("contentBackgroundAlpha",0);
			hlcanvas.mouseEnabled = false;
			hlcanvas.mouseChildren = false;
			
			//setMaptype(0);
		}
		
		public function idPolygon(x:Number, y:Number):Number
		{
			//Alert.show("got the event");
			var tmpPoint:Point = new Point(x,y);
			for (var k:int=0;k<polyArray.length;k++)
			{
				var tmpArray:Array = polyArray[k] as Array;
				var isInside:Boolean = insidePolygon(tmpArray, tmpPoint);
				if (isInside)
				{
					//Alert.show("In county " + k);
					addHighlightPolygon(1,0X00FF00, 0X00FF00, .2, k);
					selCounty = k;
					return selCounty;
					break;
				}
			}
			return -1;
		}
		
		/*
		Sets the current map type instance.  (0-Esri, 1-2D Google, 2-3D Google)
		ToDo: keep the current map extent when switching.
		*/

		public function get overlayPolygons():ArrayCollection
		{
			return _overlayPolygons;
		}

		public function set overlayPolygons(value:ArrayCollection):void
		{
			_overlayPolygons = value;
			for (var k:int=0;k<overlayPolygons.length;k++)
			{
				var tmpPoly:Object = overlayPolygons[k];
				var tmpPArray:Array = new Array();
				for (var i:int=0;i<tmpPoly.COORDS.length;i++)
				{
					var tmpPointTest:PointTest = new PointTest();
					tmpPointTest.x = tmpPoly.COORDS[i].X;
					tmpPointTest.y = tmpPoly.COORDS[i].Y;
					tmpPArray[i] = tmpPointTest;
				}
				polyArray[k] = tmpPArray;
			}
		}

		public function setMaptype(mapType:Number):void
		{
			if (!esriTypeButton.selected && !googleTypeButton.selected)
			{
				if (mapType == 0)
				{
					esriTypeButton.selected = true;
				} else if (mapType == 1)
				{
					googleTypeButton.selected = true;
				} else
				{
					googleType3DButton.selected = true;
				}
			}
			if (mapType != mType && masterMapLayout.numChildren > 0)
			{
				if (mType == 0 && (mapType == 1 || mapType == 2))
				{
					iX = esriMap.getMap.extent.center.x;
					iY = esriMap.getMap.extent.center.y;
					iLevel = getLevelFromScale(esriMap.getMap.scale);
				} else if ((mType == 1 || mType == 2) && mapType == 0)
				{
					iMinx = googleMap.gmap.getLatLngBounds().getEast();
					iMaxx = googleMap.gmap.getLatLngBounds().getWest();
					iMaxy = googleMap.gmap.getLatLngBounds().getNorth();
					iMiny = googleMap.gmap.getLatLngBounds().getSouth();
				}
				masterMapLayout.removeAllElements();
			}
			if (mapType != mType)
			{
				if (mapType == 0)
				{
					
					esriMap = new TSSEsriMap(iMinx,iMiny,iMaxx,iMaxy,spatialRef,baseLayer);
					//esriMap.getMap.addEventListener(com.esri.ags.events.ExtentEvent.EXTENT_CHANGE, regenerateOverlay);
					masterMapLayout.addElement(esriMap.getMap);
					masterMapLayout.addElement(canvas);
					masterMapLayout.addElement(hlcanvas);
				} else if (mapType == 1)
				{
					googleMap = new TSSGoogleMap(iY, iX, iLevel);
					//googleMap.gmap.addEventListener(com.google.maps.MapMoveEvent.MOVE_END, regenerateOverlayG);
					masterMapLayout.addElement(googleMap);
					masterMapLayout.addElement(canvas);
					masterMapLayout.addElement(hlcanvas);
				} else if (mapType == 2)
				{
					googleMap3D = new TSSGoogleMap3D(iY, iX, iLevel);
					masterMapLayout.addElement(googleMap3D);
					masterMapLayout.addElement(canvas);
					masterMapLayout.addElement(hlcanvas);
				}
			mType = mapType;
			}
			
		}
		
		public function regenerateOverlay(e:ExtentEvent):void
		{
			this.addPolygons(1, 0X0000FF, 0X0000FF, .3);
			if (selCounty > -1)
				addHighlightPolygon(1,0X00FF00, 0X00FF00, .2, selCounty);
		}
		
		public function regenerateOverlayG(e:MapMoveEvent):void
		{
			this.addPolygons(1, 0X0000FF, 0X0000FF, .3);
			if (selCounty > -1)
				addHighlightPolygon(1,0X00FF00, 0X00FF00, .2, selCounty);
		}
		 
		/*
		Add a dynamic point to the map.  Accepts x,y and orientation.  Name should be a unique name for the point
		*/
		public function addTrackingPoint(x:Number, y:Number, angle:Number, name:String):void
		{
			if (mType == 0)
			{
				esriMap.addTrackingPoint(x,y,angle,name);
			} else if (mType == 1)
			{
				googleMap.addTrackingPoint(x,y,angle);
			} else if (mType == 2)
			{
				googleMap3D.addTrackingPoint(x,y,angle);
			}
		}
		
		/*
		Move the dynamic point of the specified name
		*/
		public function positionTrackingPoint(x:Number, y:Number, angle:Number, name:String):void
		{
			if (mType == 0)
			{
				esriMap.positionTrackingPoint(x,y,angle, name);
			} else if (mType == 1)
			{
				googleMap.positionTrackingPoint(x,y,angle);
			} else if (mType == 2)
			{
				googleMap3D.positionTrackingPoint(x,y,angle);
			}
		}
		
		/*
		Pan to the new x,y
		*/
		public function setCenter(x:Number, y:Number):void
		{
			if (mType == 0)
			{
				esriMap.centerAt(x,y);
			} else if (mType == 1)
			{
				googleMap.setMapCenter(x,y);
			} else if (mType == 2)
			{
				googleMap3D.setMapCenter(x,y);
			}
		}
		
		/*
		Set the explicit map extent - Only good for Esri map
		*/
		public function setMapExtent(minx:Number, miny:Number, maxx:Number, maxy:Number):void
		{
			if (mType == 0)
			{
				esriMap.setMapExtent(minx, miny, maxx, maxy);
			}
		}
		
		public function getMapExtent():Extent
		{
			return esriMap.getMap.extent;
			//return WebMercatorUtil.webMercatorToGeographic(esriMap.getMap.extent) as Extent;
		}
		
		public function getMapCenter():MapPoint
		{
			return esriMap.getMap.extent.center;
		}
		/*
		Add a linear feature passing in an ordered array of coordinate pairs
		ToDo: Add support for the optimized arrays for Google.
		*/
		public function addOverlay(line:ArrayCollection):void
		{
			overlayLine = line;
			if (mType == 0)
			{
				esriMap.addOverlay(line);
			} else if (mType == 1)
			{
				
			} else if (mType == 2)
			{
				
			}
		}
		
		/*
		Clear all dynamic lines and points
		*/
		public function clearOverlays():void
		{
			if (mType == 0)
			{
				esriMap.clearOverlays();
			} else if (mType == 1)
			{
				googleMap.clearOverlays();
			} else if (mType == 2)
			{
				googleMap3D.clearOverlays();
			}
		}
		
		/*
		Clear a specific dynamic point
		*/
		public function clearTrackingPoint(name:String):void
		{
			if (mType == 0)
			{
				esriMap.clearTrackingPoint(name);
			}
		}
		
		/*
		Set the initial map extent.  Esri only.
		*/
		public function setInitialMapExtent(minx:Number, miny:Number, maxx:Number, maxy:Number):void
		{
			iMinx=minx;
			iMiny=miny;
			iMaxx=maxx;
			iMaxy=maxy;
		}
		
		/*
		Set the map spatial reference.  Esri only.
		*/
		public function setSpatialReference(spref:Number):void
		{
			spatialRef=spref;
		}
		
		/*
		Set the base map layer.  Esri only.
		*/
		public function setBaseLayer(layer:String):void
		{
			baseLayer = layer;
		}
		
		/*
		Set the initial map center.  Google only.
		*/
		public function setInitialCenter(y:Number,x:Number, level:Number):void
		{
			iX=x;
			iY=y;
			iLevel=level;
		}
		
		/*
		Function for the google 3d radio button
		*/
		private function setGoogle3DMap(event:Event):void {
			this.setMaptype(2);
		}
		
		/*
		Function for the google 2d radio button
		*/
		private function setGoogleMap(event:Event):void {
			this.setMaptype(1);
		}
		
		/*
		Function for the Esri radio button
		*/
		private function setEsriMap(event:Event):void {
			this.setMaptype(0);
			//this.addPolygons( 1, 0X0000FF, 0X0000FF, .3);
		}
		
		/*
		Function to show or hide the map type radio buttons
		*/
		public function setMapTypeControlVisible(value:Boolean):void
		{
			esriTypeButton.visible = value;		
			googleTypeButton.visible = value;
			googleType3DButton.visible = value;
		}
		
		public function addMouseEvent(type:String, callMethod:String):void
		{
				
		}
		
		
		// Convert esri map scale to google map level
		public function getLevelFromScale(scale:Number):int
		{
			var retVal:int = -1;
			
			if (scale >= gScaleList.getItemAt(0))
			{
				retVal = 0;
			} else if (scale <= gScaleList.getItemAt(gScaleList.length-1))
			{
				retVal = gScaleList.length-1;
			} else
			{
				for (var i:int=1;i<gScaleList.length - 1;i++)
				{
					var tmpScaleLow:Number = gScaleList.getItemAt(i-1) as Number;
					var tmpScaleHigh:Number = gScaleList.getItemAt(i) as Number;
					if (scale > tmpScaleHigh && scale <= tmpScaleLow)
					{
						retVal = i;
						break;
					}
				}
			}
			return retVal;
		}
		
		/*
		Add a polygon feature passing in an ordered array of coordinate pairs
		ToDo: Add support for the optimized arrays for Google.
		*/
		public function addPolygons( boundarywidth:Number, boundarycolor:Number, fillcolor:Number, opacity:Number):void
		{
			canvas.graphics.clear();
			canvas.height=masterMapLayout.height;
			canvas.width=masterMapLayout.width;
			canvas.graphics.lineStyle(boundarywidth,0x0000FF,1);
			for (var k:int=0;k<overlayPolygons.length;k++)
			{
				var tmpPoly:Object = overlayPolygons[k];
				canvas.graphics.beginFill(0x0000FF, opacity);
				
				canvas.graphics.moveTo(longToMapX(tmpPoly.COORDS[0].X), latToMapY(tmpPoly.COORDS[0].Y));
				//trace(longToMapX(tmpPoly.COORDS[0].X), latToMapY(tmpPoly.COORDS[0].Y));
				for (var i:int=1;i<tmpPoly.COORDS.length;i++)
				{
					canvas.graphics.lineTo(longToMapX(tmpPoly.COORDS[i].X), latToMapY(tmpPoly.COORDS[i].Y));
					//trace(longToMapX(tmpPoly.COORDS[i].X), latToMapY(tmpPoly.COORDS[i].Y));
				}
				canvas.graphics.lineTo(longToMapX(tmpPoly.COORDS[0].X), latToMapY(tmpPoly.COORDS[0].Y));
				canvas.graphics.endFill();
			}
		}
		
		/*
		Add a polygon feature passing in an ordered array of coordinate pairs
		ToDo: Add support for the optimized arrays for Google.
		*/
		public function addHighlightPolygon( boundarywidth:Number, boundarycolor:Number, fillcolor:Number, opacity:Number, polyNum:Number):void
		{
			hlcanvas.graphics.clear();
			hlcanvas.height=masterMapLayout.height;
			hlcanvas.width=masterMapLayout.width;
			hlcanvas.graphics.lineStyle(boundarywidth,0x00FF00,1);
			for (var k:int=0;k<overlayPolygons.length;k++)
			{
				if (k == polyNum)
				{
					var tmpPoly:Object = overlayPolygons[k];
					hlcanvas.graphics.beginFill(0x00FF00, opacity);
					
					hlcanvas.graphics.moveTo(longToMapX(tmpPoly.COORDS[0].X), latToMapY(tmpPoly.COORDS[0].Y));
					for (var i:int=1;i<tmpPoly.COORDS.length;i++)
					{
						hlcanvas.graphics.lineTo(longToMapX(tmpPoly.COORDS[i].X), latToMapY(tmpPoly.COORDS[i].Y));
					}
					hlcanvas.graphics.lineTo(longToMapX(tmpPoly.COORDS[0].X), latToMapY(tmpPoly.COORDS[0].Y));
					hlcanvas.graphics.endFill();
				}
			}
		}
		
		// Calculate x value in pixels from a longitude value
		private function longToMapX(long:Number):Number
		{
			var currMinx:Number;
			var currMiny:Number;
			var currMaxx:Number;
			var currMaxy:Number;
			
			if (mType == 0 )
			{
				currMinx = esriMap.getMap.extent.xmin;
				currMaxx = esriMap.getMap.extent.xmax;
				currMiny = esriMap.getMap.extent.ymin;
				currMaxy = esriMap.getMap.extent.ymax;
			} else
			{
				currMinx = googleMap.gmap.getLatLngBounds().getWest();
				currMaxx = googleMap.gmap.getLatLngBounds().getEast();
				currMaxy = googleMap.gmap.getLatLngBounds().getNorth();
				currMiny = googleMap.gmap.getLatLngBounds().getSouth();
			}
			
			
			if (long <= currMaxx && long >= currMinx)
			{
				var tmpDif:Number = long - currMinx;
				var tmpPerc:Number = tmpDif / (currMaxx - currMinx);
				return masterMapLayout.width * tmpPerc;
			} else
			{
				if (long > currMaxx)
				{
					return masterMapLayout.width;
				} else if (long < currMinx)
				{
					return 0;
				}
			}
			
			return -1;
		}
		
		// Calculate y value in pixels from a latitude value
		private function latToMapY(lat:Number):Number
		{
			
			var currMinx:Number;
			var currMiny:Number;
			var currMaxx:Number;
			var currMaxy:Number;
			
			if (mType == 0 )
			{
				currMinx = esriMap.getMap.extent.xmin;
				currMiny = esriMap.getMap.extent.ymin;
				currMaxx = esriMap.getMap.extent.xmax;
				currMaxy = esriMap.getMap.extent.ymax;
			} else
			{
				currMinx = googleMap.gmap.getLatLngBounds().getEast();
				currMaxx = googleMap.gmap.getLatLngBounds().getWest();
				currMaxy = googleMap.gmap.getLatLngBounds().getNorth();
				currMiny = googleMap.gmap.getLatLngBounds().getSouth();
			}
			
			if (lat <=currMaxy && lat >= currMiny)
			{
				var tmpDif:Number = currMaxy - lat;
				var tmpPerc:Number = tmpDif / (currMaxy - currMiny);
				return masterMapLayout.height * tmpPerc;
			} else
			{
				if (lat > currMaxy)
				{
					 return 0;
				} else if (lat < currMiny)
				{
					return masterMapLayout.height;	
				}
			}
			return -1;
		}
		
		private function insidePolygon(pointList:Array, p:Point):Boolean
		{
			var counter:int = 0;
			var i:int;
			var xinters:Number;
			var p1:PointTest;
			var p2:PointTest;
			var n:int = pointList.length;
			
			p1 = pointList[0];
			for (i = 1; i <= n; i++)
			{
				p2 = pointList[i % n];
				if (p.y > Math.min(p1.y, p2.y))
				{
					if (p.y <= Math.max(p1.y, p2.y))
					{
						if (p.x <= Math.max(p1.x, p2.x))
						{
							if (p1.y != p2.y) {
								xinters = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
								if (p1.x == p2.x || p.x <= xinters)
									counter++;
							}
						}
					}
				}
				p1 = p2;
			}
			if (counter % 2 == 0)
			{
				return(false);
			}
			else
			{
				return(true);
			}
		}
		
		public function drawAssets(x:Number, y:Number, sprite:Sprite):void
		{
			esriMap.drawAssets(sprite,x,y);
		}	
		
		public function addEsriAssetOverlay(assetList:Object):void
		{
			this._assetList = assetList;
			clearOverlays();
			var isEmpty:Boolean = true;
			for (var n:String in _assetList) {isEmpty = false; break;}
			
			if(!isEmpty)
			{
				for(var type:String in _assetList) // cautious....
				{
					for(var i:int=0; i <_assetList[type].length; i ++)
					{
						drawAssets(_assetList[type][i].x, _assetList[type][i].y, _assetList[type][i].sprite as Sprite); 
					}
				}
			}
		}
	}
}