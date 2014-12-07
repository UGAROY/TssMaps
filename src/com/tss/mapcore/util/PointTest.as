package  com.tss.mapcore.util
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Miguel
	 */
	public class PointTest extends Sprite
	{
		
		public function PointTest() 
		{
			super();
			
			graphics.beginFill(0x555500);
			graphics.drawCircle(0, 0, 10);
			graphics.endFill();
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(e:MouseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			x = parent.mouseX;
			y = parent.mouseY;
		}
		
	}

}