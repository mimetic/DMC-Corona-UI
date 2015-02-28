--====================================================================--
-- dmc_widgets/widget_button/button_state_style.lua
--
-- Documentation: http://docs.davidmccuskey.com/
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
--== DMC Corona Widgets : Widget Button State Style
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--


local dmc_widget_data = _G.__dmc_widget
local dmc_widget_func = dmc_widget_data.func
local widget_find = dmc_widget_func.find



--====================================================================--
--== DMC Widgets : newButtonStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local WidgetUtils = require(widget_find( 'widget_utils' ))

local BaseStyle = require( widget_find( 'widget_style.base_style' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase

local sformat = string.format
local tinsert = table.insert

--== To be set in initialize()
local Widgets = nil



--====================================================================--
--== Button-State Style Class
--====================================================================--


local ButtonStateStyle = newClass( BaseStyle, {name="Button State Style"} )

--== Class Constants

ButtonStateStyle.TYPE = 'button-state'

ButtonStateStyle._CHILDREN = {
	label=true,
	background=true
}

ButtonStateStyle.__base_style__ = nil

-- child styles
ButtonStateStyle.LABEL_KEY = 'label'
ButtonStateStyle.LABEL_NAME = 'button-state-label'
ButtonStateStyle.BACKGROUND_KEY = 'background'
ButtonStateStyle.BACKGROUND_NAME = 'button-state-background'

ButtonStateStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	align=true,
	isHitActive=true,
	marginX=true,
	marginY=true,
	offsetX=true,
	offsetY=true,

	-- Copyable properties
	font=native.systemFont
}

ButtonStateStyle._EXCLUDE_PROPERTY_CHECK = nil

ButtonStateStyle._STYLE_DEFAULTS = {
	name='button-state-default-style',
	debugOn=false,
	width=100,
	height=40,
	anchorX=0.5,
	anchorY=0.5,

	align='center',
	isHitActive=true,
	marginX=0,
	marginY=0,
	offsetX=0,
	offsetY=0,

	label={
		textColor={0,0,0,1},
		font=native.systemFontBold,
		fontSize=10
	},
	background={
		type='rounded',
		view={
			fillColor={1,1,1,1},
			strokeWidth=1,
			strokeColor={0,0,0,1},
		}
	}

}

ButtonStateStyle._TEST_DEFAULTS = {
	name='button-state-test-style',
	debugOn=false,
	width=201,
	height=202,
	anchorX=204,
	anchorY=206,

	align='center-state',
	isHitActive=true,
	marginX=210,
	marginY=210,
	offsetX=212,
	offsetY=212,

	label={
		textColor={220,220,220,221},
		font=native.systemFontBold,
		fontSize=228
	},
	background={
		type='rounded',
		view={
			fillColor={230,230,230,231},
			strokeWidth=238,
			strokeColor={232,232,232,231},
		}
	}

}

ButtonStateStyle.MODE = BaseStyle.RUN_MODE
ButtonStateStyle._DEFAULTS = ButtonStateStyle._STYLE_DEFAULTS

--== Event Constants

ButtonStateStyle.EVENT = 'button-state-style-event'


--======================================================--
-- Start: Setup DMC Objects

function ButtonStateStyle:__init__( params )
	-- print( "ButtonStateStyle:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Style Properties ==--

	-- self._data
	-- self._inherit
	-- self._widget
	-- self._parent
	-- self._onProperty

	-- self._name
	-- self._debugOn
	-- self._width
	-- self._height
	-- self._anchorX
	-- self._anchorY

	self._align = nil
	self._isHitActive = nil
	self._marginX = nil
	self._marginY = nil
	self._offsetX = nil
	self._offsetY = nil

	--== Object Refs ==--

	-- these are other style objects
	self._background = nil -- Background
	self._label = nil -- Text

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ButtonStateStyle.initialize( manager, params )
	-- print( "ButtonStateStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=BaseStyle.RUN_MODE end
	--==--
	Widgets = manager

	if params.mode==BaseStyle.TEST_MODE then
		ButtonStateStyle.MODE = BaseStyle.TEST_MODE
		ButtonStateStyle._DEFAULTS = ButtonStateStyle._TEST_DEFAULTS
	end
	local defaults = ButtonStateStyle._DEFAULTS

	ButtonStateStyle._setDefaults( ButtonStateStyle, {defaults=defaults} )
end


-- create empty style structure
-- param data string, type of background view
--
function ButtonStateStyle.createStyleStructure( data )
	-- print( "ButtonStateStyle.createStyleStructure", data )
	return {
		label=Widgets.Style.Text.createStyleStructure(),
		background=Widgets.Style.Background.createStyleStructure( data )
	}
end


function ButtonStateStyle.addMissingDestProperties( dest, srcs )
	-- print( "ButtonStateStyle.addMissingDestProperties", dest, srcs )
	assert( dest )
	srcs = srcs or {}
	local lsrc = Utils.extend( srcs, {} )
	if lsrc.parent==nil then lsrc.parent=dest end
	if lsrc.main==nil then lsrc.main=ButtonStateStyle._DEFAULTS end
	lsrc.widget = ButtonStateStyle._DEFAULTS
	--==--

	dest = BaseStyle.addMissingDestProperties( dest, lsrc )

	for _, key in ipairs( { 'main', 'parent', 'widget' } ) do
		local src = lsrc[key] or {}

		if dest.align==nil then dest.align=src.align end
		if dest.isHitActive==nil then dest.isHitActive=src.isHitActive end
		if dest.marginX==nil then dest.marginX=src.marginX end
		if dest.marginY==nil then dest.marginY=src.marginY end
		if dest.offsetX==nil then dest.offsetX=src.offsetX end
		if dest.offsetY==nil then dest.offsetY=src.offsetY end

		--== Additional properties to be handed down to children

		if dest.font==nil then dest.font=src.font end
		if dest.fontSize==nil then dest.fontSize=src.fontSize end

	end

	dest = ButtonStateStyle._addMissingChildProperties( dest, lsrc )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function ButtonStateStyle._addMissingChildProperties( dest, srcs )
	-- print( "ButtonStateStyle._addMissingChildProperties", dest, srcs )
	assert( dest )
	srcs = srcs or {}
	local lsrc = { parent = dest }
	--==--
	local eStr = "ERROR: Style missing property '%s'"
	local StyleClass, child

	child = dest.label
	assert( child, sformat( eStr, 'label' ) )
	StyleClass = Widgets.Style.Text
	lsrc.main = srcs.main and srcs.main.label
	dest.label = StyleClass.addMissingDestProperties( child, lsrc )

	child = dest.background
	assert( child, sformat( eStr, 'background' ) )
	StyleClass = Widgets.Style.Background
	lsrc.main = srcs.main and srcs.main.background
	dest.background = StyleClass.addMissingDestProperties( child, lsrc )

	return dest
end


function ButtonStateStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "ButtonStateStyle.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.align~=nil and dest.align==nil) or force then
		dest.align=src.align
	end
	if (src.isHitActive~=nil and dest.isHitActive==nil) or force then
		dest.isHitActive=src.isHitActive
	end
	if (src.marginX~=nil and dest.marginX==nil) or force then
		dest.marginX=src.marginX
	end
	if (src.marginY~=nil and dest.marginY==nil) or force then
		dest.marginY=src.marginY
	end
	if (src.offsetX~=nil and dest.offsetX==nil) or force then
		dest.offsetX=src.offsetX
	end
	if (src.offsetY~=nil and dest.offsetY==nil) or force then
		dest.offsetY=src.offsetY
	end

	return dest
end




function ButtonStateStyle._verifyStyleProperties( src, exclude )
	-- print( "ButtonStateStyle._verifyStyleProperties", src, exclude )
	assert( src )
	--==--
	local emsg = "Style: requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	if not src.align then
		print(sformat(emsg,'align')) ; is_valid=false
	end
	if not src.isHitActive then
		print(sformat(emsg,'isHitActive')) ; is_valid=false
	end
	if not src.marginX then
		print(sformat(emsg,'marginX')) ; is_valid=false
	end
	if not src.marginY then
		print(sformat(emsg,'marginY')) ; is_valid=false
	end
	if not src.offsetX then
		print(sformat(emsg,'offsetX')) ; is_valid=false
	end
	if not src.offsetY then
		print(sformat(emsg,'offsetY')) ; is_valid=false
	end

	-- check sub-styles

	local child, StyleClass

	child = src.label
	StyleClass = child.class
	if not StyleClass._verifyStyleProperties( child, exclude ) then
		is_valid=false
	end

	child = src.background
	StyleClass = child.class
	if not StyleClass._verifyStyleProperties( child, exclude ) then
		is_valid=false
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--======================================================--
-- Access to sub-styles

function ButtonStateStyle.__getters:background()
	-- print( "ButtonStateStyle.__getters:background", self._background )
	return self._background
end
function ButtonStateStyle.__setters:background( data )
	-- print( "ButtonStateStyle.__setters:background", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Widgets.Style.Background
	local inherit = self._inherit and self._inherit._background or nil

	self._background = StyleClass:createStyleFrom{
		name=ButtonStateStyle.BACKGROUND_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}

end


function ButtonStateStyle.__getters:label()
	-- print( "ButtonStateStyle.__getters:label", data )
	return self._label
end
function ButtonStateStyle.__setters:label( data )
	-- print( "ButtonStateStyle.__setters:label", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Widgets.Style.Text
	local inherit = self._inherit and self._inherit._label

	self._label = StyleClass:createStyleFrom{
		name=ButtonStateStyle.LABEL_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end


--======================================================--
-- Access to style properties

--== align

function ButtonStateStyle.__getters:align()
	-- print( "ButtonStateStyle.__getters:align" )
	local value = self._align
	if value==nil and self._inherit then
		value = self._inherit.align
	end
	return value
end
function ButtonStateStyle.__setters:align( value )
	-- print( "ButtonStateStyle.__setters:align", value )
	assert( type(value)=='string' or (value==nil and (self._inherit or self._isClearing)))
	--==--
	if value == self._align then return end
	self._align = value
end

--== isHitActive

function ButtonStateStyle.__getters:isHitActive()
	-- print( "ButtonStateStyle.__getters:isHitActive" )
	local value = self._isHitActive
	if value==nil and self._inherit then
		value = self._inherit.isHitActive
	end
	return value
end
function ButtonStateStyle.__setters:isHitActive( value )
	-- print( "ButtonStateStyle.__setters:isHitActive", value )
	assert( type(value)=='boolean' or (value==nil and (self._inherit or self._isClearing)) )
	--==--
	if value == self._isHitActive then return end
	self._isHitActive = value
	self:_dispatchChangeEvent( 'isHitActive', value )
end

--== marginX

function ButtonStateStyle.__getters:marginX()
	-- print( "ButtonStateStyle.__getters:marginX" )
	local value = self._marginX
	if value==nil and self._inherit then
		value = self._inherit.marginX
	end
	return value
end
function ButtonStateStyle.__setters:marginX( value )
	-- print( "ButtonStateStyle.__setters:marginX", value )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self._inherit or self._isClearing)) )
	--==--
	if value == self._marginX then return end
	self._marginX = value
	self:_dispatchChangeEvent( 'marginX', value )
end

--== marginY

function ButtonStateStyle.__getters:marginY()
	-- print( "ButtonStateStyle.__getters:marginY" )
	local value = self._marginY
	if value==nil and self._inherit then
		value = self._inherit.marginY
	end
	return value
end
function ButtonStateStyle.__setters:marginY( value )
	-- print( "ButtonStateStyle.__setters:marginY", value )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self._inherit or self._isClearing)) )
	--==--
	if value == self._marginY then return end
	self._marginY = value
	self:_dispatchChangeEvent( 'marginY', value )
