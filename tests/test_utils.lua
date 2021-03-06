--====================================================================--
-- tests/test_utils.lua
--====================================================================--


--[[
copy the following into test file

local hasProperty = TestUtils.hasProperty
local hasPropertyValue = TestUtils.hasPropertyValue

local hasValidStyleProperties = TestUtils.hasValidStyleProperties
local hasInvalidStyleProperties = TestUtils.hasInvalidStyleProperties


local styleInheritsFrom = TestUtils.styleInheritsFrom
local styleIsa = TestUtils.styleIsa

local styleRawPropertyValueIs = TestUtils.styleRawPropertyValueIs
local stylePropertyValueIs = TestUtils.stylePropertyValueIs

local styleHasProperty = TestUtils.styleHasProperty
local styleInheritsProperty = TestUtils.styleInheritsProperty


local styleHasPropertyValue = TestUtils.styleHasPropertyValue
local styleInheritsPropertyValue = TestUtils.styleInheritsPropertyValue

local styleInheritsPropertyValueFrom = TestUtils.styleInheritsPropertyValueFrom

local marker = TestUtils.outputMarker

local verifyButtonStyle = TestUtils.verifyButtonStyle
local verifyButtonStateStyle = TestUtils.verifyButtonStateStyle
local verifyBackgroundStyle = TestUtils.verifyBackgroundStyle
local verifyBackgroundViewStyle = TestUtils.verifyBackgroundViewStyle
local verifyTextStyle = TestUtils.verifyTextStyle


--]]


--====================================================================--
--== Imports


local dUI = require 'lib.dmc_ui'


--====================================================================--
--== Setup, Constants


local Utils = {}

local sfmt = string.format



--====================================================================--
--== Support Functions


function Utils.propertyIn( list, property )
	for i = 1, #list do
		if list[i] == property then return true end
	end
	return false
end


local function propertyIsColor( property )
	if Utils.propertyIn( {'fillColor', 'textColor', 'strokeColor'}, property ) then
		return true
	end
	return false
end


local function colorsAreEqual( c1, c2 )
	local result = true
	if c1==nil and c2==nil then
		result=true
	elseif c1==nil or c2==nil then
		result=false
	else
		if c1[1]~=c2[1] then result=false end
		if c1[2]~=c2[2] then result=false end
		if c1[3]~=c2[3] then result=false end
		if c1[4]==nil and c2[4]==nil then
			-- pass
		elseif c1[4]==nil or c2[4]==nil then
			result=false
		elseif c1[4]~=c2[4] then
			result=false
		end
	end
	return result
end


local function formatColor( value )
	local str = ""
	if value==nil then
		str = sfmt( "(nil, nil, nil, nil)" )
	elseif value.type=='gradient' then
		str = sfmt( "(gradient)" )
	elseif #value==3 then
		str = sfmt( "(%s, %s, %s, nil)", unpack( value ) )
	else
		str = sfmt( "(%s, %s, %s, %s)", unpack( value ) )
	end
	return str
end


local function format( property, value )
	-- print( "format", property, value )
	local str = ""
	if propertyIsColor( property ) then
		str = sfmt( "'%s' %s", tostring(property), formatColor( value ) )
	else
		str = sfmt( "'%s'", tostring(property) )
	end
	return str
end



--====================================================================--
--== DMC Widgets Test TestUtils
--====================================================================--


local TestUtils = {}


function TestUtils.outputMarker()
	print( "\n\n\n MARKER \n\n\n" )
end


--======================================================--
-- Base Style Verification

function TestUtils.verifyTextStyle( style )
	assert( style, "TestUtils.verifyTextStyle missing arg 'style'" )
	local Text = dUI.Style.Text
	local inherit = style.inherit

	TestUtils.styleIsa( style, Text )

	if inherit and inherit~=style.NO_INHERIT then
		TestUtils.styleIsa( style.inherit, Text )
	end

	assert_equal( style.NAME, Text.NAME, "background name is incorrect" )

	TestUtils.hasProperty( style, 'debugOn' )
	--[[
	width & height can be optional
	-- TestUtils.hasProperty( style, 'width' )
	-- TestUtils.hasProperty( style, 'height' )
	--]]
	TestUtils.hasProperty( style, 'anchorX' )
	TestUtils.hasProperty( style, 'anchorY' )

	TestUtils.hasProperty( style, 'align' )
	TestUtils.hasProperty( style, 'fillColor' )
	TestUtils.hasProperty( style, 'font' )
	TestUtils.hasProperty( style, 'fontSize' )
	TestUtils.hasProperty( style, 'marginX' )
	TestUtils.hasProperty( style, 'marginY' )
	TestUtils.hasProperty( style, 'strokeColor' )
	TestUtils.hasProperty( style, 'strokeWidth' )
	TestUtils.hasProperty( style, 'textColor' )

