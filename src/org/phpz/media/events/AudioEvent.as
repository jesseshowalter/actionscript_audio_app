package org.phpz.media.events
{
    import flash.events.Event;
    
    /**
     * ...
     * @author Seven Yu
     */
    public class AudioEvent extends Event
    {
        
        private var _data:Object;
        
        public static const ON_START:String = 'on_start';
        public static const ON_PAUSE:String = 'on_pause';
        public static const ON_RESUME:String = 'on_resume';
        public static const ON_STOP:String = 'on_stop';
        
        public static const ON_PROGRESS:String = 'on_progress';
        public static const ON_COMPLETE:String = 'on_complete';
        
        public static const ON_VOL_CHANGED:String = 'on_vol_changed';
        public static const ON_MUTE:String = 'on_mute';
        
        public static const ON_IO_ERROR:String = 'on_io_error';
        
        public static const ON_LOAD_PROGRESS:String = 'on_load_progress';
        public static const ON_LOAD_COMPLETE:String = 'on_load_complete';
        
        
        public function AudioEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            _data = data;
            
            super(type, bubbles, cancelable);
        }
        
        public function get data():Object
        {
            return _data;
        }
        
        public override function clone():Event
        {
            return new AudioEvent(type, bubbles, cancelable);
        }
        
        public override function toString():String
        {
            return formatToString("AudioEvent", "type", "bubbles", "cancelable", "eventPhase");
        }
    
    }

}