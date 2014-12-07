package com.tss.mapcore.map
{
	import com.asfusion.mate.events.Dispatcher;
	import com.tss.mapcore.events.TSSMapEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.CustomMarker;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Bounds;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Image;
	
	
	
	
	public class TSSOSMMap extends BorderContainer
	{
		private var mapLayout:HGroup;
		private var map:Map;
		private var tpInitialized:Boolean = false;
		private var iX:Number;
		private var iY:Number;
		private var iLevel:Number;
		private var tpSprite:Sprite;
		private var tpImage:Image = new Image();
		private var dispatcher:Dispatcher = new Dispatcher();
		
		//[Embed(source="assets/car.jpg")] protected var purpleIcon:Class
		
		public function TSSOSMMap(y:Number, x:Number, level:Number)
		{
			super();
			iX=x;
			iY=y;
			iLevel=level;
			this.percentWidth = 100;
			this.percentHeight = 100;
			mapLayout = new HGroup();
			mapLayout.percentHeight = 100;
			mapLayout.percentWidth = 100;
			map = new Map();
	
			
			//gmap.addEventListener(MapEvent.MAP_READY_INTERNAL, onMapReady);
			//gmap.addEventListener(MapMouseEvent.CLICK, handleClickEvent);
			mapLayout.addChild(map);
			addChild(mapLayout);
			
		}
		
		

	
		
		/*private function handleClickEvent(event:MapMouseEvent):void
		{
			
			
			try 
			{		
				var mapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.CLICKED, true, true);
				mapEvent.x = mouseLatLng.lng();
				mapEvent.y = mouseLatLng.lat();
				dispatcher.dispatchEvent(mapEvent);
			}
			catch(error:TypeError){
				//catch the occassional type error obtained when clicked on the menu container outside the item
			}
		}*/
		
		public function setMapCenter(x:Number, y:Number):void
		{
			var newCenter:Location = new Location(x,y);
			map.moveTo(newCenter, map.zoom,true);
		}
		
		
		public function addTrackingPoint(x:Number, y:Number, angle:Number):void
		{	
			//var gmarker:TSSGoogleMarker = new TSSGoogleMarker(x,y,"https://s3.amazonaws.com/videolog/car.png", angle - 90, gmap);
			tpInitialized = true;
		}
		public function positionTrackingPoint(x:Number, y:Number, angle:Number):void
		{
			
			
				if (!tpInitialized)
				{
					addTrackingPoint(x, y, angle);
				} else
				{
					//gmap.clearOverlays();
					//var gmarker:TSSGoogleMarker = new TSSGoogleMarker(x,y,"https://s3.amazonaws.com/videolog/car.png", angle - 90, gmap);	
				}
			
				var tmpeast:Number = map.extent.right;
				var tmpwest:Number = map.extent.left;
				var tmpnorth:Number = map.extent.top;
				var tmpsouth:Number = map.extent.bottom;
				
				var tmpwidth:Number = (tmpeast - tmpwest) * .1;
				var tmpheight:Number = (tmpnorth - tmpsouth) * .1;
				
				var neweast:Number = tmpeast - tmpwidth;
				var newwest:Number = tmpwest + tmpwidth;
				var newnorth:Number = tmpnorth - tmpheight;
				var newsouth:Number = tmpsouth + tmpheight;
				
				var tmpllb:Bounds = new Bounds(newwest,newsouth,neweast,newnorth);
				if (!tmpllb.containsLocation(new Location(x,y)))
				{
					map.moveTo(new Location(x,y));
				}
			
		}
		
		public function clearOverlays():void
		{
			//gmap.clearOverlays();
		}
	}
}