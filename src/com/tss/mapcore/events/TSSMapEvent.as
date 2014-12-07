package com.tss.mapcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class TSSMapEvent extends Event
	{
		public static const CLICKED:String = "mapEvent_Clicked";
		public static const DOUBLE_CLICKED:String = "mapEvent_Double_Clicked";
		public static const EXTENT_CHANGED:String = "mapEvent_Extent_Changed";
		public static const TRACKING_POINT:String = "mapEvent_Tracking_Point";

		//newly added code
		public static const TOGGLE_MAP:String = "toggleMapButton_Clicked";
		
		private var _layerId:Number;
		private var _x:Number;
		private var _y:Number;
		private var _minx:Number;
		private var _miny:Number;
		private var _maxx:Number;
		private var _maxy:Number;
		private var _tpangle:Number;
		private var _tpname:String;
		
		
				
		public function TSSMapEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}

		public function get tpname():String
		{
			return _tpname;
		}

		public function set tpname(value:String):void
		{
			_tpname = value;
		}

		public function get tpangle():Number
		{
			return _tpangle;
		}

		public function set tpangle(value:Number):void
		{
			_tpangle = value;
		}

		public function get layerId():Number
		{
			return _layerId;
		}

		public function set layerId(value:Number):void
		{
			_layerId = value;
		}

		public function get maxy():Number
		{
			return _maxy;
		}

		public function set maxy(value:Number):void
		{
			_maxy = value;
		}

		public function get maxx():Number
		{
			return _maxx;
		}

		public function set maxx(value:Number):void
		{
			_maxx = value;
		}

		public function get miny():Number
		{
			return _miny;
		}

		public function set miny(value:Number):void
		{
			_miny = value;
		}

		public function get minx():Number
		{
			return _minx;
		}

		public function set minx(value:Number):void
		{
			_minx = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

	}
}