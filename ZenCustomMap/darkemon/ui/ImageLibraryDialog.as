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
package darkemon.ui {
	import darkemon.Global;
	import darkemon.display.Arrow;
	import darkemon.display.Node;
	import darkemon.events.CommunicatorEvent;
	import darkemon.net.Communicator;
	import darkemon.skins.TileListSkin;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.TitleWindow;
	import spark.layouts.TileLayout;
	
	public class ImageLibraryDialog {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _window:TitleWindow = null;
		private static var _node:Node = null;
		private static var _comm:Communicator = new Communicator();
		
		private static var tileList:List = new List();
		private static var setBtn:Button = new Button();
		private static var clearBtn:Button = new Button();
		private static var loadBtn:Button = new Button();
		private static var deleteBtn:Button = new Button();
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function ImageLibraryDialog() {
			throw Error("ImageLibraryDialog is a singleton class, use show() instead.");
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
		
		public static function show(parent:DisplayObject, n:Node, 
									modal:Boolean=false):void {
			if(!_window) createWindow();
			_node = n;
			_comm.addEventListener(CommunicatorEvent.IMAGES_LIST_LOADED, communicatorHandler);
			_comm.addEventListener(CommunicatorEvent.IMAGE_DELETED, communicatorHandler);
			PopUpManager.addPopUp(_window, parent, modal);
			PopUpManager.centerPopUp(_window);
			updateTileList();
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private static function createWindow():void {
			
			_window = new TitleWindow();
			
			// Set size and title.
			_window.height = 480;
			_window.width = 640;
			_window.title = "Image library";
			
			_window.addElement(tileList);
			_window.addElement(setBtn);
			_window.addElement(clearBtn);
			_window.addElement(loadBtn);
			_window.addElement(deleteBtn);
			
			// Tile list.
			var tileLayout:TileLayout = new TileLayout();
			tileLayout.horizontalGap = tileLayout.verticalGap = 2;
			tileLayout.requestedColumnCount = 6;
			tileList.itemRenderer = new ClassFactory(darkemon.skins.TileListSkin);
			tileList.layout = tileLayout;
						
			tileList.setConstraintValue("top", 5);
			tileList.setConstraintValue("left", 5);
			tileList.setConstraintValue("right", 5);
			tileList.setConstraintValue("bottom", 30);
			
			// Buttons.
			setBtn.label = "Set";
			clearBtn.label = "Clear";
			loadBtn.label = "Load";
			deleteBtn.label = "Delete";
			
			setBtn.toolTip = "Set image";
			clearBtn.toolTip = "Clear image";
			loadBtn.toolTip = "Load new image";
			deleteBtn.toolTip = "Delete image from library";
			
			setBtn.width = clearBtn.width = loadBtn.width = deleteBtn.width = 60;
			
			setBtn.setConstraintValue("left", 5);
			setBtn.setConstraintValue("bottom", 5);
			clearBtn.setConstraintValue("left", 70);
			clearBtn.setConstraintValue("bottom", 5);
			deleteBtn.setConstraintValue("right", 5);
			deleteBtn.setConstraintValue("bottom", 5);
			loadBtn.setConstraintValue("right", 70);
			loadBtn.setConstraintValue("bottom", 5);

			_window.addEventListener(CloseEvent.CLOSE, closeHandler);
			setBtn.addEventListener(MouseEvent.CLICK, setHandler);
			clearBtn.addEventListener(MouseEvent.CLICK, clearHandler);
			loadBtn.addEventListener(MouseEvent.CLICK, loadHandler);
			deleteBtn.addEventListener(MouseEvent.CLICK, deleteHandler);
		}
		
		private static function updateTileList():void 
		{
			// Show busy cursor.
			Arrow.busySystem = true;
			_comm.loadImagesList();
		}
		
		private static function destroy():void {
			_node = null;
			tileList.dataProvider.removeAll();
			_comm.removeEventListener(CommunicatorEvent.IMAGES_LIST_LOADED, communicatorHandler);
			_comm.removeEventListener(CommunicatorEvent.IMAGE_DELETED, communicatorHandler);
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private static function closeHandler(e:CloseEvent):void {
			destroy();
			PopUpManager.removePopUp(_window);
		}
		
		private static function setHandler(e:MouseEvent):void {
			if(tileList.selectedIndex == -1) {
				Alert.show("Select image.", "Note");
			} else {
				_node.setImage(tileList.selectedItem.source, tileList.selectedItem.label);
				destroy();
				PopUpManager.removePopUp(_window);
			}
		}
		
		private static function clearHandler(e:MouseEvent):void {
			_node.setImage(null, null);
			destroy();
			PopUpManager.removePopUp(_window);
		}
		
		private static function loadHandler(e:MouseEvent):void 
		{
			var fileRef:FileReference = new FileReference(); 
			fileRef.addEventListener(Event.SELECT, selectHandler); 
			fileRef.addEventListener(Event.COMPLETE, completeHandler); 
			
			var progressBar:ProgressBar = new ProgressBar();
			progressBar.mode = "event";
			progressBar.indeterminate = false;
			progressBar.source = fileRef;
			progressBar.height = 50;
			progressBar.width = _window.width;
			
			try 
			{ 
				var imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", 
					"*.jpg; *.jpeg; *.gif; *.png"); 
				var success:Boolean = fileRef.browse([imageTypes]);
			} 
			catch (error:Error) 
			{ 
				throw Error("ImageLibraryDialog::Unable to browse for files\n"+error); 
			}
			
			// Handlers.
			function selectHandler(event:Event):void { 
				var urlRequest:URLRequest = new URLRequest(Communicator.url);
				var urlVars:URLVariables = new URLVariables();
				
				urlRequest.method = URLRequestMethod.POST;
				urlVars.action = "upload_nodeimage";
				urlRequest.data = urlVars;
				
				try 
				{ 
					PopUpManager.addPopUp(progressBar, _window, true);
					PopUpManager.centerPopUp(progressBar);
					fileRef.upload(urlRequest);
				} 
				catch (error:Error) 
				{ 
					PopUpManager.removePopUp(progressBar);
					throw Error("Unable to upload file.");
				} 
			}
			
			function completeHandler(event : Event) : void { 
				PopUpManager.removePopUp(progressBar);
				updateTileList();
			}
		}
		
		private static function deleteHandler(e:MouseEvent):void 
		{
			if(tileList.selectedIndex == -1) {
				Alert.show("Select deleting image.", "Note");
			} else {
				_comm.deleteImage((tileList.selectedItem).label);	
			}
		}
		
		private static function communicatorHandler(e:CommunicatorEvent):void {
			switch(e.type) {
				case CommunicatorEvent.IMAGES_LIST_LOADED:
					try {
						var xml:XML = new XML(e.data);
						
						// Read image name list.
						var dp:ArrayCollection = new ArrayCollection();
						for each(var image:XML in xml.elements("image")) 
						{
							var src:String = Communicator.url+
								"?action=download_nodeimage&filename="+
								image.toString();
							var img:Image = new spark.components.Image;
							img.height = img.width = 60;
							img.source = src;
							dp.addItem({label:image.toString(), source:img});
						}
						tileList.dataProvider = dp;
					} 
					catch(e : TypeError) {
						throw Error("Could not parse the XML file.\n"+e.toString());
					}
					finally {
						Arrow.busySystem = false;
					}
					break;
				case CommunicatorEvent.IMAGE_DELETED:
					updateTileList();
					break;
			}
		}
	}
}