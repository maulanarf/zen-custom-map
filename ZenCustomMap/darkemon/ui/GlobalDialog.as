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
	import com.yahoo.astra.containers.formClasses.FormItem;
	import com.yahoo.astra.containers.formClasses.FormLayoutStyle;
	import com.yahoo.astra.fl.containers.Form;
	import com.yahoo.astra.fl.utils.FlValueParser;
	import com.yahoo.astra.managers.FormDataManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import fl.controls.Button;
	import fl.controls.ColorPicker;
	import fl.controls.TextInput;
	import fl.controls.Label;
	import fl.controls.ProgressBar;
	import fl.controls.ProgressBarMode;
	
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	
	import flash.events.HTTPStatusEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import darkemon.Global;

	public class GlobalDialog extends Sprite {
		
	//--------------------------------------
	//  Properties
	//--------------------------------------

		private static var _instance : GlobalDialog = null;
		private static var _allowInstantiation : Boolean = false;
		private static var _isVisible : Boolean = false;
		
		private static var _glob : Global;
	
		private static var lineFormItem : FormItem;
		private static var mainForm : Form;
		private static var lineWidthInput : TextInput;
		private static var refreshEventInput : TextInput;
		private static var loadPictBtn : Button;
		private static var clearPictBtn : Button;
		private static var okBtn : Button;
		private static var cancelBtn : Button;
		private static var lineColorPicker : ColorPicker;
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		public function GlobalDialog() {
			if(!_allowInstantiation) {
				throw Error("GlobalDialog is a singleton class, use getInstance() instead.");
			}
			initUI();
			initForm();
			initData();
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------

		public static function getInstance() : GlobalDialog {
			if(!_instance) {
				_allowInstantiation = true;
				_instance = new GlobalDialog();
				_allowInstantiation = false;
			}
			return _instance;
		}
	
		public static function isVisible() : Boolean {
			return _isVisible;
		}
	
		public static function show(p : MovieClip, glob : Global) : void {
			if(_instance == null) {
				getInstance();
			}
			_glob = glob;
			lineWidthInput.text = String(_glob.graphLineWidth);
			refreshEventInput.text = String(_glob.refreshEventsTime);
			lineColorPicker.selectedColor = _glob.graphLineColor;
			
			// Add to scene.
			p.stage.addChild(_instance);
			_instance.x = (p.stage.stageWidth/2) - (mainForm.width/2);
			_instance.y = (p.stage.stageHeight/2) - (mainForm.height/2);
			_isVisible = true;
		}
	
		public static function hide() : void {
			if(_isVisible) {
				_instance.parent.removeChild(_instance);
				_isVisible = false;
			}
		}
	
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
	
		private function initUI() : void
		{
			lineWidthInput    = new TextInput();
			refreshEventInput = new TextInput();
			loadPictBtn    = new Button();
			clearPictBtn   = new Button();
			okBtn          = new Button();
			cancelBtn      = new Button();
			lineColorPicker = new ColorPicker();
			loadPictBtn.label  = "Load image";
			clearPictBtn.label = "Clear image";
			okBtn.label        = "Ok";
			cancelBtn.label    = "Cancel";
			lineWidthInput.maxChars = 1;
			lineWidthInput.restrict = "1-9";
			refreshEventInput.restrict = "0-9";
			
			lineFormItem = new FormItem("", "width", lineWidthInput, "color", lineColorPicker);
			lineFormItem.indicatorLocation = FormLayoutStyle.RIGHT;
			lineFormItem.itemHorizontalGap = 10;
		}
		
		private function initForm() : void 
		{
			mainForm = new Form("Global Preferences");
			mainForm.alpha = 100;
			mainForm.autoSize = false;
			mainForm.setSize(390,190);
			mainForm.setStyle("skin", "FormSkin");
			mainForm.labelAlign = FormLayoutStyle.RIGHT;
			mainForm.paddingLeft = mainForm.paddingRight = mainForm.paddingTop = mainForm.paddingBottom = 10;
			this.addChild(mainForm);
		}
		
		private function initData() : void 
		{
			// Init FormDataManager with FlValueParser since we are using UIcomponents.  
			var myFormDataManager:FormDataManager=new FormDataManager(FlValueParser);
			
			// Define formDataManager in Form before set dataSource.    
			mainForm.formDataManager = myFormDataManager;
			
			// Define dataSource with data array.           
			mainForm.dataSource = [
				{label:"Graph Line Width:",items:lineWidthInput},
				{label:"Graph Line Color:",items:lineColorPicker},
				{label:"Background Image:",items:[loadPictBtn,clearPictBtn]},
				{label:"Refresh Events Interval (sec):",items:refreshEventInput},
				{label:"",items:[okBtn,cancelBtn]}
			];
			
			okBtn.addEventListener(MouseEvent.CLICK, applyHandler);
			cancelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			loadPictBtn.addEventListener(MouseEvent.CLICK, loadFileHandler);
			clearPictBtn.addEventListener(MouseEvent.CLICK, clearBackground);
		}
		
	//--------------------------------------
	//  Handlers
	//--------------------------------------
	
		private function cancelHandler(e : MouseEvent) : void {
			hide();
		}
		
		private function applyHandler(e : MouseEvent) : void {
			_glob.graphLineWidth = int(lineWidthInput.text);
			_glob.refreshEventsTime = int(refreshEventInput.text);
			_glob.graphLineColor = lineColorPicker.selectedColor;
			hide();
		}
		
		private function loadFileHandler(e : MouseEvent) : void 
		{
			var fileRef : FileReference = new FileReference(); 
			fileRef.addEventListener(Event.SELECT, selectHandler); 
			fileRef.addEventListener(Event.COMPLETE, completeHandler); 
			fileRef.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileRef.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			
			var progressBar : ProgressBar = new ProgressBar();
			progressBar.mode = ProgressBarMode.EVENT;
			progressBar.indeterminate = false;
			progressBar.source = fileRef;
			progressBar.setSize(390, 12);
			
			try 
			{ 
				var imageTypes : FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", 
															 "*.jpg; *.jpeg; *.gif; *.png"); 
			    var success : Boolean = fileRef.browse([imageTypes]);
			} 
			catch (error:Error) 
			{ 
			    trace("Unable to browse for files."); 
			}
						
			// Handlers.
			function selectHandler(event : Event) : void { 
			    var urlRequest : URLRequest = new URLRequest(_glob.url) ;
				var urlVars : URLVariables = new URLVariables();
				
				urlRequest.method = URLRequestMethod.POST;
				urlVars.action = "upload_background";
				urlVars.filename = "background"+String(_glob.mapId)+".img";
				urlRequest.data = urlVars;
			    
				try 
				{ 
			        fileRef.upload(urlRequest);
					_instance.addChild(progressBar);
					
					loadPictBtn.enabled = false;
					clearPictBtn.enabled = false;
					okBtn.enabled = false;
					cancelBtn.enabled = false;
			    } 
				catch (error:Error) 
				{ 
			        trace("Unable to upload file.");
					loadPictBtn.enabled = true;
					clearPictBtn.enabled = true;
					okBtn.enabled = true;
					cancelBtn.enabled = true;
    			} 
			}
			
			function completeHandler(event : Event) : void { 
    			//trace("uploaded");
				_instance.removeChild(progressBar);
				loadPictBtn.enabled = true;
				clearPictBtn.enabled = true;
				okBtn.enabled = true;
				cancelBtn.enabled = true;
				
				var urlRequest : URLRequest = new URLRequest(_glob.url) ;
				var urlVars : URLVariables = new URLVariables();
				
				urlRequest.method = URLRequestMethod.POST;
				urlVars.action = "download_background";
				urlVars.filename = "background"+String(_glob.mapId)+".img";
				urlRequest.data = urlVars;
				_glob.scene.loadBackgroundURL(urlRequest);
			}
			
			function progressHandler(e : ProgressEvent) : void {
				//trace(e.bytesLoaded+"/"+e.bytesTotal);
			}
			
			function httpStatusHandler(e : HTTPStatusEvent) : void {
				//trace(e.toString());
			}
		}
		
		private function clearBackground(e : MouseEvent) : void {
			_glob.deleteBackground();
		}
	}
}