end


function TestUtils.verifyBackgroundViewStyle( style )
	assert( style, "TestUtils.verifyBackgroundViewStyle missing arg 'style'" )
	local StyleFactory = dUI.Style.BackgroundFactory
	local BaseViewStyle = StyleFactory.Style.Base
	local Rectangle = StyleFactory.Style.Rectangle
	local Rounded = StyleFactory.Style.Rounded
	local inherit = style.inherit

	TestUtils.styleIsa( style, BaseViewStyle )

	TestUtils.hasProperty( style, 'debugOn' )
	TestUtils.hasProperty( style, 'width' )
	TestUtils.hasProperty( style, 'height' )
	TestUtils.hasProperty( style, 'anchorX' )
	TestUtils.hasProperty( style, 'anchorY' )
	TestUtils.hasProperty( style, 'type' )

	local sType = style.type

	if sType==Rectangle.type then
		TestUtils.styleIsa( style, Rectangle )
		assert_equal( style.NAME, Rectangle.NAME, "background view name is incorrect" )
		if inherit and inherit~=style.NO_INHERIT then
			TestUtils.styleIsa( style.inherit, Rectangle )
		end
		TestUtils.hasProperty( style, 'fillColor' )
		TestUtils.hasProperty( style, 'strokeColor' )
		TestUtils.hasProperty( style, 'strokeWidth' )

	elseif sType==Rounded.type then
		TestUtils.styleIsa( style, Rounded )
		assert_equal( style.NAME, Rounded.NAME, "background view name is incorrect" )
		if inherit and inherit~=style.NO_INHERIT then
			TestUtils.styleIsa( style.inherit, Rounded )
		end
		TestUtils.hasProperty( style, 'cornerRadius' )
		TestUtils.hasProperty( style, 'fillColor' )
		TestUtils.hasProperty( style, 'strokeColor' )
		TestUtils.hasProperty( style, 'strokeWidth' )
	else
		error( sfmt( "Background view type not implemented '%s'", tostring( sType ) ))
	end


end

function TestUtils.verifyBackgroundStyle( style )
	assert( style, "TestUtils.verifyBackgroundStyle missing arg 'style'" )
	local Background = dUI.Style.Background
	local child, emsg
	local inherit = style.inherit

	TestUtils.styleIsa( style, Background )

	if inherit and inherit~=style.NO_INHERIT then
		TestUtils.styleIsa( style.inherit, Background )
	end

	assert_equal( style.NAME, Background.NAME, "background name is incorrect" )

	TestUtils.hasProperty( style, 'debugOn' )
	TestUtils.hasProperty( style, 'width' )
	TestUtils.hasProperty( style, 'height' )
	TestUtils.hasProperty( style, 'anchorX' )
	TestUtils.hasProperty( style, 'anchorY' )
	TestUtils.hasProperty( style, 'type' )
	TestUtils.hasProperty( style, 'view' )

	child = style.view
	assert_true( child, "Background style is missing child property 'view'" )
	assert_equal( style.type, child.type, "type mismatch in background type, child view" )

	TestUtils.verifyBackgroundViewStyle( child )
end


function TestUtils.verifyButtonStateStyle( style )
	assert( style, "TestUtils.verifyButtonStateStyle missing arg 'style'" )
	local ButtonState = dUI.Style.ButtonState
	local child, emsg
	local inherit = style.inherit

	TestUtils.styleIsa( style, ButtonState )

	if inherit and inherit~=style.NO_INHERIT then
		TestUtils.styleIsa( style.inherit, ButtonState )
	end

	assert_equal( style.NAME, ButtonState.NAME, "Button State name is incorrect" )

	if style.inherit then
		TestUtils.styleIsa( style.inherit, ButtonState )
	end

	TestUtils.hasProperty( style, 'debugOn' )
	TestUtils.hasProperty( style, 'width' )
	TestUtils.hasProperty( style, 'height' )
	TestUtils.hasProperty( style, 'anchorX' )
	TestUtils.hasProperty( style, 'anchorY' )
	TestUtils.hasProperty( style, 'align' )
	TestUtils.hasProperty( style, 'isHitActive' )
	TestUtils.hasProperty( style, 'marginX' )
	TestUtils.hasProperty( style, 'marginY' )
	TestUtils.hasProperty( style, 'offsetX' )
	TestUtils.hasProperty( style, 'offsetY' )

	child = style.label
	assert_true( child )
	TestUtils.verifyTextStyle( child )

	child = style.background
	assert_true( child )
	TestUtils.verifyBackgroundStyle( child )

end

