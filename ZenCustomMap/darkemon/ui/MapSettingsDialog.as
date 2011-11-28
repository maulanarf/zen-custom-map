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
	import darkemon.net.Communicator;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.ColorPicker;
	import mx.controls.ProgressBar;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.skins.spark.ColorPickerSkin;
	
	import spark.components.Button;
	import spark.components.Form;
	import spark.components.FormItem;
	import spark.components.Group;
	import spark.components.TitleWindow;
	import spark.layouts.HorizontalLayout;
	
	public class MapSettingsDialog {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		private static var _window:TitleWindow = null;
		private static var _global:Global;
		
		private static var okBtn:Button = new Button();
		private static var cancelBtn:Button = new Button();
		private static var loadPictBtn:Button = new Button();
		private static var clearPictBtn:Button = new Button();
		
		private static var graphLineColorPicker:ColorPicker = new ColorPicker();
		private static var graphLineWidthTextInput:TextInput = new TextInput();
		private static var refreshEventsTextInput:TextInput = new TextInput();
				
	//--------------------------------------
	//  Constructor
	//--------------------------------------
		
		public function MapSettingsDialog() {
			throw Error("MapSettingsDialog is a singleton class, use show() instead.");
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------

		public static function show(parent:DisplayObject, g:Global):void {
			if(!_window) {
				createWindow();
			}
			_global = g;
			graphLineWidthTextInput.text = String(_global.dataProvider.graphLineWidth);
			refreshEventsTextInput.text = String(_global.dataProvider.refreshEventsTime);
			graphLineColorPicker.selectedColor = _global.dataProvider.graphLineColor;
			PopUpManager.addPopUp(_window, parent, true);
			PopUpManager.centerPopUp(_window);
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		private static function createWindow():void {
			
			var form:Form = new Form();
			
			_window = new TitleWindow();
			
			// Set size.
			_window.height = 220;
			_window.width = 310;
			
			_window.title = "Map settings";
			
			_window.addElement(form);
			_window.addElement(okBtn);
			_window.addElement(cancelBtn);
			
			okBtn.label = "Ok";
			cancelBtn.label = "Cancel";
			okBtn.height = cancelBtn.height = 20;
			okBtn.width = cancelBtn.width = 75;
			
			form.setConstraintValue("top", 5);
			form.setConstraintValue("left", 5);
			form.setConstraintValue("right", 5);
			form.setConstraintValue("bottom", 30);
			okBtn.setConstraintValue("bottom", 5);
			okBtn.setConstraintValue("right", cancelBtn.width+10);
			cancelBtn.setConstraintValue("bottom", 5);
			cancelBtn.setConstraintValue("right", 5);
			
			//
			// Fill the form.
			//
			/* Graph line settings */
			var formItem:FormItem = new FormItem();
			formItem.label = "Graph line";
			formItem.layout = new HorizontalLayout();
						
			// Add ColorPicker to the Group, 
			// otherwise it not be displayed correctly in the Form.
			var gr:Group = new Group();
			gr.addElement(graphLineColorPicker);
			formItem.addElement(graphLineWidthTextInput);
			formItem.addElement(gr);
			graphLineWidthTextInput.width = 48;
			graphLineWidthTextInput.restrict = "1-9";
			graphLineWidthTextInput.toolTip = "Graph line width";
			graphLineColorPicker.toolTip = "Graph line color";
			form.addElement(formItem);
			
			/* Events settings */
			formItem = new FormItem();
			formItem.label = "Refresh events(sec)";
			formItem.addElement(refreshEventsTextInput);
			refreshEventsTextInput.width = 48;
			refreshEventsTextInput.restrict = "0-9";
			refreshEventsTextInput.toolTip = "Refresh events interval in seconds";
			form.addElement(formItem);
			
			/* Graph line settings */
			formItem = new FormItem();
			formItem.label = "Background image";
			formItem.layout = new HorizontalLayout();
			loadPictBtn.label = "Load";
			clearPictBtn.label = "Clear";
			formItem.addElement(loadPictBtn);
			formItem.addElement(clearPictBtn);
			form.addElement(formItem);
									
			// Add listeners.
			okBtn.addEventListener(MouseEvent.CLICK, applyHandler);
			cancelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			loadPictBtn.addEventListener(MouseEvent.CLICK, loadPictHandler);
			clearPictBtn.addEventListener(MouseEvent.CLICK, clearPictHandler);
			_window.addEventListener(CloseEvent.CLOSE, closeHandler);
		}
		
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
		
		private static function closeHandler(e:CloseEvent):void {
			PopUpManager.removePopUp(_window);
		}
		
		private static function applyHandler(e:MouseEvent):void {
			if(_global.dataProvider.graphLineWidth != int(graphLineWidthTextInput.text))
				_global.dataProvider.graphLineWidth = int(graphLineWidthTextInput.text);
			
			if(_global.dataProvider.refreshEventsTime != int(refreshEventsTextInput.text))
				_global.dataProvider.refreshEventsTime = int(refreshEventsTextInput.text);
			
			if(_global.dataProvider.graphLineColor != graphLineColorPicker.selectedColor)
				_global.dataProvider.graphLineColor = graphLineColorPicker.selectedColor;
			PopUpManager.removePopUp(_window);
		}
		
		private static function cancelHandler(e:MouseEvent):void {
			_window.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		private static function loadPictHandler(e:MouseEvent):void 
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
			
			try { 
				var imageTypes:FileFilter  = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", 
					"*.jpg; *.jpeg; *.gif; *.png"); 
				var success:Boolean = fileRef.browse([imageTypes]);
			} 
			catch (error:Error)	{ 
				throw Error("MapSettingsDialog::Unable to browse for files\n"+error); 
			}
			
			// Handlers.
			function selectHandler(event:Event):void { 
				var urlRequest:URLRequest = new URLRequest(Communicator.url) ;
				var urlVars:URLVariables = new URLVariables();
				
				urlRequest.method = URLRequestMethod.POST;
				urlVars.action = "upload_background";
				urlVars.filename = "background"+String(_global.dataProvider.mapUid)+".img";
				urlRequest.data = urlVars;
				
				try 
				{ 
					fileRef.upload(urlRequest);
					PopUpManager.addPopUp(progressBar, _window, true);
					PopUpManager.centerPopUp(progressBar);
				} 
				catch (error:Error) 
				{ 
					throw Error("darkemon::display::MapSettingsDialog::Unable to upload file\n"
						+error);
				} 
			}
			
			function completeHandler(event:Event):void { 
				PopUpManager.removePopUp(progressBar);
							
				_global.scene.setBackgroundImage(Communicator.url+
					"?action=download_background&filename=background"+
					String(_global.dataProvider.mapUid)+".img");
			}
		}
		
		private static function clearPictHandler(e:MouseEvent):void {
			_global.deleteBackgroundImage();
		}
	}
}