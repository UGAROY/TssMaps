package com.tss.mapcore.map
{
	import com.asfusion.mate.events.Dispatcher;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.events.MapMouseEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.tss.mapcore.events.*;
	
	import flash.display.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Image;
	
	public class TSSEsriMap extends BorderContainer
	{
		private var vMap:com.esri.ags.Map;
		private var vLayer:ArcGISDynamicMapServiceLayer;
		private var vGraphicsLayer:GraphicsLayer;
		private var tpGraphic:Graphic;
		private var bpGraphic:Graphic;
		private var epGraphic:Graphic;
		private var lGraphic:Graphic;
		private var mapLayout:HGroup;
		//private var initialExtent:com.esri.ags.geometry.Extent;
		private var initialExtent:Extent;
		private var spatialRef:Number;
		private var iMinx:Number;
		private var iMiny:Number;
		private var iMaxx:Number;
		private var iMaxy:Number;
		private var baseLayer:String;
		private var tpImage:Image = new Image();
		private var dispatcher:Dispatcher = new Dispatcher();
		
		private var assetSymbol:CustomSymbol;
		private var assetGraphic:Graphic;
		
		public function TSSEsriMap(minx:Number, miny:Number, maxx:Number, maxy:Number, spref:Number, baselayer:String)
		{
			mapLayout = new HGroup();
			//mapLayout.layout = "horizontal";
			this.percentWidth = 100;
			this.percentHeight = 100;
			mapLayout.percentWidth = 100;
			mapLayout.percentHeight = 100;
			vMap = new com.esri.ags.Map();
			vMap.percentWidth=100;
			vMap.percentHeight = 100;
			iMinx=minx;
			iMiny=miny;
			iMaxx=maxx;
			iMaxy=maxy;
			spatialRef=spref;
			
			/*if(spatialRef == 4326)
				initialExtent = new WebMercatorExtent(iMinx,iMiny, iMaxx,iMaxy);
			else*/
				initialExtent = new Extent(iMinx,iMiny, iMaxx,iMaxy, new SpatialReference(spatialRef));
			
			vMap.extent = initialExtent;	
			
			
			baseLayer = baselayer;
			vLayer = new ArcGISDynamicMapServiceLayer(baseLayer);

			vMap.addLayer(vLayer);
			vGraphicsLayer = new GraphicsLayer();
			vMap.addLayer(vGraphicsLayer);
			mapLayout.addElement(vMap);
			
			addElement(mapLayout);
			vMap.zoomSliderVisible = false;
			vMap.scaleBarVisible = false;
			vMap.addEventListener(MapMouseEvent.MAP_CLICK,handleMapClick);
			//vMap.zoomSliderVisible = true;
			
			
		}
		
		public function addTrackingPoint(x:Number, y:Number, angle:Number, name:String):void
		{	
			// PictureMarker - embedded image
			[Embed('images/vlog/car.jpg')]
			var picEmbeddedClass:Class;
			var pictureMarker:PictureMarkerSymbol = new PictureMarkerSymbol(picEmbeddedClass);
			
			
			if (name == "current")
			{
				tpGraphic = new Graphic(new MapPoint(x, y, new SpatialReference(spatialRef)));
				var outlineSym:SimpleLineSymbol = new SimpleLineSymbol("solid", 0x000000);
				tpGraphic.symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 10, 0xFFFF00, 1,0, 0, 0, outlineSym);
				tpGraphic.rotation = angle;
				tpGraphic.name = name;
				vGraphicsLayer.add(tpGraphic);
				
				var newwidth:Number = vMap.extent.width * .1;
				var newheight:Number = vMap.extent.height * .1;
				
				var newminx:Number = vMap.extent.xmin + newwidth;
				var newminy:Number = vMap.extent.ymin + newheight;
				var newmaxx:Number = vMap.extent.xmax - newwidth;
				var newmaxy:Number = vMap.extent.ymax - newheight;
				var tmppnt:MapPoint = new MapPoint(x, y, new SpatialReference(spatialRef));
				var newextent:Extent = new Extent(newminx,newminy,newmaxx,newmaxy);
				if (!newextent.contains(tmppnt))
				{
					vMap.centerAt(tmppnt);
				}
			} else if (name == "beginning")
			{
				bpGraphic = new Graphic(new MapPoint(x, y, new SpatialReference(spatialRef)));
				bpGraphic.symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_DIAMOND, 12, 0x32CD32);
				bpGraphic.rotation = angle;
				bpGraphic.name = name;
				vGraphicsLayer.add(bpGraphic);
			} else if (name == "end")
			{
				epGraphic = new Graphic(new MapPoint(x, y, new SpatialReference(spatialRef)));
				epGraphic.symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_DIAMOND, 12, 0x32CD32);
				epGraphic.rotation = angle;
				epGraphic.name = name;
				vGraphicsLayer.add(epGraphic);
			}
			
			
			
		}
		
		public function positionTrackingPoint(x:Number, y:Number, angle:Number, name:String):void
		{
			var tmppnt:MapPoint = new MapPoint(x, y, new SpatialReference(spatialRef));
			vGraphicsLayer.remove(tpGraphic);
			addTrackingPoint(x,y,angle, name);
			
			
			var newwidth:Number = vMap.extent.width * .1;
			var newheight:Number = vMap.extent.height * .1;
			
			var newminx:Number = vMap.extent.xmin + newwidth;
			var newminy:Number = vMap.extent.ymin + newheight;
			var newmaxx:Number = vMap.extent.xmax - newwidth;
			var newmaxy:Number = vMap.extent.ymax - newheight;
			
			var newextent:Extent = new Extent(newminx,newminy,newmaxx,newmaxy);
			if (!newextent.contains(tmppnt))
			{
				vMap.centerAt(tmppnt);
			}
			
		}
		
		public function addOverlay(line:ArrayCollection):void
		{
			var mpArray:Array = new Array();
			var tmpcnt:int;
			for (tmpcnt=0;tmpcnt<line.length;tmpcnt++)
			{
				var tmpmp:MapPoint = new MapPoint(line[tmpcnt].X, line[tmpcnt].Y,new SpatialReference(spatialRef));
				mpArray[tmpcnt] = tmpmp;
			}
			vGraphicsLayer.remove(lGraphic);
			var outerArray:Array = new Array();
			outerArray[0] = mpArray;
			var tmpLine:Polyline = new Polyline(outerArray, new SpatialReference(spatialRef));
			lGraphic = new Graphic(tmpLine);
			
			lGraphic.symbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, 0x000099, 1.0, 4);		
			vGraphicsLayer.add(lGraphic);
		}
		
		public function clearOverlays():void
		{
			vGraphicsLayer.clear();
		}
		
		public function clearTrackingPoint(name:String):void
		{
			
			if (name == "current")
			{
				vGraphicsLayer.remove(tpGraphic);
			}
		}
		
		public function centerAt(x:Number, y:Number):void
		{
			var tmppnt:MapPoint = new MapPoint(x, y, new SpatialReference(spatialRef));
			vMap.centerAt(tmppnt);
		}
		
		public function setMapExtent(minx:Number, miny:Number, maxx:Number, maxy:Number):void
		{
			initialExtent = new Extent(minx,miny,maxx,maxy, new SpatialReference(spatialRef));
			vMap.extent = initialExtent;
		}
		
		
		
		public function get getMap():Map
		{
			return vMap;
		}

		
		private function handleMapClick(event:MapMouseEvent):void{
			/*var latlong:MapPoint = WebMercatorUtil.webMercatorToGeographic(event.mapPoint) as MapPoint;
			vMap.infoWindow.label = "You clicked at "
				+ event.mapPoint.x.toFixed(1) + " / " + event.mapPoint.y.toFixed(1)
				+ "\nLat/Long is: " + latlong.y.toFixed(6)
				+ " / " + latlong.x.toFixed(6);*/
			//vMap.infoWindow.show(event.mapPoint); // "Show the click"
			
			try 
			{		
				/*var tssmap:TSSMap = this.parent as TSSMap;
				tssmap.idPolygon(event.localX, event.localY);*/
				
				var mapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.CLICKED, true, true);
				mapEvent.x = event.mapPoint.x;
				mapEvent.y = event.mapPoint.y;
				dispatcher.dispatchEvent(mapEvent);
			}
			catch(error:TypeError){
				//catch the occassional type error obtained when clicked on the menu container outside the item
			}
			
		}
		
		public function drawAssets(sprite:Sprite, x:Number, y:Number):void
		{
			var tmpMapPoint:MapPoint = new MapPoint(x, y, new SpatialReference(spatialRef));
			
			assetSymbol = new CustomSymbol(sprite);
			
			assetGraphic = new Graphic(tmpMapPoint, assetSymbol);
			
			vGraphicsLayer.add(assetGraphic);
		}
	}
}