function TestUtils.verifyButtonStyle( style )
	assert( style, "TestUtils.verifyButtonStyle missing arg 'style'" )
	local Button = dUI.Style.Button
	local child, emsg
	local inherit = style.inherit

	TestUtils.styleIsa( style, Button )

	if inherit and inherit~=style.NO_INHERIT then
		TestUtils.styleIsa( style.inherit, Button )
	end

	assert_equal( style.NAME, Button.NAME, "Button name is incorrect" )

	if style.inherit then
		TestUtils.styleIsa( style.inherit, Button )
	end

	TestUtils.hasProperty( style, 'debugOn' )
	TestUtils.hasProperty( style, 'width' )
	TestUtils.hasProperty( style, 'height' )
	TestUtils.hasProperty( style, 'anchorX' )
	TestUtils.hasProperty( style, 'anchorY' )
	TestUtils.hasProperty( style, 'align' )
	TestUtils.hasProperty( style, 'hitMarginX' )
	TestUtils.hasProperty( style, 'hitMarginY' )
	TestUtils.hasProperty( style, 'isHitActive' )
	TestUtils.hasProperty( style, 'marginX' )
	TestUtils.hasProperty( style, 'marginY' )

	child = style.active
	assert_true( child )
	TestUtils.verifyButtonStateStyle( child )

	child = style.inactive
	assert_true( child )
	TestUtils.verifyButtonStateStyle( child )

	child = style.disabled
	assert_true( child )
	TestUtils.verifyButtonStateStyle( child )

end


function TestUtils.verifyTextFieldStyle( style )
	assert( style, "TestUtils.verifyTextFieldStyle missing arg 'style'" )
	local TextField = dUI.Style.TextField
	local child, emsg
	local inherit = style.inherit

	TestUtils.styleIsa( style, TextField )

	assert_equal( style.NAME, TextField.NAME, "TextField name is incorrect" )

	if inherit and inherit~=style.NO_INHERIT then
		TestUtils.styleIsa( style.inherit, TextField )
	end

	TestUtils.hasProperty( style, 'debugOn' )
	TestUtils.hasProperty( style, 'width' )
	TestUtils.hasProperty( style, 'height' )
	TestUtils.hasProperty( style, 'anchorX' )
	TestUtils.hasProperty( style, 'anchorY' )
	TestUtils.hasProperty( style, 'align' )
	TestUtils.hasProperty( style, 'backgroundStyle' )
	TestUtils.hasProperty( style, 'inputType' )
	TestUtils.hasProperty( style, 'isHitActive' )
	TestUtils.hasProperty( style, 'isSecure' )
	TestUtils.hasProperty( style, 'marginX' )
	TestUtils.hasProperty( style, 'marginY' )
	TestUtils.hasProperty( style, 'returnKey' )

	child = style.background
	assert_true( child )
	TestUtils.verifyBackgroundStyle( child )

	child = style.hint
	assert_true( child )
	TestUtils.verifyTextStyle( child )

	child = style.display
	assert_true( child )
	TestUtils.verifyTextStyle( child )

end



--======================================================--
-- Table tests

-- can be used on tables or Style instances

-- checks whether style has a non-nil property
-- via inheritance or local
--
function TestUtils.hasProperty( source, property )
	assert( source, "TestUtils.hasProperty missing arg 'source'" )
	assert( property, "TestUtils.hasProperty missing arg 'property'" )
	local emsg = sfmt( "missing property '%s'", tostring( property ) )
	assert_true( source[property]~=nil, emsg )
end


-- checks whether style has a value for property
-- via inheritance or local
--
function TestUtils.hasPropertyValue( source, property, value )
	assert( source, "TestUtils.hasPropertyValue missing arg 'source'" )
	assert( property, "TestUtils.hasPropertyValue missing arg 'property'" )
	local emsg = sfmt( "incorrect value for property '%s'", tostring( property ) )
	if propertyIsColor( property ) then
		emsg = sfmt( "color mismatch %s<>%s", formatColor( source[property] ), formatColor( value ) )
		assert_true( colorsAreEqual( value, source[property] ), emsg )
	else
		assert_equal( value, source[property], emsg )
	end
end


function TestUtils.hasValidStyleProperties( class, source )
	assert( class, "TestUtils.hasValidStyleProperties missing 'class'" )
	assert( source, "TestUtils.hasValidStyleProperties missing 'source'" )
	local emsg = sfmt( "invalid class properties for '%s'", tostring( class ) )
	assert_true( class._verifyStyleProperties( source ), emsg )
end

function TestUtils.hasInvalidStyleProperties( class, source )
	assert( class, "TestUtils.hasInvalidStyleProperties missing arg 'class'" )
	assert( source, "TestUtils.hasInvalidStyleProperties missing arg 'source'" )
	local emsg = sfmt( "invalid class properties for '%s'", tostring( class.NAME ) )
	assert_false( class._verifyStyleProperties( source ), emsg )
