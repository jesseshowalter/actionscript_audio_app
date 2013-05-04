package org.phpz.media
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.utils.Timer;
    import org.phpz.media.events.AudioEvent;
    
    /**
     * 音频播放
     * @author Seven Yu
     */
    public class MySound extends EventDispatcher
    {
        
        private var _sound:Sound;
        private var _sndChnl:SoundChannel;
        
        private var _isPaused:Boolean = false;
        private var _isPlaying:Boolean = false;
        
        private var _url:String = '';
        
        private var _volume:Number = 0.77;
        private var _position:Number = 0;
        
        private var _playEvtTimer:Timer;
        
        public function MySound():void
        {
        
        }
        
        /**
         * 添加 on_progress 监听时开启计时器
         * @param	type
         * @param	listener
         * @param	useCapture
         * @param	priority
         * @param	useWeakReference
         */
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            
            switch (type)
            {
                case AudioEvent.ON_PROGRESS: 
                {
                    _playEvtTimer = new Timer(200);
                    _playEvtTimer.addEventListener(TimerEvent.TIMER, playTimerHandler);
                    _playEvtTimer.start();
                    break;
                }
                default: 
                {
                    break;
                }
            }
        }
        
        /**
         * 定时派发播放进度事件
         * @param	evt
         */
        private function playTimerHandler(evt:TimerEvent):void
        {
            dispatchEvent(new AudioEvent(AudioEvent.ON_PROGRESS, {position: this.position, length: this.length}));
        }
        
        /**
         * 开始播放
         * @param	url        播放文件地址
         * @param	startTime  开始时间 (毫秒)
         */
        public function play(url:String, startTime:Number = 0):void
        {
            _url = url;
            
            var ur:URLRequest = new URLRequest(url);
            var lc:SoundLoaderContext = new SoundLoaderContext(1000, true);
            
            _sound = new Sound(ur, lc);
            _sound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            _sound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            _sound.addEventListener(Event.COMPLETE, loadCompleteHandler);
            
            // 初始化 sound channel
            playPosition(startTime);
            
            dispatchEvent(new AudioEvent(AudioEvent.ON_START, {url: _url, position: startTime, length: this.length}));
        }
        
        /**
         * 加载进度
         * @param	evt
         */
        private function progressHandler(evt:ProgressEvent):void
        {
            dispatchEvent(new AudioEvent(AudioEvent.ON_LOAD_PROGRESS, {bytesLoaded: evt.bytesLoaded, bytesTotal: evt.bytesTotal}));
        }
        
        private function loadCompleteHandler(evt:Event):void
        {
            dispatchEvent(new AudioEvent(AudioEvent.ON_LOAD_COMPLETE, {bytesTotal: _sound.bytesTotal}));
        }
        
        /**
         * 统一的初始化播放
         * @param	startTime
         */
        private function playPosition(startTime:Number):void
        {
            if (_sndChnl)
            {
                _sndChnl.stop();
            }
            
            _sndChnl = _sound.play(startTime, 0, new SoundTransform(_volume));
            _sndChnl.addEventListener(Event.SOUND_COMPLETE, completeHandler);
            
            _isPaused = false;
            _isPlaying = true;
            
            _position = startTime;
            
            _playEvtTimer && _playEvtTimer.start();
        }
        
        /**
         * IO Error handler
         * @param	e
         */
        private function errorHandler(evt:IOErrorEvent):void
        {
            dispatchEvent(new AudioEvent(AudioEvent.ON_IO_ERROR, evt));
        }
        
        /**
         * sound complete
         * @param	e
         */
        private function completeHandler(evt:Event):void
        {
            _playEvtTimer && _playEvtTimer.stop();
            dispatchEvent(new AudioEvent(AudioEvent.ON_COMPLETE, {url: _url}));
        }
        
        /**
         * pause
         */
        public function pause():void
        {
            if (!_sndChnl || !_isPlaying || _isPaused)
            {
                return;
            }
            
            _isPaused = true;
            
            _playEvtTimer && _playEvtTimer.stop();
            
            _position = _sndChnl.position;
            dispatchEvent(new AudioEvent(AudioEvent.ON_PAUSE, {position: this.position, length: this.length}));
            
            _sndChnl.stop();
        }
        
        /**
         * resume
         */
        public function resume():void
        {
            if (!_sndChnl || !_isPlaying || !_isPaused)
            {
                return;
            }
            
            _isPaused = false;
            
            playPosition(_position)
            
            dispatchEvent(new AudioEvent(AudioEvent.ON_RESUME, {position: this.position, length: this.length}));
        }
        
        /**
         * stop
         */
        public function stop():void
        {
            if (!_sndChnl || !_isPlaying)
            {
                return;
            }
            
            _isPlaying = false;
            
            _playEvtTimer && _playEvtTimer.stop();
            
            dispatchEvent(new AudioEvent(AudioEvent.ON_STOP, { position: this.position, length: this.length } ));
            
            _position = 0;
            _sndChnl.stop();
        }
        
        /**
         * file url
         */
        public function get url():String
        {
            return _url;
        }
        
        /**
         * sound length
         */
        public function get length():Number
        {
            return _sound ? _sound.length : 0;
        }
        
        /**
         * position (read / write)
         */
        public function get position():Number
        {
            return _sndChnl ? _sndChnl.position : 0;
        }
        
        public function set position(value:Number):void
        {
            value = Math.min(this.length, Math.max(0, value));
            
            playPosition(value);
        }
        
        /**
         * mute
         */
        public function mute():void
        {
            this.volume = 0;
        }
        
        /**
         * volume (read / write)
         */
        public function get volume():Number
        {
            return _volume;
        }
        
        public function set volume(value:Number):void
        {
            if (!_sndChnl)
            {
                return;
            }
            
            if (value > 0)
            {
                dispatchEvent(new AudioEvent(AudioEvent.ON_VOL_CHANGED, {volume: value}));
            }
            else
            {
                dispatchEvent(new AudioEvent(AudioEvent.ON_MUTE, {volume: _volume}));
            }
            
            _volume = value;
            _sndChnl.soundTransform = new SoundTransform(value);
        }
    
    }

}