end


--== offsetX

function ButtonStateStyle.__getters:offsetX()
	-- print( "ButtonStateStyle.__getters:offsetX" )
	local value = self._offsetX
	if value==nil and self._inherit then
		value = self._inherit.offsetX
	end
	return value
end
function ButtonStateStyle.__setters:offsetX( value )
	-- print( "ButtonStateStyle.__setters:offsetX", value )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self._inherit or self._isClearing)) )
	--==--
	if value == self._offsetX then return end
	self._offsetX = value
	self:_dispatchChangeEvent( 'offsetX', value )
end

--== offsetY

function ButtonStateStyle.__getters:offsetY()
	-- print( "ButtonStateStyle.__getters:offsetY" )
	local value = self._offsetY
	if value==nil and self._inherit then
		value = self._inherit.offsetY
	end
	return value
end
function ButtonStateStyle.__setters:offsetY( value )
	-- print( "ButtonStateStyle.__setters:offsetY", value, self )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self._inherit or self._isClearing)) )
	--==--
	if value==self._offsetY then return end
	self._offsetY = value
	self:_dispatchChangeEvent( 'offsetY', value )
end


--======================================================--
-- Proxy Methods




--======================================================--
-- Misc

--== inherit

function ButtonStateStyle:_doChildrenInherit( value )
	-- print( "ButtonStateStyle", value, self )
	self._background.inherit = value and value.background or nil
	self._label.inherit = value and value.label or nil

end


function ButtonStateStyle:_clearChildrenProperties( style )
	-- print( "ButtonStateStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(ButtonStateStyle) )
	end
	--==--
	local substyle

	substyle = style and style.background
	self._background:_clearProperties( substyle )

	substyle = style and style.label
	self._label:_clearProperties( substyle )
end


--====================================================================--
--== Private Methods


function ButtonStateStyle:_prepareData( data )
	-- print( "ButtonStateStyle:_prepareData", data )
	if not data then return end
	--==--
	local createStruct = ButtonStateStyle.createStyleStructure

	if data.isa and data:isa( ButtonStateStyle ) then
		--== Instance
		local o = data
		data = createStruct( o.background.view.type )

	else
		--== Lua structure
		local StyleClass
		local src, dest = data, nil

		dest = src.label
		StyleClass = Widgets.Style.Text
		StyleClass.copyExistingSrcProperties( dest, src )

		dest = src.background
		StyleClass = Widgets.Style.Background
		StyleClass.copyExistingSrcProperties( dest, src )

	end

	return data
end



--====================================================================--
--== Event Handlers


-- none




return ButtonStateStyle
