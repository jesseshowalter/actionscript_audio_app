package org.phpz.media
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import org.phpz.media.events.AudioEvent;
    import org.phpz.slib.utils.FlashVars;
    import org.phpz.slib.utils.JSProxy;
    
    /**
     * ...
     * @author Seven Yu
     */
    public class Audio extends Sprite
    {
        
        private var mySound:MySound = new MySound();
        
        public function Audio():void
        {
            init();
            bindEvents();
            
            run();
        }
        
        private function init():void
        {
            // init flash variables
            FlashVars.init(loaderInfo);
            
            // init jsProxy
            JSProxy.init(FlashVars.getParam('fn', 'fn'));
            
            JSProxy.register('play', play);
            JSProxy.register('pause', pause);
            JSProxy.register('resume', resume);
            JSProxy.register('stop', stop);
            JSProxy.register('volume', volume);
            JSProxy.register('mute', mute);
            JSProxy.register('position', position);
        }
        
        private function play(url:String):void 
        {
            mySound.play(url);
        }
        
        private function pause():void 
        {
            mySound.pause();
        }
        
        private function resume():void 
        {
            mySound.resume();
        }
        
        private function stop():void 
        {
            mySound.stop();
        }
        
        private function volume(value:Number):void 
        {
            mySound.volume = value;
        }
        
        private function mute():void 
        {
            mySound.mute();
        }
        
        private function position(value:Number):void 
        {
            mySound.position = value;
        }
        
        private function bindEvents():void
        {
            if (!JSProxy.available)
            {
                return;
            }
            mySound.addEventListener(AudioEvent.ON_START, handler);
            mySound.addEventListener(AudioEvent.ON_PAUSE, handler);
            mySound.addEventListener(AudioEvent.ON_RESUME, handler);
            mySound.addEventListener(AudioEvent.ON_STOP, handler);
            
            mySound.addEventListener(AudioEvent.ON_PROGRESS, handler);
            mySound.addEventListener(AudioEvent.ON_COMPLETE, handler);
            
            mySound.addEventListener(AudioEvent.ON_MUTE, handler);
            mySound.addEventListener(AudioEvent.ON_VOL_CHANGED, handler);
            
            mySound.addEventListener(AudioEvent.ON_IO_ERROR, handler);
            
            mySound.addEventListener(AudioEvent.ON_LOAD_PROGRESS, handler);
            mySound.addEventListener(AudioEvent.ON_LOAD_COMPLETE, handler);
        }
        
        private function handler(e:AudioEvent):void 
        {
            JSProxy.call(e.type, e.data);
        }
        
        private function run():void 
        {
            CONFIG::debug
            {
                var index:int = 1;
                
                mySound.play('0.mp3');
                
                stage.addEventListener(MouseEvent.CLICK, 
                    function(evt:MouseEvent):void
                    {
                        if (++index > 2)
                        {
                            index = 1;
                        }
                        mySound.play(index + '.mp3');
                    } );
            }
        }
    }

}