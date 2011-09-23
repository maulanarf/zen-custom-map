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
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	
	import flash.net.URLRequest;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	public class MainScene extends MovieClip {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private var pictLayer : MovieClip = new MovieClip();
		private var edgeLayer : MovieClip = new MovieClip();
		private var nodeLayer : MovieClip = new MovieClip();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function MainScene() {
			addChild(pictLayer);    // layer 0
			addChild(edgeLayer);    // layer 1
			addChild(nodeLayer);    // layer 2
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		public function getEdgeLayer() : MovieClip { return edgeLayer; }
		public function getNodeLayer() : MovieClip { return nodeLayer; }
		
		public function setActive(active : Boolean) : void {
			if(active) {
				addEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				addEventListener(MouseEvent.MOUSE_UP, mouseListener);
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseListener);
				removeEventListener(MouseEvent.MOUSE_UP, mouseListener);
			}
		}
		
		public function setBackground(picture : DisplayObject) : void {
			clearBackground();
			pictLayer.addChild(picture);
		}
		
		public function loadBackgroundURL(url : URLRequest) : void {
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initListener);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorListener);
			loader.load(url);
			
			function initListener(e : Event) : void {
				clearBackground();
				pictLayer.addChild(loader.content);
			}
			
			function errorListener(e : IOErrorEvent) : void {
				trace("darkemon::display::MainScene::loadBackgroundURL\n"+e.text);
			}
		}
		
		public function clearBackground() : void {
			try {
				pictLayer.removeChildAt(0);
			}
			catch(e:Error) 
			{
			}
		}
		
		public function hasBackground() : Boolean {
			try 
			{
				pictLayer.getChildAt(0);
			}
			catch(e:Error)
			{
				return false;
			}
			return true;
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		// The mouse events listener.
		private function mouseListener(e : MouseEvent) : void {
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					startDrag();
					break;
				case MouseEvent.MOUSE_UP:
					stopDrag();
					break;
			}
		}
	}
}