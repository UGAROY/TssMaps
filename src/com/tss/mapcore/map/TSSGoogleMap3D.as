package com.tss.mapcore.map
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map3D;
	import com.google.maps.MapEvent;
	import com.google.maps.MapOptions;
	import com.google.maps.MapType;
	import com.google.maps.View;
	import com.google.maps.controls.NavigationControl;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.geom.Attitude;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Image;
	
	
	
	
	public class TSSGoogleMap3D extends BorderContainer
	{
		private var mapLayout:HGroup;
		private var gmap:com.google.maps.Map3D;
		private var tpMarker:com.google.maps.overlays.Marker;
		private var tpInitialized:Boolean = false;
		private var zoomControl:com.google.maps.controls.ZoomControl;
		private var iX:Number;
		private var iY:Number;
		private var iLevel:Number;
		private var tpSprite:Sprite;
		private var tpImage:Image = new Image();
		
		
		
		public function TSSGoogleMap3D(y:Number, x:Number, level:Number)
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
			gmap = new com.google.maps.Map3D();
			gmap.id = "map";
			gmap.sensor = "false";
			gmap.percentHeight = 100;
			gmap.percentWidth = 100;
			gmap.key = "ABQIAAAAzpmvOqIDlAeq_blvXCvwkxQGPLZp1aYYN9bxyrHAL-mbMEQoPBS55gbPevdlVSgr3mJ1Oh2gTSLb6g";
			gmap.addEventListener(MapEvent.MAP_READY_INTERNAL, onMapReady);
			gmap.addEventListener(MapEvent.MAP_PREINITIALIZE, onMapPreinitialize);
			mapLayout.addChild(gmap);
			addChild(mapLayout);
			
		}
		
		private function onMapPreinitialize(event:MapEvent):void {
			var myMapOptions:MapOptions = new MapOptions;
			myMapOptions.zoom = iLevel;
			myMapOptions.center = new LatLng(iY, iX);
			myMapOptions.mapType = MapType.NORMAL_MAP_TYPE;
			myMapOptions.viewMode = View.VIEWMODE_PERSPECTIVE;
			myMapOptions.attitude = new Attitude(20,30,0);
			gmap.setInitOptions(myMapOptions);
		}
		
		
		private function onMapReady(event:Event):void {
			gmap.addControl(new NavigationControl());
		}
		
		public function setMapCenter(x:Number, y:Number):void
		{
			gmap.setCenter(new LatLng(y, x));
		}
		
		
		public function addTrackingPoint(x:Number, y:Number, angle:Number):void
		{	
			var gmarker:TSSGoogleMarker = new TSSGoogleMarker(x,y,"https://s3.amazonaws.com/videolog/car.png", angle, gmap);
			tpInitialized = true;
		}
		
		public function positionTrackingPoint(x:Number, y:Number, angle:Number):void
		{
			if (!tpInitialized)
			{
				addTrackingPoint(x, y, angle);
			} else
			{
				gmap.clearOverlays();
				var gmarker:TSSGoogleMarker = new TSSGoogleMarker(x,y,"./assets/car.jpg", angle, gmap);	
			}
			gmap.panTo(new LatLng(y, x));
		}
		
		public function clearOverlays():void
		{
			gmap.clearOverlays();
		}
	}
}