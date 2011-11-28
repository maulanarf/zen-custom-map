/*
This program is the add-on for a Zenoss monitoring system.
Copyright (C) 2011 Krasotin Artem

This program is free software; you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software Foundation; 
either version 2 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; 
if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
package darkemon.display {
	
	import darkemon.ui.NodeMenu;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import spark.components.Image;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	public class MainScene extends UIComponent {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var _hitArea:Sprite = new Sprite();
		private var container:UIComponent = new UIComponent();
		private var pictLayer:Image = new Image();
		private var gridLayer:UIComponent = new UIComponent();
		private var edgeLayer:UIComponent = new UIComponent();
		private var nodeLayer:UIComponent = new UIComponent();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function MainScene() {
			_hitArea.mouseEnabled = false;
			pictLayer.mouseEnabled = false;
			gridLayer.mouseEnabled = false;
			container.addChild(pictLayer);    // layer 0
			container.addChild(gridLayer);    // layer 1
			container.addChild(edgeLayer);    // layer 2
			container.addChild(nodeLayer);    // layer 3
			addChild(container);
			addChild(_hitArea);
			addEventListener(Event.RESIZE, resizeHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		public function getEdgeLayer(): UIComponent { return edgeLayer; }
		public function getNodeLayer(): UIComponent { return nodeLayer; }
		
		public function set draggable(flag:Boolean):void {
			if(flag) {
				addEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				addEventListener(MouseEvent.MOUSE_UP, mouseListener);
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				removeEventListener(MouseEvent.MOUSE_UP, mouseListener);
			}
		}
		
		public function set zoom(z:Number):void {
			container.scaleX = z;
			container.scaleY = z;
		}

		public function get sceneX():Number { return container.x; }
		
		public function set sceneX(_x:Number):void {
			container.x = _x;
		}
		
		public function get sceneY():Number { return container.y; }
		
		public function set sceneY(_y:Number):void {
			container.y = _y;
		}
		
		public function setBackgroundImage(img:Object):void {
			pictLayer.source = img;
			if(img != null) {
				pictLayer.x = pictLayer.y = 0;
				pictLayer.height = pictLayer.sourceHeight;
				pictLayer.width = pictLayer.sourceWidth;
			}
		}
		
		public function hasBackgroundImage():Boolean {
			if(pictLayer.source != null) return true;
			else return false;
		}
		
		public function clearNodeLayer():void {
			while(nodeLayer.numChildren != 0) {
				nodeLayer.removeChildAt(0);
			}
		}
		
		public function showNodeInCenter(nodeX:Number, nodeY:Number):void {
			// Add animation.
			var anim:Animate = new Animate();
			var xPath:SimpleMotionPath = new SimpleMotionPath();
			var yPath:SimpleMotionPath = new SimpleMotionPath();
			xPath.property = "x";
			yPath.property = "y";
						
			var motionPaths:Vector.<MotionPath> = new Vector.<MotionPath>();
			motionPaths.push(xPath);
			motionPaths.push(yPath);
			anim.motionPaths = motionPaths;
			anim.duration = 500;
			anim.target = container;
			
			// Move scene.
			xPath.valueBy = _hitArea.width/2 - (nodeX + container.x);
			yPath.valueBy = _hitArea.height/2 - (nodeY + container.y);
			anim.play();
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		// The mouse events listener.
		private function mouseListener(e:MouseEvent):void {
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					container.startDrag();
					break;
				case MouseEvent.MOUSE_UP:
					container.stopDrag();
					break;
			}
		}
		
		private function mouseDownListener(e:MouseEvent):void {
			if(!(e.target is Node)) {
				// unselect nodes
				Node.unselectAll();
				// hide opened node menu
				if(NodeMenu.visible) NodeMenu.hide();
			}
		}
		
		private function resizeHandler(e:Event):void {
			_hitArea.graphics.clear();
			_hitArea.graphics.beginFill(0XFFFFFF);
			_hitArea.graphics.lineStyle(0, 0XFFFFFF);
			_hitArea.graphics.drawRect(0, 0, width, height);
			_hitArea.graphics.endFill();
			_hitArea.alpha = 0;
		}
	}
}