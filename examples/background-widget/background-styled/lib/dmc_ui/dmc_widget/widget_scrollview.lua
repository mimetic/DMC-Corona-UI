--====================================================================--
-- dmc_ui/dmc_widget/widget_scrollview.lua
--
-- Documentation: http://docs.davidmccuskey.com/dmc+corona+ui
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2015 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]



--====================================================================--
--== DMC Corona UI : ScrollView Widget
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI : newScrollView
--====================================================================--



--====================================================================--
--== Imports


local AxisMotion = require( ui_find( 'dmc_widget.widget_scrollview.axis_motion' ) )
local Gesture = require 'dmc_gestures'
local Objects = require 'dmc_objects'
local TouchMgr = require 'dmc_touchmanager'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )
local Scroller = require( ui_find( 'dmc_widget.widget_scrollview.scroller' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

-- local mabs = math.abs
-- local sfmt = string.format
-- local tinsert = table.insert
-- local tremove = table.remove
-- local tstr = tostring
local tcancel = timer.cancel
local tdelay = timer.performWithDelay
local type = _G.type

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== ScrollView Widget Class
--====================================================================--

--- Scroll View Widget.
-- a container view which can scroll independently on two axis (X/Y).
--
-- @classmod Widget.ScrollView
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newScrollView()

local ScrollView = newClass( WidgetBase, { name="ScrollView" } )

--- Class Constants.
-- @section

--== Class Constants

ScrollView.HIT_TOP_LIMIT = 'top_limit_hit'
ScrollView.HIT_BOTTOM_LIMIT = 'bottom_limit_hit'
ScrollView.HIT_LEFT_LIMIT = 'left_limit_hit'
ScrollView.HIT_RIGHT_LIMIT = 'right_limit_hit'

--== Style/Theme Constants

ScrollView.STYLE_CLASS = nil -- added later
ScrollView.STYLE_TYPE = uiConst.SCROLLVIEW

-- TODO: hook up later
-- ScrollView.DEFAULT = 'default'

-- ScrollView.THEME_STATES = {
-- 	ScrollView.DEFAULT,
-- }


--== Event Constants

--- ScrollView event constant.
-- used when setting up event listeners.
--
-- @usage
-- widget:addEventListener( widget.EVENT, listener )


ScrollView.EVENT = 'scrollview-widget-event'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function ScrollView:__init__( params )
	-- print( "ScrollView:__init__", params )
	params = params or {}
	if params.bounceIsActive==nil then params.bounceIsActive=true end
	if params.horizontalScrollEnabled==nil then params.horizontalScrollEnabled=true end
	if params.lowerHorizontalOffset==nil then params.lowerHorizontalOffset = 0 end
	if params.lowerVerticalOffset==nil then params.lowerVerticalOffset = 0 end
	if params.scrollWidth==nil then params.scrollWidth=dUI.WIDTH end
	if params.scrollHeight==nil then params.scrollHeight=dUI.HEIGHT end
	if params.upperHorizontalOffset==nil then params.upperHorizontalOffset = 0 end
	if params.upperVerticalOffset==nil then params.upperVerticalOffset = 0 end
	if params.verticalScrollEnabled==nil then params.verticalScrollEnabled=true end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties in this class

	self._contentPosition = {x=0,y=0}
	self._contentPosition_dirty=true

	-- self._enterFrameIterator = nil

	self._hasMoved = false
	self._isMoving = false

	self._scrollWidth = params.scrollWidth
	self._scrollWidth_dirty=true
	self._scrollHeight = params.scrollHeight
	self._scrollHeight_dirty=true

	-- controlled by Directional Lock Enabled
	self._scrollBlockedH = false
	self._scrollBlockedV = false

	self._returnFocus = nil -- return focus callback
	self._returnFocusCancel = nil -- return focus callback
	self._returnFocus_t = nil -- return focus timer

	-- properties from style

	self._alwaysBounceVertically = false
	self._alwaysBounceHorizontally = false

	self._isDirectionalLockEnabled = false

	self._showHorizontalScrollIndicator = false
	self._showVerticalScrollIndicator = false

	self._stopMotion = false

	-- save params for axis controllers
	self._tmp_params = params -- tmp

	--== Display Groups ==--

	--== Object References ==--

	self._axis_x = nil -- y-axis motion
	self._axis_y = nil -- x-axis motion
	self._axis_f = nil -- axis event handler (both)

	self._gesture = nil -- pan gesture
	self._gesture_f = nil -- callback

	self._rectBg = nil -- background object, touch area

	self._scroller = nil -- our scroll area
	self._scroller_dirty=true

end

--[[
function ScrollView:__undoInit__()
	-- print( "ScrollView:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]

--== createView

function ScrollView:__createView__()
	-- print( "ScrollView:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o

	-- local background, gesture hit area

	o = display.newRect( 0,0,0,0 )
	o.anchorX, o.anchorY = 0, 0
	o:setFillColor( 1,0,0,0.4 )
	self._dgBg:insert( o )
	self._rectBg = o

end

function ScrollView:__undoCreateView__()
	-- print( "ScrollView:__undoCreateView__" )
	self._rectBg:removeSelf()
	self._rectBg=nil
	--==--
	self:superCall( '__undoCreateView__' )
end


--== initComplete

function ScrollView:__initComplete__()
	-- print( "ScrollView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local o, f, tmp

	f = self:createCallback( self._gestureEvent_handler )
	o = Gesture.newPanGesture( self._rectBg, { touches=1, threshold=0 } )
	o:addEventListener( o.EVENT, f )
	self._gesture = o
	self._gesture_f = f

	self._axis_f = self:createCallback( self._axisEvent_handler )
	self:_createAxisMotionX()
	self:_createAxisMotionY()

	--== Use Setters, after axis motion objects are created
	tmp = self._tmp_params

	self.bounceIsActive = tmp.bounceIsActive

	self.horizontalScrollEnabled = tmp.horizontalScrollEnabled
	self.upperHorizontalOffset = tmp.upperHorizontalOffset
	self.lowerHorizontalOffset = tmp.lowerHorizontalOffset

	self.verticalScrollEnabled = tmp.verticalScrollEnabled
	self.upperVerticalOffset = tmp.upperVerticalOffset
	self.lowerVerticalOffset = tmp.lowerVerticalOffset

	self._tmp_params = nil
end

function ScrollView:__undoInitComplete__()
	--print( "ScrollView:__undoInitComplete__" )
	local o, f

	self:_removeAxisMotionX()
	self:_removeAxisMotionY()

	o = self._gesture
	o:removeEventListener( o.EVENT, self._gesture_f )
	self._gesture_f = nil
	self._gesture = nil

	self:_removeScroller()

	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ScrollView.initialize( manager, params )
	-- print( "ScrollView.initialize" )
	dUI = manager

	local Style = dUI.Style
	ScrollView.STYLE_CLASS = Style.ScrollView

	Style.registerWidget( ScrollView )
end



--====================================================================--
--== Public Methods


--- description of parameters for method :setContentPosition().
-- this is the complete list of properties for the :setContentPosition() parameter table. Though x or y are optional, at least one of them must be specified.
--
-- @within Parameters
-- @tfield[opt] number x The x position to scroll to.
-- @tfield[opt] number y The y position to scroll to.
-- @tfield[opt=500] number Time duration for scroll animation, in milliseconds. set to 0 for immediate transition.
-- @tfield[opt] func onComplete a function to call when the animation is complete
-- @table .setContentPositionParams


--== .alwaysBounceHorizontally

-- set/get activate rebound action when hitting a scroll-limit.
-- defaults to true.
-- @TODO
-- @within Properties
-- @function .alwaysBounceHorizontally
-- @usage widget.alwaysBounceHorizontally = true
-- @usage print( widget.alwaysBounceHorizontally )

function ScrollView.__getters:alwaysBounceHorizontally()
	-- print( "ScrollView.__getters:bounceIsActive" )
	return ( self._axis_x.alwaysBounceHorizontally and self._axis_y.alwaysBounceHorizontally )
end
function ScrollView.__setters:alwaysBounceHorizontally( value )
	-- print( "ScrollView.__setters:alwaysBounceHorizontally", value )
	self._axis_x.alwaysBounceHorizontally = value
	self._axis_y.alwaysBounceHorizontally = value
end

--== .alwaysBounceVertically

-- set/get activate rebound action when hitting a scroll-limit.
-- defaults to true.
-- @TODO
-- @within Properties
-- @function .alwaysBounceVertically
-- @usage widget.alwaysBounceVertically = true
-- @usage print( widget.alwaysBounceVertically )

function ScrollView.__getters:alwaysBounceVertically()
	-- print( "ScrollView.__getters:bounceIsActive" )
	return ( self._axis_x.alwaysBounceVertically and self._axis_y.alwaysBounceVertically )
end
function ScrollView.__setters:alwaysBounceVertically( value )
	-- print( "ScrollView.__setters:alwaysBounceVertically", value )
	self._axis_x.alwaysBounceVertically = value
	self._axis_y.alwaysBounceVertically = value
end


--== .bounceIsActive

--- set/get activate rebound action when hitting a scroll-limit.
-- defaults to true.
--
-- @within Properties
-- @function .bounceIsActive
-- @usage widget.bounceIsActive = true
-- @usage print( widget.bounceIsActive )

function ScrollView.__getters:bounceIsActive()
	-- print( "ScrollView.__getters:bounceIsActive" )
	return ( self._axis_x.bounceIsActive and self._axis_y.bounceIsActive )
end
function ScrollView.__setters:bounceIsActive( value )
	-- print( "ScrollView.__setters:bounceIsActive", value )
	self._axis_x.bounceIsActive = value
	self._axis_y.bounceIsActive = value
end

--== .lowerHorizontalOffset

--- set/get the lower horizontal offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .lowerHorizontalOffset
-- @usage widget.lowerHorizontalOffset = 30
-- @usage print( widget.lowerHorizontalOffset )

function ScrollView.__getters:lowerHorizontalOffset()
	-- print( "ScrollView.__getters:lowerHorizontalOffset" )
	return self._axis_x.lowerOffset
end
function ScrollView.__setters:lowerHorizontalOffset( value )
	-- print( "ScrollView.__setters:lowerHorizontalOffset", value )
	self._axis_x.lowerOffset = value
end

--== .lowerVerticalOffset

--- set/get the lower vertical offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .lowerVerticalOffset
-- @usage widget.lowerVerticalOffset = 30
-- @usage print( widget.lowerVerticalOffset )

function ScrollView.__getters:lowerVerticalOffset()
	-- print( "ScrollView.__getters:lowerVerticalOffset" )
	return self._axis_y.lowerOffset
end
function ScrollView.__setters:lowerVerticalOffset( value )
	-- print( "ScrollView.__setters:lowerVerticalOffset", value )
	self._axis_y.lowerOffset = value
end

--== .isDirectionalLockEnabled

-- set/get whether bouncing on edges (TBD).
-- @TODO
-- @within Properties
-- @function .directionalLockEnabled
-- @usage widget.directionalLockEnabled = true
-- @usage print( widget.directionalLockEnabled )

function ScrollView.__getters:isDirectionalLockEnabled()
	-- print( "ScrollView.__getters:isDirectionalLockEnabled" )
	return self._isDirectionalLockEnabled
end
function ScrollView.__setters:isDirectionalLockEnabled( value )
	-- print( "ScrollView.__setters:isDirectionalLockEnabled", value )
	self._isDirectionalLockEnabled = value
end

--== .horizontalScrollEnabled

--- set/get control ScrollView horizontal motion.
-- setting to false will disable scrolling in X-axis.
--
-- @within Properties
-- @function .horizontalScrollEnabled
-- @usage widget.horizontalScrollEnabled = true
-- @usage print( widget.horizontalScrollEnabled )

function ScrollView.__getters:horizontalScrollEnabled()
	-- print( "ScrollView.__getters:horizontalScrollEnabled" )
	return self._axis_x.scrollIsEnabled
end
function ScrollView.__setters:horizontalScrollEnabled( value )
	-- print( "ScrollView.__setters:horizontalScrollEnabled", value )
	self._axis_x.scrollIsEnabled = value
end

--== .verticalScrollEnabled

--- set/get control ScrollView vertical motion.
-- setting to false will disable scrolling in Y-axis.
--
-- @within Properties
-- @function .verticalScrollEnabled
-- @usage widget.verticalScrollEnabled = true
-- @usage print( widget.verticalScrollEnabled )

function ScrollView.__getters:verticalScrollEnabled()
	-- print( "ScrollView.__getters:verticalScrollEnabled" )
	return self._axis_y.scrollIsEnabled
end
function ScrollView.__setters:verticalScrollEnabled( value )
	-- print( "ScrollView.__setters:verticalScrollEnabled", value )
	self._axis_y.scrollIsEnabled = value
end

--== .scrollWidth

--- set/get width of scroll area.
-- this is the total scroll area, not just the scroll view port.
-- value must be greater than zero.
--
-- @within Properties
-- @function .scrollWidth
-- @usage widget.scrollWidth = 1000
-- @usage print( widget.scrollWidth )

function ScrollView.__getters:scrollWidth()
	-- print( "ScrollView.__getters:scrollWidth" )
	return self._scrollWidth
end
function ScrollView.__setters:scrollWidth( value )
	-- print( "ScrollView.__setters:scrollWidth", value )
	if self._scrollWidth==value then return end
	self._scrollWidth = value
	self._scrollWidth_dirty=true
end

--== .scrollHeight

--- set/get height of scroll area.
-- this is the total scroll area, not just the scroll view port.
-- value must be greater than zero.
--
-- @within Properties
-- @function .scrollHeight
-- @usage widget.scrollHeight = 1000
-- @usage print( widget.scrollHeight )

function ScrollView.__getters:scrollHeight()
	-- print( "ScrollView.__getters:scrollHeight" )
	return self._scrollHeight
end
function ScrollView.__setters:scrollHeight( value )
	-- print( "ScrollView.__setters:scrollHeight", value )
	if self._scrollHeight==value then return end
	self._scrollHeight = value
	self._scrollHeight_dirty=true
end

--== .upperHorizontalOffset

--- set/get the upper horizontal offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .upperHorizontalOffset
-- @usage widget.upperHorizontalOffset = 30
-- @usage print( widget.upperHorizontalOffset )

function ScrollView.__getters:upperHorizontalOffset()
	-- print( "ScrollView.__getters:upperHorizontalOffset" )
	return self._axis_x.upperOffset
end
function ScrollView.__setters:upperHorizontalOffset( value )
	-- print( "ScrollView.__setters:upperHorizontalOffset", value )
	self._axis_x.upperOffset = value
end

--== .upperVerticalOffset

--- set/get the upper vertical offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .upperVerticalOffset
-- @usage widget.upperVerticalOffset = 30
-- @usage print( widget.upperVerticalOffset )

function ScrollView.__getters:upperVerticalOffset()
	-- print( "ScrollView.__getters:upperVerticalOffset" )
	return self._axis_y.upperOffset
end
function ScrollView.__setters:upperVerticalOffset( value )
	-- print( "ScrollView.__setters:upperVerticalOffset", value )
	self._axis_y.upperOffset = value
end


--======================================================--
-- Methods

--== .contentPosition

--- Returns the x and y coordinates of the ScrollView content.
--
-- @within Methods
-- @function :getContentPosition
-- @treturn number x
-- @treturn number y
-- @usage local x, y = widget:getContentPosition()

function ScrollView:getContentPosition()
	-- print( "ScrollView.__getters:contentPosition" )
	return self._axis_x.value, self._axis_y.value
end

--- Scroll to a specific x and/or y position.
-- Moves content position to x/y over a certain time duration.
--
-- @within Methods
-- @function :setContentPosition
-- @tab params table of coordinates, see @{setContentPositionParams}
-- @usage widget:setContentPosition( { x=-20, y=-35 } )

function ScrollView:setContentPosition( params )
	-- print( "ScrollView:setContentPosition", params )
	assert( type(params)=='table' )
	--==--
	local xIsNum = (type(params.x)=='number')
	local yIsNum = (type(params.y)=='number')
	assert( xIsNum or type(params.x)=='nil' )
	assert( yIsNum or type(params.y)=='nil' )

	local tcf -- transition complete func
	if params.onComplete then
		if xIsNum and yIsNum then
			tcf = Utils.getTransitionCompleteFunc( 2, params.onComplete )
		else
			tcf = params.onComplete
		end
	end
	if xIsNum then
		self._axis_x:scrollToPosition( params.x, {
			onComplete=tcf, time=params.time
		})
	end
	if yIsNum then
		self._axis_y:scrollToPosition( params.y, {
			onComplete=tcf, time=params.time
		})
	end
end


-- completes process of giving up focus.
-- the main point it to terminate any touch action on ScrollView
--
function ScrollView:relinquishFocus( event )
	-- print( "ScrollView:relinquishFocus" )
	event.phase='cancelled'
	self._rectBg:dispatchEvent( event )
end

--- give touch focus to the ScrollView.
-- the ScrollView will take the touch event and set the focus to itself. _event must be from DMC TouchManager_.
--
-- @within Methods
-- @function :takeFocus
-- @param event Touch Event from DMC TouchManager
-- @usage widget:takeFocus( event )

function ScrollView:takeFocus( event )
	TouchMgr.setFocus( self._rectBg, event.id )

	-- stop existing returnFocus timer, if any
	if self._returnFocusCancel then self._returnFocusCancel() end

	self._tmpTouchEvt = event

	if event.returnFocus then
		-- we have returnFocus request, so do setup for it

		local rFCallback = event.returnFocus
		local rFTarget = event.returnTarget
		assert( rFTarget and rFCallback )

		local returnFocus_f, cancelFocus_f

		-- returns focus back to initiator
		-- this is set on timer, either it gets cancelled
		-- or the timer goes off and initiates returnFocus
		--
		returnFocus_f = function( state )
			-- print( "ScrollView: returnFocus" )

			cancelFocus_f()

			local e = self._tmpTouchEvt

			local evt = {
				name=e.name,
				id=e.id,
				time=e.time,
				x=e.x,
				y=e.y,
				xStart=e.xStart,
				yStart=e.yStart,
			}

			if state then
				-- coming from end touch
				-- make event 'ended'
				evt.phase = state
			else
				-- coming from timer
				-- terminate current touch action
				-- then send 'began' event
				self:relinquishFocus( e )
				evt.phase = 'began'
			end

			evt.target = rFTarget
			rFCallback( evt )
		end

		cancelFocus_f = function()
			-- print( 'ScrollerBase: cancelFocus' )

			if self._returnFocus_t then
				tcancel( self._returnFocus_t )
				self._returnFocus_t = nil
			end

			self._returnFocus = nil
			self._returnFocusCancel = nil
		end

		self._returnFocus = returnFocus_f
		self._returnFocusCancel = cancelFocus_f
		self._returnFocus_t = tdelay( 100, function(e) returnFocus_f() end )

	end

	-- remove previous focus, if any

	TouchMgr.unsetFocus( event.target, event.id )
	-- send new event through touch area
	event.phase='began'
	event.target=self._rectBg
	event.target:dispatchEvent( event )
end



--====================================================================--
--== Private Methods



function ScrollView:_removeAxisMotionX()
	-- print( "ScrollView:_removeAxisMotionX" )
	local o = self._axis_x
	if not o then return end
	o:removeSelf()
	self._axis_x = nil
end

function ScrollView:_createAxisMotionX()
	-- print( "ScrollView:_createAxisMotionX" )
	self:_removeAxisMotionX()
	local o = AxisMotion:new{
		id='x',
		length=self._width,
		scrollLength=self._scrollWidth,
		callback=self._axis_f
	}
	self._axis_x = o
end


function ScrollView:_removeAxisMotionY()
	-- print( "ScrollView:_removeAxisMotionY" )
	local o = self._axis_y
	if not o then return end
	o:removeSelf()
	self._axis_y = nil
end

function ScrollView:_createAxisMotionY()
	-- print( "ScrollView:_createAxisMotionY" )
	self:_removeAxisMotionY()
	local o = AxisMotion:new{
		id='y',
		length=self._height,
		scrollLength=self._scrollHeight,
		callback=self._axis_f
	}
	self._axis_y = o
end


function ScrollView:_removeScroller()
	-- print( "ScrollView:_removeScroller" )
	local o = self._scroller
	if not o then return end
	o:removeSelf()
	self._scroller = nil
end

function ScrollView:_createScroller()
	-- print( "ScrollView:_createScroller" )

	self:_removeScroller()

	local o = Scroller:new{
		width=self._scrollWidth,
		height=self._scrollHeight
	}
	self:_addSubView( o )
	self._scroller = o

end


function ScrollView:_loadViews()
	self:_createScroller()
end



function ScrollView:__commitProperties__()
	-- print( 'ScrollView:__commitProperties__' )
	local style = self.curr_style

	local view = self.view
	local bg = self._rectBg
	local scr = self._scroller

	--== position sensitive

	-- set text string

	if self._text_dirty then
		self._text_dirty=false

		self._width_dirty=true
		self._height_dirty=true
	end

	if self._align_dirty then
		self._align_dirty = false
	end

	if self._width_dirty then
		-- print("width", self._width)
		bg.width = self._width
		self._width_dirty=false
	end
	if self._height_dirty then
		bg.height = self._height
		self._height_dirty=false
	end

	if self._scrollWidth_dirty then
		local value = self._scrollWidth
		scr.width = value
		if self._axis_x then
			self._axis_x.scrollLength = value
		end
		self._scrollWidth_dirty=false
	end
	if self._scrollHeight_dirty then
		local value = self._scrollHeight
		scr.height = value
		if self._axis_y then
			self._axis_y.scrollLength = value
		end
		self._scrollHeight_dirty=false
	end


	if self._marginX_dirty then
		self._marginX_dirty=false

		self._rectBgWidth_dirty=true
		self._textX_dirty=true
		self._displayWidth_dirty=true
	end
	if self._marginY_dirty then
		-- reminder, we don't set text height
		self._marginY_dirty=false

		self._rectBgHeight_dirty=true
		self._textY_dirty=true
		self._displayHeight_dirty=true
	end

	-- bg width/height

	if self._rectBgWidth_dirty then
		self._rectBgWidth_dirty=false
	end
	if self._rectBgHeight_dirty then
		self._rectBgHeight_dirty=false
	end


	-- anchorX/anchorY

	if self._anchorX_dirty then
		-- bg.anchorX = style.anchorX
		self._anchorX_dirty=false

		self._x_dirty=true
		self._textX_dirty=true
	end
	if self._anchorY_dirty then
		-- bg.anchorY = style.anchorY
		self._anchorY_dirty=false

		self._y_dirty=true
		self._textY_dirty=true
	end

	-- x/y

	if self._x_dirty then
		view.x = self._x
		self._x_dirty = false
	end
	if self._y_dirty then
		view.y = self._y
		self._y_dirty = false
	end

	-- if self._contentPosition_dirty then
	-- 	scr.x = self._contentPosition.x
	-- 	scr.y = self._contentPosition.y
	-- 	self._contentPosition_dirty=false
	-- end

	--== non-position sensitive

	-- textColor/fillColor

	if self._fillColor_dirty or self._debugOn_dirty then
		if style.debugOn==true then
			bg:setFillColor( 1,0,0,0.2 )
		else
			bg:setFillColor( unpack( style.fillColor ))
		end
		self._fillColor_dirty=false
		self._debugOn_dirty=false
	end
	if self._strokeColor_dirty then
		-- bg:setStrokeColor( unpack( style.strokeColor ))
		self._strokeColor_dirty=false
	end
	if self._strokeWidth_dirty then
		-- bg.strokeWidth = style.strokeWidth
		self._strokeWidth_dirty=false
	end
	if self._textColor_dirty then
		-- display:setScrollViewColor( unpack( style.textColor ) )
		self._textColor_dirty=false
	end

end



--====================================================================--
--== Event Handlers


function ScrollView:stylePropertyChangeHandler( event )
	-- print( "ScrollView:stylePropertyChangeHandler", event.type, event.property )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- print( "Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty = true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._align_dirty=true
		self._fillColor_dirty = true
		self._font_dirty=true
		self._fontSize_dirty=true
		self._marginX_dirty=true
		self._marginY_dirty=true
		self._strokeColor_dirty=true
		self._strokeWidth_dirty=true

		self._text_dirty=true
		self._textColor_dirty=true

		property = etype

	else
		if property=='debugActive' then
			self._debugOn_dirty=true
		elseif property=='width' then
			self._width_dirty=true
		elseif property=='height' then
			self._height_dirty=true
		elseif property=='anchorX' then
			self._anchorX_dirty=true
		elseif property=='anchorY' then
			self._anchorY_dirty=true

		elseif property=='align' then
			self._align_dirty=true
		elseif property=='fillColor' then
			self._fillColor_dirty=true
		elseif property=='font' then
			self._font_dirty=true
		elseif property=='fontSize' then
			self._fontSize_dirty=true
		elseif property=='marginX' then
			self._marginX_dirty=true
		elseif property=='marginY' then
			self._marginY_dirty=true
		elseif property=='strokeColor' then
			self._strokeColor_dirty=true
		elseif property=='strokeWidth' then
			self._strokeWidth_dirty=true
		elseif property=='text' then
			self._text_dirty=true
		elseif property=='textColor' then
			self._textColor_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end





function ScrollView:_gestureEvent_handler( event )
	-- print( "ScrollView:_gestureEvent_handler", event.phase )
	local etype = event.type
	local phase = event.phase
	local gesture = event.target
	local f = self._returnFocusCancel

	-- Utils.print( event )
	local evt = {
		name='touch',
		phase=event.phase,
		time=event.time,
		value=0, -- this is holder for x/y
		start=0, -- this is holder for xStart/yStart
	}

	if etype == gesture.GESTURE then
		if phase=='began' then
			evt.phase = 'began'
			if self._axis_x then
				evt.value = event.x
				evt.start = event.xStart
				self._axis_x:touch( evt )
			end
			if self._axis_y then
				evt.value = event.y
				evt.start = event.yStart
				self._axis_y:touch( evt )
			end
		elseif phase=='changed' then
			-- if changed, then already know movement was enough
			-- because Pan Gesture will filter movement
			f = self._returnFocusCancel
			if f then f() end
			evt.phase = 'moved'
			if self._axis_x then
				evt.value = event.x
				evt.start = event.xStart
				self._axis_x:touch( evt )
			end
			if self._axis_y then
				evt.value = event.y
				evt.start = event.yStart
				self._axis_y:touch( evt )
			end
		else
			evt.phase = 'ended'
			if self._axis_x then
				evt.value = event.x
				evt.start = event.xStart
				self._axis_x:touch( evt )
			end
			if self._axis_y then
				evt.value = event.y
				evt.start = event.yStart
				self._axis_y:touch( evt )
			end
			-- if ended (quickly), like a tap
			-- then give back to the initiator
			f = self._returnFocus
			if f then f( 'ended' ) end
		end
	end
end


function ScrollView:_axisEvent_handler( event )
	-- print( "ScrollView:_axisEvent_handler", event.state )
	local state = event.state
	-- local velocity = event.velocity
	if event.id=='x' then
		self._scroller.x = event.value
	else
		self._scroller.y = event.value
	end
end




return ScrollView
