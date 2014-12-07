package com.tss.mapcore.map
{
	public class TSSGoogleMarker
	{
		import com.google.maps.LatLng;
		import com.google.maps.Map;
		import com.google.maps.overlays.Marker;
		import com.google.maps.overlays.MarkerOptions;
		
		import flash.display.*;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.events.Event;
		import flash.geom.Point;
		import flash.net.URLRequest;
		import flash.utils.*;
		
		private var mx:Number;
		private var my:Number;
		private var murl:String;
		private var mangle:Number;
		private var bitmap:Bitmap;
		private var tpMarker:Marker;
		private var mgmap:com.google.maps.Map;
		
		/*Constructor:  Takes the x and y in map units, url to the image, angle in degrees and the active map instance*/
		public function TSSGoogleMarker(x:Number, y:Number, url:String, angle:Number, gmap:com.google.maps.Map)
		{
			mgmap = gmap;
			mx = x;
			my = y;
			mangle = angle;
			// Set up loader and load image from url
			var myLoader:Loader = new Loader();
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
			var fileRequest:URLRequest = new URLRequest(url);
			myLoader.load(fileRequest);
		}
		
		/* This function is called when the image is completely loaded*/
		public function onLoaderReady(e:Event):void { 
			//Retrieve the bitmap from the image and rotate
			var doneloaderinfo:LoaderInfo = e.target as LoaderInfo;
			var doneloader:Loader = doneloaderinfo.loader as Loader;
			bitmap = doneloader.content as Bitmap;
			bitmap.rotation = mangle;
			
			//Set up marker options, load bitmap into markeroptions
			var markerOptions:MarkerOptions = new MarkerOptions();
			markerOptions.icon = bitmap;
			markerOptions.tooltip = "Current Location";
			markerOptions.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER;
			markerOptions.iconOffset = new Point(2, 2);
			
			// Deal with flex rotating from the upper left corner by shifting the image
			var tmpll:LatLng = new LatLng(my,mx);
			var tx:Number = mgmap.fromLatLngToViewport(tmpll).x - (bitmap.width /2);
			var ty:Number = mgmap.fromLatLngToViewport(tmpll).y - (bitmap.height /2);
			var tmpp:Point = new Point(tx,ty);
			mx = mgmap.fromViewportToLatLng(tmpp).lng();
			my = mgmap.fromViewportToLatLng(tmpp).lat();
			
			// Create the new marker and add to the map
			tpMarker = new Marker(new LatLng(my, mx), markerOptions);
			mgmap.addOverlay(tpMarker);
		}
	}
}