package com.tss.mapcore.map
{
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.symbols.Symbol;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class CustomSymbol extends Symbol
	{
		private var _sprite:Sprite;
		
		
		public function CustomSymbol(sprite:Sprite) 
		{
			_sprite = sprite;
			
		}
		
		//public function set sprite(sprite:Sprite):void
		//{
		//	_sprite = sprite;	
		//}
		
		override public function clear(sprite:Sprite):void
		{
			sprite.graphics.clear();
		}
		
		override public function draw(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
		{
			if(geometry is MapPoint)
			{
				drawMapPoint(sprite, MapPoint(geometry), map);
				//sprite = this._sprite;
			}
		}
		
		private function drawMapPoint(sprite:Sprite, mapPoint:MapPoint, map:Map):void
		{
			_sprite.x =0;
			_sprite.y =0;
			
			sprite.x = toScreenX(map,mapPoint.x) + _sprite.width / 2;
			sprite.y = toScreenY(map, mapPoint.y) - _sprite.height / 2;
			
			sprite.addChildAt(_sprite,0);
			
			//sprite = _sprite;
			//sprite.graphics.beginFill( 0x0000FF,1 );
			//sprite.graphics.drawCircle(0,0,100);
			//sprite.graphics.endFill();  
		}
		
	}
}