end



--======================================================--
-- Style-instance tests

-- styleInheritsFrom()
-- tests to see if Style inheritance matches
-- tests for Inherit match
--
function TestUtils.styleInheritsFrom( style, class )
	assert( style, "TestUtils.styleInheritsFrom missing arg 'style'" )
	local emsg = sfmt( "incorrect class inheritance for '%s'", tostring( style ) )
	assert_equal( style._inherit, class, emsg )
end


function TestUtils.styleIsa( style, class )
	assert( style, "TestUtils.styleIsa missing arg 'style'" )
	assert( class, "TestUtils.styleIsa missing arg 'class'" )
	local emsg = sfmt( "incorrect base class for '%s', expected '%s'", tostring(style), tostring(class) )
	assert_true( style:isa( class ), emsg )
end


-- styleRawPropValueIs()
-- tests to see whether the property value matches test value
-- test only local property value
--
function TestUtils.styleRawPropertyValueIs( style, property, value )
	assert( style, "TestUtils.styleRawPropertyValueIs missing arg 'style'" )
	assert( property, "TestUtils.styleRawPropertyValueIs missing arg 'property'" )
	local emsg = sfmt( "incorrect local property value for '%s'", format( property, value ) )

	if propertyIsColor( property ) then
		local color = style:_getRawProperty( property )
		emsg = sfmt( "color mismatch for property '%s' %s<>%s", property, formatColor( color ), formatColor( value ) )
		assert_true( colorsAreEqual( value, color ), emsg )
	else
		-- local value
		assert_equal( style:_getRawProperty( property ), value, emsg )
	end
end

-- stylePropValueIs()
-- tests to see whether the property value matches test value
-- tests either local or inherited values
--
function TestUtils.stylePropertyValueIs( style, property, value )
	assert( style, "TestUtils.stylePropertyValueIs missing arg 'style'" )
	assert( property, "TestUtils.stylePropertyValueIs missing arg 'property'" )
	local emsg = sfmt( "incorrect value for property '%s'", format( property, value ) )
	-- using getters (inheritance)
	if propertyIsColor( property ) then
		emsg = sfmt( "color mismatch for '%s' %s<>%s", property, formatColor( style[property] ), formatColor( value ) )
		assert_true( colorsAreEqual( value, style[property] ), emsg )
	else
		assert_equal( value, style[property], emsg )
	end
end


-- styleHasProperty()
-- tests to see whether the property value is local to Style
-- test whether local property is NOT nil
--
function TestUtils.styleHasProperty( style, property )
	assert( style, "TestUtils.styleHasProperty missing arg 'style'" )
	assert( property, "TestUtils.styleHasProperty missing arg 'property'" )
	local emsg = sfmt( "style inherits property '%s'", tostring( property ) )
	assert_true( style:_getRawProperty(property)~=nil, emsg )
end

-- styleInheritsProp()
-- tests to see whether the style inherits its property
-- test whether local property is nil
--
function TestUtils.styleInheritsProperty( style, property )
	assert( style, "TestUtils.styleInheritsProperty missing arg style'" )
	assert( property, "TestUtils.styleInheritsProperty missing arg 'property'" )
	local emsg = sfmt( "style has local property '%s'", tostring( property ) )
	assert_true( style:_getRawProperty(property)==nil, emsg )
end


--======================================================--
-- Style-instance "combo" tests

-- styleHasPropertyValue()
-- combo test to see whether the property value is local to Style
-- checks all possibilities
--
function TestUtils.styleHasPropertyValue( style, property, value )
	TestUtils.stylePropertyValueIs( style, property, value )
	TestUtils.styleHasProperty( style, property )
	TestUtils.styleRawPropertyValueIs( style, property, value )
end


-- styleInheritsPropertyValue()
-- combo test to see whether the property value is local to Style
-- checks all possibilities
--
function TestUtils.styleInheritsPropertyValue( style, property, value )
	TestUtils.stylePropertyValueIs( style, property, value )
	TestUtils.styleInheritsProperty( style, property )
	-- last item is supposed to be nil
	TestUtils.styleRawPropertyValueIs( style, property, nil )
end


-- styleInheritsPropValueFrom()
-- combo test to see whether the property value is inherited
-- checks all possibilities
--
function TestUtils.styleInheritsPropertyValueFrom( style, property, value, inherit )
	TestUtils.stylePropertyValueIs( style, property, value )
	TestUtils.styleInheritsProperty( style, property )
	TestUtils.styleInheritsFrom( style, inherit )
end




return TestUtils
