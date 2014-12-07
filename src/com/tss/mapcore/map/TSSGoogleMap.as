package com.tss.mapcore.map
{
	import com.asfusion.mate.events.Dispatcher;
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapType;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.tss.mapcore.events.TSSMapEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Image;
	
	
	
	
	public class TSSGoogleMap extends BorderContainer
	{
		private var mapLayout:HGroup;
		private var _gmap:com.google.maps.Map;
		private var tpMarker:com.google.maps.overlays.Marker;
		private var tpInitialized:Boolean = false;
		private var zoomControl:com.google.maps.controls.ZoomControl;
		private var iX:Number;
		private var iY:Number;
		private var iLevel:Number;
		private var tpSprite:Sprite;
		private var tpImage:Image = new Image();
		private var dispatcher:Dispatcher = new Dispatcher();
		
		//[Embed(source="assets/car.jpg")] protected var purpleIcon:Class
		
		public function TSSGoogleMap(y:Number, x:Number, level:Number)
		{
			super();
			iX=x;
			iY=y;
			iLevel=level;
			this.percentWidth = 100;
			this.percentHeight = 100;
			mapLayout = new HGroup();
			//mapLayout.layout = "horizontal";
			mapLayout.percentHeight = 100;
			mapLayout.percentWidth = 100;
			gmap = new com.google.maps.Map();
			gmap.id = "map";
			gmap.sensor = "false";
			gmap.percentHeight = 100;
			gmap.percentWidth = 100;
			gmap.key = "ABQIAAAAzpmvOqIDlAeq_blvXCvwkxQGPLZp1aYYN9bxyrHAL-mbMEQoPBS55gbPevdlVSgr3mJ1Oh2gTSLb6g";
			gmap.addEventListener(MapEvent.MAP_READY_INTERNAL, onMapReady);
			gmap.addEventListener(MapMouseEvent.CLICK, handleClickEvent);
			mapLayout.addElement(gmap);
			addElement(mapLayout);
			
		}
		
		public function get gmap():com.google.maps.Map
		{
			return _gmap;
		}

		public function set gmap(value:Map):void
		{
			_gmap = value;
		}

		private function onMapReady(event:Event):void {
			this.gmap.setCenter(new LatLng(iY,iX), iLevel, MapType.NORMAL_MAP_TYPE);
			gmap.enableContinuousZoom();
			zoomControl = new ZoomControl();
			gmap.addControl(zoomControl);

		}
		
		private function handleClickEvent(event:MapMouseEvent):void
		{
			
			var mousePoint:Point = new Point(mouseX, mouseY);
			//var mousePointLocal:Point = globalToLocal(mousePoint);
			var mouseLatLng:LatLng = gmap.fromViewportToLatLng(mousePoint); 
			
			try 
			{		
				/*var tssmap:TSSMap = this.parent as TSSMap;
				tssmap.idPolygon(event.localX, event.localY);*/
				
				var mapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.CLICKED, true, true);
				mapEvent.x = mouseLatLng.lng();
				mapEvent.y = mouseLatLng.lat();
				dispatcher.dispatchEvent(mapEvent);
			}
			catch(error:TypeError){
				//catch the occassional type error obtained when clicked on the menu container outside the item
			}
		}
		
		public function setMapCenter(x:Number, y:Number):void
		{
			gmap.setCenter(new LatLng(y, x));
		}
		
		
		public function addTrackingPoint(x:Number, y:Number, angle:Number):void
		{	
			var gmarker:TSSGoogleMarker = new TSSGoogleMarker(x,y,"https://s3.amazonaws.com/videolog/car.png", angle - 90, gmap);
			tpInitialized = true;
		}
		public function positionTrackingPoint(x:Number, y:Number, angle:Number):void
		{
			if (gmap.isLoaded())
			{
				if (!tpInitialized)
				{
					addTrackingPoint(x, y, angle);
				} else
				{
					gmap.clearOverlays();
					var gmarker:TSSGoogleMarker = new TSSGoogleMarker(x,y,"https://s3.amazonaws.com/videolog/car.png", angle - 90, gmap);	
				}
			
				var tmpeast:Number = gmap.getLatLngBounds().getEast();
				var tmpwest:Number = gmap.getLatLngBounds().getWest();
				var tmpnorth:Number = gmap.getLatLngBounds().getNorth();
				var tmpsouth:Number = gmap.getLatLngBounds().getSouth();
				
				var tmpwidth:Number = (tmpeast - tmpwest) * .1;
				var tmpheight:Number = (tmpnorth - tmpsouth) * .1;
				
				var neweast:Number = tmpeast - tmpwidth;
				var newwest:Number = tmpwest + tmpwidth;
				var newnorth:Number = tmpnorth - tmpheight;
				var newsouth:Number = tmpsouth + tmpheight;
				
				var tmpllb:LatLngBounds = new LatLngBounds(new LatLng(newsouth,newwest), new LatLng(newnorth,neweast));
				if (!tmpllb.containsLatLng(new LatLng(y, x)))
				{
					gmap.panTo(new LatLng(y, x));
				}
			}
		}
		
		public function clearOverlays():void
		{
			gmap.clearOverlays();
		}
	}
}